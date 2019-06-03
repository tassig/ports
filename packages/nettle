package_name=nettle
package_version=3.4.1
tarball_suffix=gz
build_dependencies="gmp"

# TODO: temporary hack, use custombuild instead
# gmp does not have pkg-config support
# nettle does not handle -rpath well
export CFLAGS=-I/opt/gmp/include
export LDFLAGS="-L/opt/gmp/lib -Wl,-rpath=/opt/gmp/lib"
