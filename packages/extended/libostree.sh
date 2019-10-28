
package_name=libostree
package_version=v2019.4
tarball_suffix=gz
build_dependencies="glib xz e2fsprogs git libsoup gpgme fuse"
no_check=1 # TODO: all tests will fail due to missing command

function custombuild(){
	SRC_DIR=`pwd`
	builddir="builddir-$package_fullname"  # build directory is "builddir" followed by the name of the package, which allows multiple builds of different software in parallel
	rm -rf $builddir
	mkdir -p $builddir   # do everything in builddir for tidiness
	cd $builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory
  # depend on gpgme instead of non-existent gpgme-pthread
	patch -p1 < $SRC_DIR/packages/extended/libostree/configure.ac.patch
  # provide missing macros from glibc
  patch -p1 < $SRC_DIR/packages/extended/libostree/musl.patch

  NOCONFIGURE=1 ./autogen.sh
  CFLAGS="-I/opt/libgpg-error/include \
          -I/opt/gpgme/include \
          -I/opt/e2fsprogs/include \
         " \
	LDFLAGS="-Wl,-rpath,/opt/glib/lib \
           -L/opt/gpgme/lib -Wl,-rpath,/opt/gpgme/lib \
           -L/opt/libassuan/lib -Wl,-rpath,/opt/libassuan/lib \
          " \
		./configure --prefix=$installdirectory/$package_fullname/ \
                --enable-man=no

	ncpu=`cat /proc/cpuinfo | grep processor | wc -l`
	make -j$ncpu
	make -j$ncpu
	if test -z $no_check   # run the make check, unless $no_check is set for this package definition
	then make -j$ncpu check || make -j$ncpu test
	fi
	make install
	ln -snv $installdirectory/$package_fullname $installdirectory/$package_name || true
	ln -sv $installdirectory/$package_name/bin/* $bindirectory || true   # don't crash if the links are already there
	if [ -d "$installdirectory/$package_fullname/lib/pkgconfig" ]; then
		ln -svf $installdirectory/$package_fullname/lib/pkgconfig/* $installdirectory/pkgconf/lib/pkgconfig/   # symlink pkg-config files
	fi
	# NOTE: .m4 files should probably be installed as well by default, but i have no strong opinion on it, so for now we leave this to the postinstall() function
	cd ../..
	rm -r $builddir
}
