# Required: babl, gegl

package_name="gimp"
package_version="2.8.18"
url="http://mirrors.tassig.com/gimp/gimp-2.8.18.tar.bz2"


if [ ! -d "/opt/babl" ]; then
    sh babl.sh
fi

if [ ! -d "/opt/gegl" ]; then
    sh gegl.sh
fi



# libjpeg, libtiff and X should be done via pkgconfig TODO: fix configure.ac
export CFLAGS="-I/opt/libjpeg-turbo/include -I/opt/libtiff/include -I/opt/xorg/include" 
export LDFLAGS="-Wl,-rpath=/opt/gtk+/lib \
                -Wl,-rpath=/opt/glib/lib \
                -Wl,-rpath=/opt/pango/lib \
                -Wl,-rpath=/opt/cairo/lib \
                -Wl,-rpath=/opt/freetype/lib \
                -Wl,-rpath=/opt/fontconfig/lib \
                -Wl,-rpath=/opt/gdk-pixbuf/lib \
                -Wl,-rpath=/opt/atk/lib \
                -L/opt/libjpeg-turbo/lib -Wl,-rpath=/opt/libjpeg-turbo/lib \
                -L/opt/libtiff/lib -Wl,-rpath=/opt/libtiff/lib \
                -L/opt/xorg/lib -Wl,-rpath=/opt/xorg/lib"
                
                
# hack because of broken configure.ac
mkdir -p /usr/local/include
ln -sv /opt/libjpeg-turbo/include/* /usr/local/include/


# custom build because we do --disable-python, because it relies on PyGTK


installdirectory="/opt"


rm -rf builddir
mkdir -p builddir   # do everything in builddir for tidiness
cd builddir
wget -O archive $url
tar xvf archive 
rm archive
cd *   # cd into the package directory
package_fullname=$package_name-$package_version

./configure --disable-python --prefix=$installdirectory/$package_fullname/
make -j
make install


ln -svf $installdirectory/$package_fullname $installdirectory/$package_name
ln -svf $installdirectory/$package_name/bin/* /bin/ || true   # don't crash if the links are already there
ln -svf $installdirectory/$package_name/lib/pkgconfig/* $installdirectory/pkgconf/lib/pkgconfig/   # install pkg-config files


cd ../..
rm -r builddir



rm -r /usr



