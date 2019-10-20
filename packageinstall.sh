#!/bin/sh

#
# usage: ./packageinstall.sh package_identifier
# example: ./packageinstall.sh autoconf
#
# the second argument "user-only" can be given to perform a user-only installation
#
# the script is assuming you're running it in the ports directory (which is a 
# bit stupid, need to be changed later) refer to "package definition 
# specifications.md" for laws and regulations
#
# TODO: installpackage() should be a transaction to prevent half-installed 
#   packages and leftovers. ex: what do you do when "make install" returns an 
#   error? right now, we do nothing, which is incorrect
#

set -ex

packagedirectory="packages"   # the directory name where the packages definitions are located
installdirectory="/opt"   # default value for global installs, if the "foruser" argument is specifiedin $2, installdirectory becomes ~/.opt
bindirectory="/bin/"   # default value for global installs
mirror_prefix=http://mirrors.tassig.com

# the function called by default to build a package
# this can be overloaded by defining "custombuild()", which will be used instead
defaultbuild(){
	builddir="builddir-$package_fullname"  # build directory is "builddir" followed by the name of the package, which allows multiple builds of different software in parallel
	rm -rf $builddir
	mkdir -p $builddir   # do everything in builddir for tidiness
	cd $builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory
	./configure --prefix=$installdirectory/$package_fullname/
	ncpu=`cat /proc/cpuinfo | grep processor | wc -l`
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
	cd ../..
	rm -r $builddir
}

installpackage(){
	echo "installing package $1"

	source $packagedirectory/$1
	
	# if the package has been installed for the user or globally, don't install again	
	if [ -d "$installdirectory/$package_name-$package_version" ] || [ -d "/opt/$package_name-$package_version" ] ; then
		echo "package $package_name is already installed, not reinstalling"
		return 0
	fi
	package_fullname=$package_name-$package_version 
	url=$mirror_prefix/$package_name/$package_fullname.tar.$tarball_suffix # default URL, relative to $mirror_prefix

	echo "build dependencies of $1: $build_dependencies"
	
	# installing the package's dependencies recursively
	for pkg_name in $build_dependencies
	do
		(./packageinstall.sh $pkg_name $2) || exit $?   # I initially used a recursive call to "installpackage" instead, but it was inheriting the shell local variables so this allows us to start from something cleaner
	done


	# TODO: check if the file system where we install the package is writable, otherwise the build will occur (and resources will be spent), but the installation will fail. This is especially important considering Axiom root file system is read-only
	
	# do a custom build if the package defines custombuild(), otherwise do a 
	# default build
	if type 'custombuild' 2>/dev/null | grep -q 'function'
	then custombuild
	else defaultbuild
	fi
	
	# call its postinstall() function if the package defines postinstall(), 
	# otherwise do nothing
	if type 'postinstall' 2>/dev/null | grep -q 'function'
	then postinstall
	fi
	
	# clean up by removing the build directory and the tarball
	rm -rf $package_name*
}


if [ "$2" = "user-only" ] || [ "$(id -u)" != "0" ]
then
	echo "Performing a user-only installation"
	installdirectory="$HOME/.opt"
	bindirectory="$HOME/.opt/bin/"
fi


# reinstall switch will remove existing package installation, before fresh install
# this is typically useful when one or more package dependencies were removed, and package is left broken
for arg in $@  # process all arguments
	do
		if [ "$arg" = "reinstall" ]
		then
			rm -rf $installdirectory/$package_name*
		fi
	done


installpackage $1
