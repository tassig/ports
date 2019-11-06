#!/bin/sh

set -ex

package_fullname=$package_name-$package_version
url=http://mirrors.tassig.com/$package_name/$package_fullname.tar.$tarball_suffix
installdirectory=$HOME/.opt
BUILD_DIR=$HOME/.work

if [ "$HOME" == "/root" ]; then
	# we need room, so use /home/work instead
	BUILD_DIR=/home/work
	installdirectory=/opt
fi

ACTION=$1

function premake(){
	./configure --prefix=$installdirectory/$package_name-$package_version
}

function domake(){
	ncpu=`cat /proc/cpuinfo | grep processor | wc -l`
	make -j$ncpu
}

function dotest(){
	if test -z $no_check
	then make -j check || make -j test
	fi
}

function doinstall(){
	make install
}

function postinstall(){
	touch $installdirectory/$package_name-$package_version/installed
	ln -svf "$installdirectory/$package_fullname" "$installdirectory/$package_name"
	if [ -d "$installdirectory/$package_name/lib/pkgconfig" ]; then
		ln -svf $installdirectory/$package_name/lib/pkgconfig/* \
		/opt/pkgconf/lib/pkgconfig/ || true  # install pkg-config files
	fi
	if [ "$HOME" == "/root" ]; then
		ln -svf "$installdirectory/$package_name/bin"/* /bin/
	else
		ln -svf "$installdirectory/$package_name/bin"/* "$installdirectory/bin/"
	fi
}

function install_ports_deps(){
	if [ "$ports_build_dependencies" == "" ]; then
		return
	fi
	local START_DIR=`pwd`
	rm -rf "$BUILD_DIR"
	mkdir -p "$BUILD_DIR"
	cd "$BUILD_DIR"

	GIT_SSH_COMMAND="ssh -y" sshpass -p "temppassrobotbuilder" git clone ssh://robotbuilder@git.cacaoweb.org/../var/git/ports.git
	cd ports

	for pkg_name in $ports_build_dependencies
	do
		(./packageinstall.sh $pkg_name) || exit $?
	done

	cd ..
	rm -rf ports
	cd "$START_DIR"
}

function install_deps(){
	if [ "$build_dependencies" == "" ]; then
		return
	fi
	for pkg_name in $build_dependencies
	do
		(./${pkg_name}.sh install) || exit $?
	done
}

function install(){
	[ -e "$installdirectory/$package_name-$package_version/installed" ] && {
		echo "$package_name is already installed"
		exit 0
	}

	install_ports_deps
	install_deps
	local START_DIR=`pwd`

	rm -rf "$BUILD_DIR"
	mkdir -p "$BUILD_DIR"
	cd "$BUILD_DIR"

	wget -O archive $url
	tar xvf archive
	rm archive

	cd *
	premake
	domake
	doinstall
	postinstall
	cd "$START_DIR"
}

function clean(){
	rm -rf $BUILD_DIR
}

function remove(){
	rm -rf $installdirectory/$package_name-$package_version
}

function main()
{
	case $ACTION in
		installportsdeps)
			install_ports_deps
		;;
		install)
			install
      clean
		;;
		remove)
			remove
		;;
		clean)
			clean
		;;
		*)
        echo "$0 <install|remove>"
		;;
	esac
}
