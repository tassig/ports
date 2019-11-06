#!/bin/sh


VERSION=0.16

# an alternative download address is: https://downloads.sourceforge.net/opencore-amr/fdk-aac-0.1.6.tar.gz
# TODO: i am not sure what is the difference or if they are difference => investigate
git clone https://github.com/mstorsjo/fdk-aac.git

cd fdk-aac
./autogen.sh
./configure --prefix=/opt/fdk-aac-$VERSION

ncpu=`cat /proc/cpuinfo | grep processor | wc -l`
make -j$ncpu
make install



ln -svf /opt/fdk-aac-$VERSION /opt/fdk-aac
ln -svf /opt/fdk-aac/lib/pkgconfig/*.pc /opt/pkgconf/lib/pkgconfig/
