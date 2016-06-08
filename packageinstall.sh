#!/bin/sh

# TODO: it would be better if we were running everything with set -e, but the whole thing has to be tested... so for now i just put some " || exit $?" and " || true" here and there
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
	set -e
	package_fullname=$package_name-$package_version
	wget -O archive $url
	tar xvf archive
	rm archive
	cd $package_name*
	CFLAGS=$configure_cflags LDFLAGS=$configure_ldflags ./configure --prefix=/opt/$package_fullname/ $configure_string
	make -j
	make install
	ln -sv /opt/$package_fullname /opt/$package_name
	ln -sv /opt/$package_name/bin/* /bin/ || true   # don't crash if the links are already there
	if [ -d "/opt/$package_name/lib/pkgconfig" ]; then
		ln -svf /opt/$package_name/lib/pkgconfig/* /opt/pkgconf/lib/pkgconfig/   # install pkg-config files
	fi  
	cd ..
	set +e
}


installpackage(){
	echo "installing package $1"

	# TODO: at this point of the script, these variables are always undefined, so the following is useless
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
		(./packageinstall.sh $pkg_name) || exit $?   # i initially used a recursive call to "installpackage" instead, but it was inheriting the shell variables
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
	# TODO: only if $package_name is defined
	rm -rf $package_name*
	
}


installpackage $1
