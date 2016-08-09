#!/bin/sh

# usage: ./packageinstall.sh package_identifier
# example: ./packageinstall.sh autoconf
# the script is assuming you're running it in the ports directory (which is a bit stupid, need to be changed later)
# refer to "package definition specifications.md" for laws and regulations
#
# TODO: installpackage() should be a transaction to prevent half-installed packages and leftovers. ex: what do you do when "make install" returns an error? right now, we do nothing, which is incorrect
# TODO: make all url relative to mirrors.tassig.com. dambaev: added support of relative urls.

# version 1.1
#
# history
# - 1.1: Aug 09 2016 dambaev <ice.redmine@gmail.com> 
#        added support of relative urls by expecting rel_url to be suffix to "http://mirrors.tassig.com/" url iff
#        there is no url defined
# - 1.0 initial version

set -e

packagedirectory=packages   # the directory name where the packages definitions are located

installdirectory="/opt"   # TODO: implement per user installs (with different --prefix)

mirror_prefix=http://mirrors.tassig.com # this is for relative URLs. If $url is empty, then 
                                        # url=$mirror_prefix/$rel_url

# the function called by default to build a package, works for most packages
defaultbuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
    if [ "$url" == "" ]; then
        # if no absolute $url defined, then assume, that we have relative url $rel_url
        url=$mirror_prefix/$rel_url
    fi
	wget -O archive $url
	tar xvf archive 
	rm archive
	cd *   # cd into the package directory
	package_fullname=$package_name-$package_version # TODO: PROPOSAL: we can move that difinition to installpackage.It can be used to form default relative rel_url=$package_name-$package_version.tar.$package_suffix. This allows to get rid of defining simple urls in ports
	./configure --prefix=$installdirectory/$package_fullname/
	make -j
	if test -z $no_check   # run the make check, unless $no_check is set for this package definition
	then make -j check || make -j test
	fi
	make install
	ln -sv $installdirectory/$package_fullname $installdirectory/$package_name
	ln -sv $installdirectory/$package_name/bin/* /bin/ || true   # don't crash if the links are already there
	if [ -d "$installdirectory/$package_name/lib/pkgconfig" ]; then
		ln -svf $installdirectory/$package_name/lib/pkgconfig/* $installdirectory/pkgconf/lib/pkgconfig/   # install pkg-config files
	fi
	cd ../..
	rm -r builddir
}


installpackage(){
	echo "installing package $1"

	source $packagedirectory/$1
	
	if [ -d "$installdirectory/$package_name-$package_version" ]; then
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
	rm -rf $package_name*
	
}


installpackage $1
