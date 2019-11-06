#!/bin/sh

# nodejs is a platform for running "serverside" JavaScript code.
# custom build is needed to make build in a /home/work dir, where there is enough space for it

set -ex

package_name=node
package_version=v6.10.2
url=http://mirrors.tassig.com/node/$package_name-$package_version.tar.gz
no_check=1


installdirectory="/opt"

STARTPWD=`pwd`
BUILDDIR=/home/work/node

rm -rf $BUILDDIR
mkdir -p $BUILDDIR   # do everything in builddir for tidiness
cd $BUILDDIR
wget -O archive $url
tar xvf archive 
rm archive
cd *   # cd into the package directory
package_fullname=$package_name-$package_version

ncpu=`cat /proc/cpuinfo | grep processor | wc -l`

./configure --prefix=$installdirectory/$package_fullname/
make -j$ncpu 
if test -z $no_check
then make check
fi
make install

ln -svf $installdirectory/$package_fullname $installdirectory/$package_name
ln -svf $installdirectory/$package_name/bin/* /bin/ || true   # don't crash if the links are already there
if [ -d "$installdirectory/$package_name/lib/pkgconfig" ]; then
	ln -svf $installdirectory/$package_name/lib/pkgconfig/* $installdirectory/pkgconf/lib/pkgconfig/   # install pkg-config files
fi
if [ -d "$installdirectory/$package_name/share/pkgconfig" ]; then
	ln -svf $installdirectory/$package_name/share/pkgconfig/* $installdirectory/pkgconf/lib/pkgconfig/   # install pkg-config files
fi

cd $STARTPWD
rm -rf $BUILDDIR


