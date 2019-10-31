package_name=glib-networking
package_version=2.48.2
tarball_suffix=xz
build_dependencies="gnutls"
no_check=1

export LDFLAGS="-Wl,-rpath=/opt/glib/lib -Wl,-rpath=/opt/nettle/lib"

# NOTE: the modules are installed in /opt/glib/
# NOTE: some issue with nettle rpath missing at runtime, which is a bit abnormal because nettle should be a dependency of gnutls, not a direct dependency of this glib module

