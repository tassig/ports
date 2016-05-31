# usage: ./packageinstall.sh package_identifier
# example: ./packageinstall.sh autoconf
# the script is assuming you're running it in the ports directory (which is a bit stupid, need to be changed later)
# refer to "package definition specifications.md" for laws and regulations
#
# TODO: add error management. installpackage() should be a transaction. ex: what do you do when "make install" returns an error? right now, we do nothing, which is incorrect
# TODO: implement it differently for root and normal users (different --prefix)
#

packagedirectory=packages   # the directory name where the packages definitions are located


# the function called by default to build a package, works for most packages
defaultbuild(){
	# set package_fullname to $package_name if package_version is empty TODO: a package is forbidden to not have a version
	package_fullname=$package_name${package_version:+-}$package_version
	package_tarball_name=$package_fullname.tar.$tarball_suffix
	rm $package_tarball_name
	wget -O $package_tarball_name $url   # TODO: when $url is inconsistent with $package_tarball_name, then it's an error in the package definition. In that case, we should exit with an error, not ignore the inconsistency
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

	source $packagedirectory/$1
	
	if [ -d "/opt/$package_name${package_version:+-}$package_version" ]; then
		echo "package $package_name is already installed, not reinstalling"
		return 0
	fi
	
	echo "build dependencies of $1: $build_dependencies"
	
	# installing the package's dependencies recursively
	for pkg_name in $build_dependencies
	do
		(./packageinstall.sh $pkg_name) || exit $?   # i initially used a recursive call to "installpackage" instead, but it was inheriting the shell variables
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
