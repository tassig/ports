/* allows third party software to run commands via dedicated unix socket, instead of interactive mode */

#define PROCESSING_PERIOD_ms 1000                              /* period in which unix_socket_backend_process() is being called */

guint    unix_socket_backend_open (gchar *path);               /* open given unix socketm, binds and listen to */
void     unix_socket_backend_close(void);                      /* close unix socket */
gboolean unix_socket_backend_process (gpointer data);          /* timer based call, to process unix socket commands */
void     unix_socket_reply_append (const gchar *format, ...);  /* whoever writes reply will use this function, specially iterative operations like device/adapter lists */
void     unix_socket_write_reply(void);                        /* write whole us_reply buffer to the socket */

void     clent_process_command (gchar *cmd);                   /* wrapper around client's main command processing function */ 
