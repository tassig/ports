package_name=glib-networking
package_version=2.48.2
tarball_suffix=xz
build_dependencies="gnutls"
no_check=1

export LDFLAGS="-Wl,-rpath=/opt/glib/lib"

# NOTE: the modules are installed in /opt/glib/

