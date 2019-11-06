package_name=libfilezilla
package_version=0.16.0
tarball_suffix=bz2
ports_build_dependencies="nettle gmp"

source ./include.sh

function premake(){
    CPPFLAGS="-I/opt/gmp/include" \
    CFLAGS="-I/opt/gmp/include" \
    LDFLAGS="-L/opt/gmp/lib -Wl,-rpath,/opt/gmp/lib \
            -L/opt/nettle/lib -Wl,-rpath,/opt/nettle/lib \
            " \
           ./configure --prefix=$installdirectory/$package_name-$package_version
}

main
