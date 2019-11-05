package_name=flatpak
package_version=1.4.3
tarball_suffix=xz
build_dependencies="glib libarchive libsoup libcap polkit glib-networking libostree bubblewrap fuse json-glib gcab appstream-glib dconf libseccomp libxslt gpgme bison"
no_check=1

# dependences (all in ports): 
#    glib
#    libarchive "zlib libressl"
#    libsoup "sqlite libxml2 gobject-introspection glib-networking"
#    libcap 
#    poklit "glib intltool Linux-PAM gobject-introspection expat mozjs"
#    glib-networking "glib gnutls intltool gsettings-desktop-schemas" NOTE: production image needs perl
#    libostree "glib bison xz e2fsprogs libarchive libsoup gpgme fuse libxslt"
#    bubblewrap "autoconf automake libcap"
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
	export LDFLAGS="-L/opt/libcap/lib -Wl,-rpath=/opt/libcap/lib -L/opt/libuuid/lib -Wl,-rpath=/opt/libuuid/lib -Wl,-rpath=/opt/appstream-glib/lib/"

	./configure --prefix=/opt/$package_fullname --disable-documentation --with-priv-mode=setuid --with-system-bubblewrap

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
	
	# /opt/flatpak/var needs to be redirected to a place with lots of space, i'm not sure at the moment if we can put it in ~/.opt/ , or something similar writable by jerry, or if flatpak needs root permissions, i have currently put it in /home/varflatpak
	mkdir -p /home/varflatpak
	ln -sv /home/varflatpak /opt/flatpak/var
	
	# Very basic usage:
	# (as root)
	# export XDG_DATA_DIRS=/opt/gsettings-desktop-schemas-3.20.0/share
	# flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	# flatpak install telegram
	#
	# (as normal user)
	# flatpak run org.telegram.desktop
	#
	# NOTE: for some apps (like spotify) need to do: export XDG_DATA_DIRS=/opt/gsettings-desktop-schemas-3.20.0/share before launching flatpak
}
