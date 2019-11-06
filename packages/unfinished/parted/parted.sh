#!/bin/sh

# Depends on ncurses from ports

set -ex

# allow static link with libparted
# still parted will be dynamically linked with libc and libuuid
if [ "$1" = "-static" ]; then
  EXTRA_FLAGS=-static
fi

mkdir build
cd build

wget http://mirrors.tassig.com/parted/parted-3.2.tar.xz
tar xvf parted-3.2.tar.xz
cd parted-3.2

CFLAGS="-I/opt/libuuid/include/" LDFLAGS="-L/opt/libuuid/lib/" ./configure --prefix=/opt/parted-3.2 --disable-device-mapper --without-readline

# parted-3.2 device-mapper is disabled but still some defines are not guarded with ifdefs
cp ../../parted-3.2.patch .
patch -p0 < parted-3.2.patch
pwd

# musl relted issue, loff_t is not provided, we have to workaround
make CFLAGS="$EXTRA_FLAGS -Dloff_t=off_t -I/opt/libuuid/include"
#make test
make install

ln -sv /opt/parted-3.2 /opt/parted
ln -sv /opt/parted/sbin/* /bin/ || true

# Clean up
cd ../..
rm -r build/



