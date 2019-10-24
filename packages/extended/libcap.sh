package_name=libcap
package_version=2.25
tarball_suffix=gz
build_dependencies=
no_check=1 

# We use custombuild because this is wired build anyway

custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	# NOTE: the installation is weird
	#       need to set LDFLAGS to point to attr in Make.Rules
	#       need to set prefix=/opt/libcap at the top of Make.Rules
	#
	# in Make.Rules: LDFLAGS += -L$(topdir)/libcap -L/opt/attr/lib -Wl,-rpath=/opt/attr/lib -Wl,-rpath=/opt/libcap/lib
	#                prefix=/opt/libcap
	#

	# don't use Debian specific wat to form lib, just use lib=lib
	LINE_TO_REPLACE=`sed -n /lib=/= Make.Rules`
	sed -i "${LINE_TO_REPLACE}s|.*|lib=lib|" Make.Rules

	# use prefix=/opt/libcap
	sed -i '18iprefix=/opt/libcap' Make.Rules

	# add additional LDFLAGS
	sed -i 's|LDFLAGS += -L$(topdir)/libcap|LDFLAGS += -L$(topdir)/libcap -L/opt/attr/lib -Wl,-rpath=/opt/attr/lib -Wl,-rpath=/opt/libcap/lib|g' Make.Rules

	make
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
