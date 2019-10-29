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
installdirectory="/opt"   # default value for global installs, if the "user-only" argument is specified in $2, installdirectory becomes ~/.opt instead
bindirectory="/bin/"   # default value for global installs, if the "user-only" argument is specified in $2, becomes ~/.opt/bin/ isntead
mirror_prefix=http://mirrors.tassig.com   # a place to download tarballs

# the function called by default to build a package
# if "custombuild()" is defined, it will be used instead of this function
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
	# NOTE: .m4 files should probably be installed as well by default, but i have no strong opinion on it, so for now we leave this to the postinstall() function
	cd ../..
	rm -r $builddir
}

installpackage(){
	echo "installing package $1"

	# sourcing package installer shell script, we have two types of packages:
	# - base packages in $packagedirectory, where each package is a single file - shell script with name $1
	# - extended packages in $packagedirectory/extended, where package is a shell script with name $1.sh
	# See "introduction to ports.md", which is the documentation
	if [ ! -f $packagedirectory/$1 ]; then
		source $packagedirectory/extended/$1.sh
	else
		source $packagedirectory/$1   # TODO: this file might not exist, exit with an error message
	fi

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
	
	# do a custom build if the package defines custombuild(), otherwise do a default build
	if type 'custombuild' 2>/dev/null | grep -q 'function'
	then custombuild
	else defaultbuild
	fi
	
	# call its postinstall() function if the package defines postinstall(), otherwise do nothing
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

# process all arguments
for arg in $@
	do
	
		# reinstall switch will remove existing package installation, before fresh install
		# this is typically useful when one or more package dependencies were removed, and package is left broken
		if [ "$arg" = "reinstall" ]
		then
			echo "Removing previous installation"
			rm -rf $installdirectory/$package_name*
		fi
		
	done


installpackage $1
