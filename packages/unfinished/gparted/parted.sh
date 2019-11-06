package_name="parted"
package_version="3.2"
package_url="https://ftp.gnu.org/gnu/parted/parted-3.2.tar.xz"

# dependencies: libuuid


rm -rf builddir
mkdir -p builddir   # do everything in builddir for tidiness
cd builddir
wget -O archive $package_url
tar xvf archive
rm archive
cd *   # cd into the package directory



CXXFLAGS="-I/opt/libuuid/include" LDFLAGS="-L/opt/libuuid/lib -Wl,-rpath=/opt/libuuid/lib" ./configure --prefix=/opt/parted --disable-device-mapper --without-readline
ncpu=`cat /proc/cpuinfo | grep processor | wc -l`
make -j$ncpu

# TODO: fails because it requires lvm2


if test -z $no_check
then make check
fi
make install



cd ../..
rm -r builddir
