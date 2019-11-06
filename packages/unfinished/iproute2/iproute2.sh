#!/bin/sh -ex

package_name=iproute2
package_version=4.9.0
tarball_suffix=gz

installdirectory=/opt
mirror_prefix=http://mirrors.tassig.com
package_fullname=$package_name-$package_version 
url=$mirror_prefix/$package_name/$package_fullname.tar.$tarball_suffix

rm -rf builddir
mkdir -p builddir
cd builddir
wget -O archive $url
tar xvf archive
rm archive
cd *

# iproute2 is a dirty package, which mixes user space and kernel headers
# to make it compiile with axiom and linux, we have to apply few modifications

# 1. don't use package provided incide/linux headers, use axiom kernel headers instead
rm -r include/linux

# 2. temporarly patch kernel headers, to prevent redefinitions with user space musl headers, we'll revert it at the end
patch -p0 < ../../iproute2_kernel_headers.patch

# 3. patch Makefile install target:
#      don't install doc, requires bash 
#      don't install man
#      tipc and devlink depends on libmnl, we won't install it on Axiom for now
patch -p0 < ../../iproute2_makefile.patch

# 4 fix one source file which expexts <limits.h> to be included through other headers, which we removed in step 1
cd tc
patch -p0 < ../../../iproute2_f_matchall.c.patch
cd ../



# build and install
DESTDIR=$installdirectory/$package_fullname make install


# reverse kernel headers modification
patch -p0 -R < ../../iproute2_kernel_headers.patch


# standard axiom procedure to install and symlink executables
ln -snv $installdirectory/$package_fullname $installdirectory/$package_name
ln -sv $installdirectory/$package_name/sbin/* /bin/ || true   # don't crash if the links are already there
if [ -d "$installdirectory/$package_name/lib/pkgconfig" ]; then
	ln -svf $installdirectory/$package_name/lib/pkgconfig/* \
	$installdirectory/pkgconf/lib/pkgconfig/ 
fi


cd ../..
rm -r builddir
