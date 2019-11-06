#!/bin/sh -ex

package_name="djbdns"
package_version="1.05"
url="http://mirrors.tassig.com/dnscache/djbdns-1.05.tar.gz"

rm -rf builddir
mkdir -p builddir   # do everything in builddir for tidiness
cd builddir
wget -O archive $url
tar xvf archive
rm archive
cd *   # cd into the package directory

patch -p1 < ../../djbdns-readiness-notification.patch
sed -f ../../patch.sed Makefile > Makefile.patched
sed -i "s:extern int errno;:# include <errno.h>:g" error.h

make -f Makefile.patched dnscache

mkdir -p /opt/$package_name-$package_version/bin
cp dnscache /opt/$package_name-$package_version/bin/

ln -svf /opt/$package_name-$package_version /opt/$package_name 
ln -svf /opt/$package_name-$package_version/bin/* /bin/

cd ../..
rm -r builddir
