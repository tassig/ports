# usage: ./packageinstall.sh package_identifier
# example: ./packageinstall.sh autoconf
# the script is assuming you're running it in the ports directory (which is a bit stupid, need to be changed later)
#
# TODO: add error management. installpackage() should be a transaction. ex: what do you do when "make install" returns an error? right now, we do nothing, which is incorrect

packagedirectory=packages

# the function called by default to build a package, works for most packages
defaultbuild(){
	package_fullname=$package_name-$package_version
	package_tarball_name=$package_fullname.tar.$tarball_suffix
	rm $package_tarball_name
	# TODO: This is hardcoded url, all packages shall define just base URL, while we have to call wget $url/$package_tarball_name... 
	wget $url
	tar xvf $package_tarball_name
	cd $package_fullname/
	./configure --prefix=/opt/$package_fullname/
	make -j
	make install
	ln -sv /opt/$package_fullname /opt/$package_name
	ln -sv /opt/$package_name/bin/* /bin/
	cd ..
}


installpackage(){
	echo "installing package $1"
	
	# set default values for variables for safety TODO: these variables belong to the packages definitions files, it's not the job of the package manager to set these variables
	iscustombuild=
	haspostinstall=

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
	else defaultbuild
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
