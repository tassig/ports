# usage: ./packageinstall.sh package_name
# the script is assuming you're running it in the ports directory (which is a bit stupid, need to be changed later)

packagedirectory=packages

# the function called by default to build a package, works for most packages
defaultbuild(){
	package_fullname=$package_name-$package_version
	wget $url
	tar xvf $package_fullname.tar.$tarball_suffix
	cd $package_fullname/
	./configure --prefix=/opt/$package_fullname/
	make
	make install
	ln -s /opt/$package_fullname /opt/$package_name
	ln -s /opt/$package_name/bin/* /bin/
	cd ..
}


installpackage(){
	echo "installing package $1"
	
	source $packagedirectory/$1
	echo "dependencies of $1: $build_dependencies"
	
	# installing the dependencies recursively
	for pkg_name in $build_dependencies
	do
		(installpackage $pkg_name)
	done
	
	# do a custom build if the package defines custombuild(), otherwise do a default build
	if test iscustombuild
	then custombuild
	else defaultbuild
	fi
	
	# call its postinstall() function if the package defines postinstall(), otherwise do nothing
	if test haspostinstall
	then postinstall
	fi
	
}


installpackage $1
