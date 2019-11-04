
package_name=go
package_version=1.13.4
tarball_suffix=gz
build_dependencies="go-binary"

function custombuild(){
	builddir="builddir-$package_fullname"  # build directory is "builddir" followed by the name of the package, which allows multiple builds of different software in parallel
  rm -rf $builddir
  mkdir -p $builddir   # do everything in builddir for tidiness
  cd $builddir
  BUILD_DIR=$PWD
  wget -O archive $url
  tar xvf archive
  rm archive
	cd *   # cd into the package directory

  SRC_DIR=$PWD
  mkdir -p $BUILD_DIR/tmp

  cd src
  GOROOT=$installdirectory/$package_fullname \
      GOROOT_FINAL=$installdirectory/$package_fullname \
      GOROOT_BOOTSTRAP=$installdirectory/$package_fullname.linux-amd \
      TMPDIR=$BUILD_DIR/tmp \
      sh make.bash   # same as above, but without the tests, which stupidly fail
  # we had passed GOROOT_FINAL variable, which should define install prefix, but maske.bash does not perform actual install, so we just copy result into install prefix
  cd ..
  mkdir -p $installdirectory/$package_fullname
  cp -r * $installdirectory/$package_fullname
	ln -snv $installdirectory/$package_fullname $installdirectory/$package_name || true
	ln -sv $installdirectory/$package_name/bin/* $bindirectory || true   # don't crash if the links are already there
	if [ -d "$installdirectory/$package_fullname/lib/pkgconfig" ]; then
		ln -svf $installdirectory/$package_fullname/lib/pkgconfig/* $installdirectory/pkgconf/lib/pkgconfig/   # symlink pkg-config files
	fi
	# NOTE: .m4 files should probably be installed as well by default, but i have no strong opinion on it, so for now we leave this to the postinstall() function
	cd ../..
	rm -r $builddir
  # remove bootstrap compiler
  rm -rf $installdirectory/$package_fullname.linux-amd
}
