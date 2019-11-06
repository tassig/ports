

# NOTE: problem with ncurses, not using pkg-config

export CPPFLAGS="-I/opt/ncurses/include"
export LDFLAGS="-L/opt/ncurses/lib \
                -Wl,-rpath=/opt/xorg/lib \
                -Wl,-rpath=/opt/ncurses/lib"


# TODO: some -rpath are needed during compilation to remove the need for this
export LD_LIBRARY_PATH="/opt/libpng/lib:/opt/pango/lib:/opt/glib/lib:/opt/dbus/lib:/opt/cairo/lib:/opt/freetype/lib:/opt/libasound/lib:/opt/atk/lib:/opt/gnutls/lib:/opt/fontconfig/lib:/opt/gtk+/lib/:/opt/alsa-lib/lib:/opt/gdk-pixbuf/lib:/opt/libxml2/lib"

# NOTE: i removed jpeg, gif, tiff, not because it's that hard to find by configure, but i wasn't sure if it's useful
./configure --prefix=/opt/emacs --x-includes=/opt/xorg/include --x-libraries=/opt/xorg/lib  --with-jpeg=no --with-gif=no --with-tiff=no


ncpu=`cat /proc/cpuinfo | grep processor | wc -l`
make -j$ncpu


make install


