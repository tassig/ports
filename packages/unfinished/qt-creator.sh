#!/bin/sh -ex

package_name="qt-creator"
package_version="4.6"
package_full_name=$package_name-$package_version

# qt-creator depends on: 
#  - qt (ports.git)
#  - libexecinfo (which we don't provide, we'll simply pack it with qt-creator)

# IMPORTANT NOTE: qt-creator is not able to build at tha path which contains spaces!

# NOTE: qt-creator version we can use is limited by available qt version form ports.git
#       since we currenlty provide qt-5.7.0, we are limited to use qt-creator 4.6 
#       refer to README.md file in the qt-creator source tree

# we provide way for root and regular user builds and installation
# for root user, install will take place in the /opt folder
# for any other user, install will take place in the $HOME/.opt folder
if [ `id -u` = 0 ]; then
    installdirectory="/opt"
    bindir="/bin"
else
    installdirectory="$HOME/.opt"
    bindir="$HOME/.opt/bin"
    mkdir -p $installdirectory   # make sure we have this folder
    mkdir -p $bindir             # the same
fi

# do build in the temporary folder, for tidyness
rm -rf builddir
mkdir -p builddir
cd builddir


# build libexecinfo, following qt-creator modules requires it: plugins/debugger/ and plugins/qmldesigner
# libexecinfo is normally part of glibc, and since we use musl, we'll have to use one version availabe as replacement
# NOTE: alpine linux also provide libexecinfo as an external package
# TODO: do we need it in ports?

# we won't polute Axiom and install it, we will simply use it just to build qt-creator
# NOTE: more details on how we will do it, will be given below, in the qt-creator build preparation steps
wget http://mirrors.tassig.com/libexecinfo/libexecinfo-1.1-3.tar.gz
tar xf libexecinfo-1.1-3.tar.gz
cd libexecinfo-1.1-3
make CC=gcc
cp libexecinfo.so.1 libexecinfo.so  # this is exactly what qt-creator expects, we don't need to make symlink
cd ../
libexecinfo_path=`pwd`/libexecinfo-1.1-3

# official qt-creator building procedure: 
# https://wiki.qt.io/Building_Qt_Creator_from_Git#Getting_the_source_code 

# get qt-creator sources form our mirror
wget http://mirrors.tassig.com/qt-creator/$package_full_name.tar.gz
tar xf $package_full_name.tar.gz
cd $package_full_name

# add additional include and link paths to qt-creator.pri:
sed -i '182a \  ' qtcreator.pri
sed -i "182a \QMAKE_LFLAGS += -Wl,-rpath=/opt/xorg/lib" qtcreator.pri  # avoid using LD_LIBRARY_PATH later on
sed -i "182a \LIBS += -L$libexecinfo_path" qtcreator.pri               # add link path for libexecinfo
sed -i "182a \LIBS += -lexecinfo" qtcreator.pri                        # add link flag for libexecinfo
sed -i "182a \INCLUDEPATH += /opt/xorg/include" qtcreator.pri          # fix missing include GL/gl.h
sed -i "182a \INCLUDEPATH += $libexecinfo_path" qtcreator.pri          # add include path for libexecinfo

# now follow the procedure for qt-creator building
cd ../
mkdir qt-creator-build
cd qt-creator-build
qmake ../$package_full_name/qtcreator.pro
make qmake_all

ncpu=`cat /proc/cpuinfo | grep processor | wc -l`
make -j$ncpu

make install INSTALL_ROOT="$installdirectory/$package_full_name"

# copy libexecinfo.so.1 at the standard run path of qt-creator
cp ../libexecinfo-1.1-3/libexecinfo.so.1 $installdirectory/$package_full_name/lib/qtcreator/

# make a final symlink
ln -svf $installdirectory/$package_full_name/bin/qtcreator $bindir/qtcreator || true

cd ../..
rm -rf builddir
