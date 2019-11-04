package_name=flatpak
package_version=1.4.3
tarball_suffix=xz
build_dependencies="glib libarchive libsoup libcap polkit glib-networking libostree fuse json-glib gcab appstream-glib dconf libseccomp libxslt gpgme bison"
no_check=1

# dependences (all in ports): 
#    glib
#    libarchive "zlib libressl"
#    libsoup "sqlite libxml2 gobject-introspection glib-networking"
#    libcap 
#    poklit "glib intltool Linux-PAM gobject-introspection expat mozjs"
#    glib-networking "glib gnutls intltool gsettings-desktop-schemas" NOTE: production image needs perl
#    libostree "glib bison xz e2fsprogs libarchive libsoup gpgme fuse libxslt"
#    fuse 
#    json-glib 
#    gcab
#    appstream-glib "glib gdk-pixbuf libarchive libsoup libuuid meson ninja cmake json-glib"
#    dconf "dbus glib gtk+2 libxml2"
#    libseccomp
#    libxslt
#    gpgme "gnupg"
#    bison

custombuild(){
	SRC_DIR=$(pwd)
	rm -rf builddir
	mkdir -p builddir
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	export CPPFLAGS="-I/opt/libcap/include"
	export LDFLAGS="-L/opt/libcap/lib -L/opt/libuuid/lib -Wl,-rpath=/opt/libuuid/lib -Wl,-rpath=/opt/appstream-glib/lib"

	./configure --prefix=/opt/flatpak-1.4.3 --disable-documentation --with-priv-mode=setuid

	# Apply alpine patch, do it after configure, it will pach generated config.h for missing macros
	patch -p1 < $SRC_DIR/packages/extended/flatpak/musl-fixes.patch

	make -j
	if test -z $no_check   # run the make check, unless $no_check is set for 
						   # this package definition
	then make -j check || make -j test
	fi

	make install

	ln -sv $installdirectory/$package_fullname $installdirectory/$package_name
	ln -sv $installdirectory/$package_name/bin/* /bin/ || true
	if [ -d "$installdirectory/$package_name/lib/pkgconfig" ]; then
		ln -svf $installdirectory/$package_name/lib/pkgconfig/* \
		$installdirectory/pkgconf/lib/pkgconfig/
	fi
	cd ../..
	rm -r builddir
	
	
	# TODO: /opt/flatpak/var needs to be redirected to a place with lots of space, i'm not sure at the moment if we can put it in ~/.opt/ , or something similar writable by jerry, or if flatpak needs root permissions, i have currently put it in /home/varflatpak
	
	# TODO: /tmp is not big enough (i've circumvented for testing purposes), and i don't know how to configure $TMP_DIR for ostree, also i was unable to reproduce this error
	
	
# NOTE: for some apps (like spotify) need to set XDG_DATA_DIRS environment variable to /opt/gsettings-desktop-schemas-3.20.0/share before launching flatpak
	
	# TODO: i also did export LD_LIBRARY_PATH=/opt/libcap/lib:/opt/nettle/lib to solve the error: Error loading shared library libcap.so.2: No such file or directory (needed by /opt/flatpak/libexec/flatpak-bwrap)
	# these should be temporary
	
	# TODO: i then download a pakref file on flathub.org, and did:
#       flatpak -vv --ostree-verbose install /home/jerry/Downloads/com.spotify.Client.flatpakref 
#       which return with error: error: Unable to connect to system bus
#       i can imagine it's about dbus, or who knows
#       if you run as root, it works, but ultimately fails with the following:
# bwrap: Can't bind mount /oldroot/home/varflatpak/lib/flatpak/runtime/org.freedesktop.Platform/x86_64/19.08/5a35247ad1c941455f2f9c4139d9136c6c0662e1b04e5b3c56121e7f67ba0100/files on /newroot/usr: No such file or directory
# or similarly, for other apps: 
# F: Running '/opt/flatpak/libexec/flatpak-bwrap --unshare-ipc --unshare-net --unshare-pid --ro-bind / / --proc /proc --dev /dev --bind /home/varflatpak/lib/flatpak /home/varflatpak/lib/flatpak /opt/flatpak/share/flatpak/triggers/desktop-database.trigger /home/varflatpak/lib/flatpak'
# bwrap: Can't bind mount /oldroot/ on /newroot/: No such file or directory

# NOTE: bubblewrap issue is easily fixed by installing bubblewrap separately, and adding --with-system-bubblewrap  into configure call

# UPDATE: now what works is to do:
# flatpatk install telegram
# which must be done as root
# and then do:
# flatpak run telegram
# which can be done as jerry

# Issue we are facing with normal user installation, for example org.gnome.Calculator, we get ostree error:
# Error: Not enough disk space to complete this operation
# error: Failed to install org.gnome.Platform: While pulling runtime/org.gnome.Platform/x86_64/3.34 from remote # flathub: Writing content object: min-free-space-size 500MB would be exceeded, at least 2.0 kB requeste

# with root user this issue won't appear
}
