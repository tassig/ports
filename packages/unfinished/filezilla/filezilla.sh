# depends on:
# - nettle (in ports.git)
# - wxwidgets (in hutchr.git)
# - libidn (in ports.git)
# - gnutls (in ports.git)
# - sqlite3 : install from https://www.sqlite.org/2019/sqlite-autoconf-3290000.tar.gz (download page of sqlite). TODO: this is a straighforward install and sqlite is an important software so it can be added to ports.git

set -ex


# NOTE: initially i also patched configure.ac (and then run autoreconf) to remove the check for wxwidgets 3.0. We have 3.1 and it works fine, so i think this check if overkill and we can simply remove it
#       alternative is to simply use wxWidgets 3.0.4


# TODO: this is needed during the build, but it could probably be fixed by adding the -rpath instead, which is cleaner
export LD_LIBRARY_PATH="/opt/wxwidgets/lib"


package_name=FileZilla
package_version=3.42.1
tarball_suffix=bz2
ports_build_dependencies="gnutls nettle libidn sqlite"
build_dependencies="libfilezilla"

source ./include.sh

url=http://mirrors.tassig.com/$package_name/${package_name}_${package_version}_src.tar.$tarball_suffix

function premake(){
    # TODO: should work with just CPPFLAGS, and CFLAGS shouldn't be needed
    LDFLAGS="-L/opt/libidn/lib -Wl,-rpath,/opt/libidn/lib \
            -L/opt/gnutls/lib -Wl,-rpath,/opt/gnutls/lib \
            -L/opt/xorg/lib -Wl,-rpath,/opt/xorg/lib \
            -L/opt/nettle/lib -Wl,-rpath,/opt/nettle/lib \
            -L/opt/wxWidgets/lib -Wl,-rpath,/opt/wxWidgets/lib \
            " \
    CFLAGS="-I/opt/libidn/include \
           -I/opt/gnutls/include \
           " \
    CPPFLAGS="$CFLAGS" \
           ./configure --prefix=$installdirectory/$package_name-$package_version \
           --with-pugixml=builtin \
           --without-dbus
}

# install the wxWidgets dependency first
cd ../wxWidgets
./wxWidgets.sh install
cd ../filezilla



main
