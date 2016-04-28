# usage: ./packageinstall.sh package_identifier
# example: ./packageinstall.sh autoconf
# the script is assuming you're running it in the ports directory (which is a bit stupid, need to be changed later)
#
# TODO: add error management. installpackage() should be a transaction. ex: what do you do when "make install" returns an error? right now, we do nothing, which is incorrect
# TODO: if a package installation returns an error, the *whole* build should be aborted immediately,
#       namely, your (installpackage $pkg_name) should check if it returns an error and abort if that's the case

packagedirectory=packages

# the function called by default to build a package, works for most packages
defaultbuild(){
	package_fullname=$package_name-$package_version
	package_tarball_name=$package_fullname.tar.$tarball_suffix
	rm $package_tarball_name
	wget $url
	tar xvf $package_tarball_name
	cd $package_fullname/
	./configure --prefix=/opt/$package_fullname/
	make
	make install
	ln -sv /opt/$package_fullname /opt/$package_name
	ln -sv /opt/$package_name/bin/* /bin/
	cd ..
}


installpackage(){
	echo "installing package $1"
	
	# set default values for variables TODO: these variables belong to the packages definitions files, it's not the job of the package manager to set these variables
	iscustombuild=
	haspostinstall=

	source $packagedirectory/$1
	
	package_fullname=$package_name-$package_version
	if [ -d "/opt/$package_fullname" ]; then
		echo "package $package_fullname already installed"
		return
	fi
	
	echo "dependencies of $1: $build_dependencies"
	
	# installing the package's dependencies recursively
	for pkg_name in $build_dependencies
	do
		(installpackage $pkg_name)
	done
	
	# do a custom build if the package defines custombuild(), otherwise do a default build
	if test $iscustombuild
	then custombuild
	else defaultbuild
	fi
	
	# call its postinstall() function if the package defines postinstall(), otherwise do nothing
	if test $haspostinstall
	then postinstall
	fi
	
	# clean up by removing the build directory and the tarball
	rm -rf $package_fullname
	rm $package_fullname.tar.$tarball_suffix
	
}


installpackage $1
