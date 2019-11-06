package_name="mplayer-vaapi"
package_version="1.3.0"


# TODO: mplayer probably needs yasm (from ports.git) to build ffmpeg


set -ex

installdirectory="/opt"


rm -rf builddir
mkdir -p builddir   # do everything in builddir for tidiness
cd builddir
# we download the mplayer-vaapi variant, to have vaapi support
GIT_SSL_NO_VERIFY=true git clone https://github.com/gbeauchesne/mplayer-vaapi
cd mplayer-vaapi

package_fullname=$package_name-$package_version


# get ffmpeg
#git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg
# mplayer needs checkout bc63a760837c8b173f2a3820ccb06f9cac1c07b4 of ffmpeg

# you have to type Enter to continue the build (this is stupid)

# this configure script is not autoconf generated, and it's not using pkg-config for certain things, so we have to be extra careful
./configure --prefix=$installdirectory/$package_fullname --extra-cflags="-I/opt/xorg/include" --extra-ldflags="-L/opt/xorg/lib"
export LDFLAGS="-Wl,-rpath=/opt/xorg/lib -Wl,-rpath=/opt/freetype/lib -Wl,-rpath=/opt/fontconfig/lib"
make -j   # TODO: should be adjusted to the number of cores on the machine, otherwise it uses more memory than it can really process
make install

ln -svf $installdirectory/$package_fullname $installdirectory/$package_name
ln -svf $installdirectory/$package_name/bin/* /bin/ || true   # don't crash if the links are already there

cd ../..
rm -r builddir


# TODO: i had a build crash, but then i restarted make, and did not have a crash... i did not investigate, mplayer worked fine
