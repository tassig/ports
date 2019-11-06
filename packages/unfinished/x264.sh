#!/bin/sh

set -ex


VERSION=latest

# TODO: install bash

mkdir -p builddir
cd builddir


# x264 configure script is written in bash, or rather, written by people who don't know anything else than bash, so there are some unintentional bash-isms
git clone http://git.videolan.org/git/x264.git

cd x264
# i added --disable-asm, i'm sure we could install nasm, but i'm also pretty sure that the people who wrote x264 are not better than GCC at generating assembly, so their "optimizations" are most likely overkill
./configure --prefix=/opt/x264-latest --disable-asm --enable-shared --enable-static

ncpu=`cat /proc/cpuinfo | grep processor | wc -l`
make -j$ncpu
make install

cp x264.pc /opt/x264-$VERSION/

ln -svf /opt/x264-$VERSION /opt/x264
ln -svf /opt/x264/bin/* /bin/
ln -svf /opt/x264/lib/pkgconfig/*.pc /opt/pkgconf/lib/pkgconfig/




# TODO: remove bash
#rm -r /opt/bash*
