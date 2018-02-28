#include <stdio.h>      /* printf, perror */
#include <stdlib.h>     /* malloc, client code will free command buffer we send */
#include <unistd.h>     /* read, write, unlink, close */
#include <string.h>     /* strcmp, strcpy, memset */
#include <sys/socket.h> /* socket, bind, listen, accept, AF_UNIX, SOCK_STREAM */
#include <sys/un.h>     /* struct sockaddr_un */
#include <fcntl.h>      /* F_GETFL, F_SETFL, fcntl */
#include <glib.h>       /* clien code use glib defs, we use them too to stay compliant */
#include "unixsocket.h" /* client code interface and definitions */

/* packet format:
 * NOTE: we implement only a subset of commands, sufficient for minimal GUI operation
 * commands are being received as strings, by periodic pooling loop, and sent to rl_handler
 * replys are sent as strings of fixed length of 1024 bytes, in following format:
 * 
 * string + /0 - reply string and null termination
 * 
 * we implement synchronous command->reply pattern, for simplicity, and only for subset of available commands:
 *   - is_ready  - custom command to check if unix socket backend is operational
 *   - scan on   - start continuous device scan
 *   - scan off  - stop scan
 *   - devices   - list of available devices, in format: mac device_name
 *   - info mac  - detailed info on a device with given mac
 *   - agent on  - trun on bluetooth agent
 *   - default-agent - we use only default agent for now
 *   - pair mac  - pair device with given mac, NOTE: if pin appears to be required, it shall be handled internally, by writing it back
 *   - trust mac - trust device with a given mac
 *   - connect mac - connect device with a given mac
 *   - delete mac - delete device with a given mac
 * 
 */

#define REPLY_BUFF_SIZE   1024
#define COMMAND_BUFF_SIZE 64

guint us_use_unix_socket_backend = 0;  /* navigate unix socket specific operations */
gchar us_reply[REPLY_BUFF_SIZE];       /* based on previous flag, functions will fill the buffer instead of rl_printf...*/
guint us_reply_pos = 0;                /* position in the us_reply buffer to append */

gint us_fd;         /* unix socket file descriptor */
gint us_conn = 0;   /* accepted connection file descriptor */
                    /* NOTE we can accept multiple connections */

/* axiom patch, unix socket command interface */
guint unix_socket_backend_open (gchar *path)
{
	struct sockaddr_un addr; /* used to setup connection */

	/* fail if path is not provided TODO: why care? bind() will fail */
	if(path == NULL)
		return -1;
	
	/* open unix socket, and fail if not successful */
	if((us_fd = socket (AF_UNIX, SOCK_STREAM, 0)) == -1)
		return -1;
	
	/* setup unix sokcket file path */
	memset (&addr, 0, sizeof(addr));
	addr.sun_family = AF_UNIX;
	strcpy (addr.sun_path, path);
	
	/* eplicitely unlink, so we'll create new one */
	unlink (path);
	
	/* bind to provided unix socket path */
	if (bind (us_fd, (struct sockaddr*)&addr, sizeof (addr)) == -1)
	{
		perror ("Error bind: ");
		return -1;
	}
	
	/* dirty hack to allow user jerry to run btsetup, and to connect to unix socket TODO: we shouldn't need that */
	chown (path, 1001, 1001);
	
	/* listen incoming connections */
	if (listen (us_fd, 5) == -1)
	{
		perror ("Error listen: ");
		return -1;
	} 
	
	/* ignore SIGPIPE, as write may crash if other end close conection during write */
	signal(SIGPIPE, SIG_IGN);
	
	return 0;
}

/* simply close open connection and sockets */
void unix_socket_backend_close (void)
{
	if (us_conn)
		close (us_conn);
	
	if (us_fd)
		close (us_fd);
}

/* await connection, read incoming data and process it 
 * NOTE: we use existing bluetoothctl client code to process commands, rl_handler()
 *       all command handlers of interest will fill in us_reply[] and write it to the unix socket
 * NOTE: we aslo process one custom command "is_ready" will be used by btsetup to check socket operation
 */
