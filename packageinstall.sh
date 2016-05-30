# usage: ./packageinstall.sh package_identifier
# example: ./packageinstall.sh autoconf
# the script is assuming you're running it in the ports directory (which is a bit stupid, need to be changed later)
# refer to "package definition specifications.md" for laws and regulations
#
# TODO: add error management. installpackage() should be a transaction. ex: what do you do when "make install" returns an error? right now, we do nothing, which is incorrect

packagedirectory=packages

# the function called by default to build a package, works for most packages
defaultbuild(){
	package_fullname=$package_name-$package_version
	package_tarball_name=$package_fullname.tar.$tarball_suffix
	rm $package_tarball_name
	# TODO: This is hardcoded url, all packages shall define just base URL, while we have to call wget $url/$package_tarball_name... 
	wget $url || exit $?
	tar xvf $package_tarball_name || exit $?
	cd $package_fullname/

	CFLAGS=$configure_cflags LDFLAGS=$configure_ldflags ./configure --prefix=/opt/$package_fullname/ $configure_string || exit $?
	make -j || exit $?
	make install
	ln -sv /opt/$package_fullname /opt/$package_name
	ln -sv /opt/$package_name/bin/* /bin/
	cd ..
}


installpackage(){
	echo "installing package $1"
	
	# set default values for variables for safety 
	# TODO: these variables are shell variables, not environment variables. There is no safety hazard, such variables don't go into the subshells. So you can clean this up.
	iscustombuild=
	haspostinstall=
	confflags=
	build_dependencies=
	configure_string=
	configure_ldflags=
	configure_cflags=

	source $packagedirectory/$1
	
	if [ -d "/opt/$package_name-$package_version" ]; then
		echo "package $package_name is already installed, not reinstalling"
		return 0
	fi
	
	echo "build dependencies of $1: $build_dependencies"
	
	# installing the package's dependencies recursively
	for pkg_name in $build_dependencies
	do
		(installpackage $pkg_name) || exit $?
	done
	
	# do a custom build if the package defines custombuild(), otherwise do a default build
	if test $iscustombuild
	then custombuild || exit $?
	else defaultbuild || exit $?
	fi
	
	# call its postinstall() function if the package defines postinstall(), otherwise do nothing
	if test $haspostinstall
	then postinstall
	fi
	
	# clean up by removing the build directory and the tarball
	# TODO: only if $package_name is defined
	rm -rf $package_name*
	
}


installpackage $1
