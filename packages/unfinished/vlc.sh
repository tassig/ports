
set -ex


rm -rf builddir
mkdir -p builddir   # do everything in builddir for tidiness
cd builddir

wget http://mirrors.tassig.com/vlc/vlc-2.2.4.tar.xz
tar xvf vlc-2.2.4.tar.xz
cd vlc-2.2.4

./configure --prefix=/opt/vlc --disable-lua --disable-mad --disable-avcodec --disable-a52 --disable-libgcrypt
make -j

# TODO: compilation fails
