package_name=ls-colored
package_version=
tarball_suffix=
build_dependencies=


# Replace busybox ls, with coreutils 8.27 precompiled ls binary, to benefit text color supoort
# TIP: use aliases in .profile file
#      alias ls='ls --color'
#      alias ll='ls --color -la'

custombuild(){

	mkdir builddir
	cd builddir
	wget http://mirrors.tassig.com/coreutils/coreutils-8.27.tar.xz
	tar xvf coreutils-8.27.tar.xz
	cd coreutils-8.27

	FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/opt/coreutils-8.27  # ./configure will complain, if invoked by root
	make -j  # to build only ls, we need to invoke internal make targets for quite a few dependences, it's easier to build them all

	rm /bin/ls
	cp src/ls /bin  # replace ls with coreutils one

	cd ../..
	rm -r builddir/
}
