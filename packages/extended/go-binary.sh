
package_name=go
package_version=1.13.4.linux-amd
tarball_suffix=gz
build_dependencies="patchelf"

# TODO: this should not be its own package, the sole purpose of this is to build go (bootstrap it), so it's always deleted after go install. This should be part of Go script.

function custombuild(){
	  builddir="builddir-$package_fullname"  # build directory is "builddir" followed by the name of the package, which allows multiple builds of different software in parallel
	  rm -rf $builddir
	  mkdir -p $builddir   # do everything in builddir for tidiness
	  cd $builddir
	  wget -O archive $url
	  tar xvf archive
	  rm archive
	  cd *   # cd into the package directory

    # patching built executable to use MUSL LIBC instead of glibc
    patchelf --set-interpreter /lib/ld-musl-x86_64.so.1 bin/go
    mkdir -p $installdirectory/$package_fullname
    cp -r * $installdirectory/$package_fullname

	  cd ../..
	  rm -r $builddir
}