gboolean unix_socket_backend_process (gpointer path)
{
	gint cmd_len, result_len, bytes_sent;
	gchar *cmd = (gchar *)malloc (COMMAND_BUFF_SIZE); /* existing rl_handler code is written to free it */
	int flags;
	
	/* await for a connection, until it's eatablished
	 * the idea is , once started, to leave bluetoothctl active, and able to accept new connections
	 * also to detect connection loss and to establish new connections
	 * this way it acts as a daemon, allowing btsetup to connect as many times it's necessary */
	if(us_conn == 0)
	{
		/* NOTE: to be able to use accept, us_fd has to be in blocking mode, which is default */
		if ((us_conn = accept (us_fd, NULL, NULL)) == -1)
		{
			perror("Error accept: ");
			return TRUE;
		}
		
		/* reset reply write pointer and bufffer, we received command and we'll process it */
		us_reply_pos = 0;
		us_reply[0] = 0;
		
		/* IMPORTANT: we use non blocking read on established connection because client code still has to
		 *            process dbus events, detect new devices, state changes, etc.. we need to give it time to do so */
		flags = fcntl (us_conn, F_GETFL, NULL);
		flags |= O_NONBLOCK;
		fcntl (us_conn, F_SETFL, flags);
	}
	
	/* we await a coomand on accepted connection, in non-blocking mode */
	cmd_len = read (us_conn, cmd, COMMAND_BUFF_SIZE);
	if(cmd_len == COMMAND_BUFF_SIZE)
	{
		cmd[cmd_len] = 0; /* make sure to zero terminate, although sender was supposed to do so */
		
		/* process on specific message, to check other side od the socket */
		if (!strcmp (cmd, "is_ready"))
		{
			strcpy (us_reply, "ok");
			unix_socket_write_reply ();
			return TRUE;
		}
		
		/* normally process commands 
		 * this is the way we call client code to process command, and write reply 
		 * IMPORTANT: forming reply may take several steps, we client code will write it sequentialy
		 *            by using unix_socket_reply_append() function, see below...
		 */
		us_reply_pos = 0;
		clent_process_command (cmd);
	}
	else
	{
		/* NOTE: non-blocking read will return -1, so we do nothing, just wait next call */

		/* if read return 0, then other side closed connection */
		/* on connection closed, enable new connection */
		if(cmd_len == 0)
		{
			close (us_conn);
			us_conn = 0;      /* will trigger new accept call */
		}
	}
	
	return TRUE;
}

/* IMPORTANT: client code does not have well defined place to form command replise, due to 
 *            the fact that normally, command replies are written on stdout, and not in any kind of buffer.
 *            so we have to allow client to form reply buffer, by sequential calls to this function.
 *            for example, 'info mac' command, will use many rl_printf's to create final command output, and 
 *            everywhere it happens, we have to call unix_socket_reply_append() in parallel, to fill in the buffer.
 *            since client code use variadic argument list, we do so, mimicing the way rl_printf operates.
 */
void unix_socket_reply_append (const gchar *format, ...)
{
	va_list argptr;
    va_start (argptr, format);
    
    /* write body reply */
    /* move current reply pointer to the next writable position */
    us_reply_pos += vsprintf ((gchar *)us_reply + us_reply_pos, format, argptr);
    va_end (argptr);
}

/* write command reply, back to the connection */
/* IMPORTANT: this function is being called form client code, in the moment client has finished command processing.
 *            and client code implements fair amount of dbus method calls and callbacks, so one shall be very carefull
 *            to be sure, that this function will not be called outside our command scope, as it will break sync with
 *            other side. 
 *            up to now, with few simple commands and replies, this is not such an issue, but it may be tricky for some
 *            other commands. one workaround would be to implement message headers and seq numbers
 */
void unix_socket_write_reply ()
{
	int bytes_written = 0;
	
	/* don't try to write if we don't have proper socket and connection */
	if (us_fd && us_conn)
	{
		/* IMPORTANT: to prevent silent write failure, if other side has closed connection during write,
		 *            we used signal(SIGPIPE, SIG_IGN) call, to redirect SIGPIPE to SIG_IGN, in fact to ignore this error.
		 *            in such case, write will return -1, and we will await for another connection
		 */
		bytes_written = write (us_conn, us_reply, REPLY_BUFF_SIZE);
		if (bytes_written <= 0)
			us_conn = 0;
	}

	/* once command was written, or error occured, we reset reply buffer write position and buffer */
	us_reply_pos = 0;
	us_reply[0] = 0;
}

