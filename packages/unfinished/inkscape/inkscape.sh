#!/bin/sh -xe

package_name=inkscape
package_version=0.92.3
tarball_suffix=bz2

installdirectory="/opt"   # mpv is installed globally, to /opt
mirror_prefix=http://mirrors.tassig.com
package_fullname=$package_name-$package_version 
url=$mirror_prefix/$package_name/$package_fullname.tar.$tarball_suffix


# install the following from Ports:
# - perl
# - perl-xml-paeser
# - gc
# - gsl
# - gtkmm
# - lcms
# - popt
# - python2
# - python2-lxml (required for inkscape extensions)



# install boost
if [ ! -d "/opt/boost" ]; then
	./boost.sh
fi


rm -rf builddir
mkdir -p builddir   # do everything in builddir for tidiness
cd builddir
wget -O archive $url
tar xvf archive
rm archive
cd *   # cd into the package directory


# apply patch to configure.ac
patch < ../../configure.ac.patch


# generate configure
./autogen.sh


# change FLAGS so that boost can be used (boost does not have pkgconfig)
export CXXFLAGS=-I/opt/boost/include
export CPPFLAGS=-I/opt/boost/include
export LDFLAGS=-L/opt/boost/lib


# as often, python scripts put #!/usr/bin/env python at the top, instead of simply calling python
# create /usr/bin/env
mkdir -p /usr/bin
cp /bin/env /usr/bin/


# TODO: one bug with inkjar. Can either be disabled as below, or the preprocessor variable set to the correct value ( HAVE_ZLIB_H must be defined )
./configure --prefix=$installdirectory/$package_fullname  --without-inkjar
make -j4
make install


ln -snv $installdirectory/$package_fullname $installdirectory/$package_name
ln -sv $installdirectory/$package_name/bin/* /bin/ || true   # don't crash if the links are already there

cd ../..
rm -r builddir

# clean up
rm -r /usr
