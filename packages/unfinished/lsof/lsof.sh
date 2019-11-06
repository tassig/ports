#!/bin/sh -ex

package_name=lsof
package_version=4.91
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
ls -la

# NOTE: although we have to do some interestiing steps to build lsof, 
#       it's quite clean installtion, we just correct one wrong assumption about system header file


# lsof holds sources archived, and with sig file, to be used for pgp verificatiion
# we don't care
ARCHIVE="$package_name"_"$package_version"_src
tar xvf $ARCHIVE.tar
cd $ARCHIVE

# lsof expects __GLIBC__ or __UCLIBC__ while trying to detect system C library, and in absence of  these macro's it will make wrong assumptions
# musl don't provide such macro, as it considers it a bug, and that packages shall test features, rather than relying on macros

# luckily, ony one wrong assumtion was made, and it's easy to correct:
# in case of __GLIBC__ and __UCLIBC__ it will include <netinet/tcp.h>, and for other C libraries it will include <linux/tcp.h>
# musl do provide <netinet/tcp.h>, so we modify part of the code where this assumtion was made
cd dialects/linux/
chmod 644 dlsof.h # lsof comes with 444 default file permissions, we need to patch one of them
patch -p0 < ../../../../../lsof_dlsof.h.patch
cd ../../

# losf configure loves to ask questions, by calling customization scripts
# we will simply make them dummy to prevent errors, other way around was to patch Confifure
chmod +w Inventory Customize
echo "#!/bin/sh" > Inventory
echo "#!/bin/sh" > Customize

./Configure linux
make CC=gcc


# lsof policy is that everyone shall implement it's own installation procedure
# it's fine, we just need lsof binary, but then we can install static library too
mkdir -p /opt/$package_fullname/bin
cp lsof /opt/$package_fullname/bin
 
mkdir -p /opt/$package_fullname/lib
cp lib/liblsof.a /opt/$package_fullname/lib

ln -snv $installdirectory/$package_fullname $installdirectory/$package_name

# axiom has default lsof via busybox, so we have to remove it
ln -sfv $installdirectory/$package_name/bin/* /bin/

cd ../../../
rm -r builddir
