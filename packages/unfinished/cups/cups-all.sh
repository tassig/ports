#!/bin/sh -e

package_name=cups-all
ports_build_dependencies=""
build_dependencies="cups cups-filters splix cndrvcups-capt"

BUILD_DIR=/home/work/

ACTION=$1

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
		(./$pkg_name.sh install) || exit $?
	done
}

function install(){
	[ -e "$installdirectory/$package_name" ] && {
		echo "$package_name is already installed"
		exit 0
	}

	install_ports_deps
	install_deps
}

#this function will remove all cups-related directories. This is needed
# until we decide, that cups is robust enough to be included in base
# system and we will increase rootfs size, because it uses ~500MB and
# nightly builds are struggrling due to lack of free space for build image
function cleandeps(){
	local deps="cndrv ghostscript lcms2 libiconv libopenjp2 mupdf poppler qpdf splix"
	for dep in $deps
	do
		rm -rf "/opt/$dep"*
	done
}

case $ACTION in
	install)
		install
	;;
	remove)
		remove
	;;
	cleandeps)
		cleandeps
	;;
	*)
		echo "$0 <install|remove|cleandeps>"
	;;
esac







