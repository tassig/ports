package_name=flatpak
package_version=1.4.3
tarball_suffix=xz
build_dependencies= # TODO: add in proper order
no_check=1

# direct requirements: 
#    glib  (ports)
#    libarchive (ports)
#    libsoup (ports)
#    libcap (ports)
#    polkit (ports)
#    libxau ( we have it with X, but we can disable it )
#    ostree  (ports)
#    fuse  (ports)
#    json-glib (ports)
#    gcab (ports) 
#    appstream-glib (ports)
#    dconf (ports)
#    libseccomp (ports, we can disaable it)
#    libxslt (ports)
#    gpgme (ports)
#    bison (ports)
#    gobject-introspection (ports)
#    Linux-PAM (ports) - who depens on it?
#
# indirect requirements:
#    gpgme requires: gnupg (ports)
#    gnupg requires: 
#       libgpg-error (ports)
#       libassuan (ports) 
#       libgcrypt (ports) 
#       libksba (ports)
#       npth (ports)
#    libarchive requres: attr (ports)
#

# TODO: i then download a pakref file on flathub.org, and did:
#       flatpak install /home/jerry/Downloads/com.spotify.Client.flatpakref 
#       which return with error: error: Unable to connect to system bus
#       i can imagine it's about dbus, or who knows
#       if you run as root, it complains about TLS support (i don't know why we don't have TLS support)

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

}
