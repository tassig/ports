#!/bin/sh

# Depends on ncurses from ports

set -e

mkdir build
cd build

wget http://mirrors.tassig.com/vim/vim-7.4.tar.bz2
tar xvf vim-7.4.tar.bz2
cd vim74

LDFLAGS="-Wl,-rpath=/opt/ncurses/lib -L/opt/ncurses/lib -Wl,-rpath=/opt/xorg/lib,-rpath=/opt/gtk+/lib,-rpath=/opt/gdk-pixbuf/lib,-rpath=/opt/glib/lib,-rpath=/opt/fontconfig/lib,-rpath=/opt/freetype/lib,-rpath=/opt/atk/lib,-rpath=/opt/pango/lib:,-rpath=/opt/cairo/lib" ./configure --prefix=/opt/vim-7.4 --x-includes=/opt/xorg/include  --x-libraries=/opt/xorg/lib # buggy configure tests for ncurses, not using pkgconfig, the rest are -rpath, they are also propagated to the final executables
make -j4
#make test
make install

ln -sv /opt/vim-7.4 /opt/vim
ln -sv /opt/vim/bin/* /bin/ || true

# Clean up
cd ../..
rm -r build/


# run with:
# gvim


