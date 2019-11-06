#!/bin/sh

set -ex


#TODO
#configure: libGLU 64-bit development files not found, GLU won't be supported.
#configure: libOSMesa 64-bit development files not found (or too old), OpenGL rendering in bitmaps won't be supported.
#configure: OpenCL 64-bit development files not found, OpenCL won't be supported.
#configure: pcap 64-bit development files not found, wpcap won't be supported.
#configure: libdbus 64-bit development files not found, no dynamic device support.
#configure: lib(n)curses 64-bit development files not found, curses won't be supported.
#configure: libsane 64-bit development files not found, scanners won't be supported.
#configure: libv4l 64-bit development files not found.
#configure: libgphoto2 64-bit development files not found, digital cameras won't be supported.
#configure: libgphoto2_port 64-bit development files not found, digital cameras won't be auto-detected.
#configure: liblcms2 64-bit development files not found, Color Management won't be supported.
#configure: libz 64-bit development files not found, data compression won't be supported.
#configure: libpulse 64-bit development files not found or too old, Pulse won't be supported.
#configure: OSS sound system found but too old (OSSv4 needed), OSS won't be supported.
#configure: libcapi20 64-bit development files not found, ISDN won't be supported.
#configure: libcups 64-bit development files not found, CUPS won't be supported.
#configure: libgsm 64-bit development files not found, gsm 06.10 codec won't be supported.
#configure: libmpg123 64-bit development files not found (or too old), mp3 codec won't be supported.
#configure: libopenal 64-bit development files not found (or too old), OpenAL won't be supported
#configure: openal-soft 64-bit development files not found (or too old), XAudio2 won't be supported
#configure: libldap (OpenLDAP) 64-bit development files not found, LDAP won't be supported.

#configure: WARNING: libxslt 64-bit development files not found, xslt won't be supported.

#configure: WARNING: libgnutls 64-bit development files not found, no schannel support.

#configure: WARNING: libjpeg 64-bit development files not found, JPEG won't be supported.

#configure: WARNING: No sound system was found. Windows applications will be silent.


# TODO: most of the warnings above make little sense, or are useless. For example, i don't know what something like "JPEG won't be supported". Wine is supposed to be a Windows API emulator, it has nothing to do with JPEG.


rm -rf builddir
mkdir -p builddir   # do everything in builddir for tidiness
cd builddir

git clone git://source.winehq.org/git/wine.git

cd wine

#patch configure for X
patch -p0 < ../../wine-xorg.patch

export LD_LIBRARY_PATH="/opt/freetype/lib"

./configure --prefix=/opt/wine --without-gstreamer --enable-win64
ncpu=`cat /proc/cpuinfo | grep processor | wc -l`
make -j$ncpu
make install

ln -sv /opt/wine/bin/* /bin/

cd ../..
rm -r builddir
