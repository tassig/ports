package_name="gftp"
package_version="2.0.19"
url="https://www.gftp.org/gftp-2.0.19.tar.gz"

export LDFLAGS="-Wl,-rpath=/opt/gtk+/lib \
                -Wl,-rpath=/opt/glib/lib \
                -Wl,-rpath=/opt/pango/lib \
                -Wl,-rpath=/opt/cairo/lib \
                -Wl,-rpath=/opt/freetype/lib \
                -Wl,-rpath=/opt/fontconfig/lib \
                -Wl,-rpath=/opt/gdk-pixbuf/lib \
                -Wl,-rpath=/opt/atk/lib"
                
source "defaultbuild.sh"

# TODO: fails because of MAXNAMLEN undefined, you just have to define it
