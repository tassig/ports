package_name=flatpak
package_version=1.4.3
tarball_suffix=xz
build_dependencies= # TODO: add in proper order

# direct requirements: 
#    glib  (ports)
#    libarchive (ports)
#    libsoup (ports)
#    libcap (ports)
#    polkit (ports)
#    libxau ( we have it with X, but we can disable it )
#    ostree  (ports)
#    fuse  (ports)
#    json-glib (ports)
#    gcab (ports) 
#    appstream-glib (ports)
#    dconf (ports)
#    libseccomp (ports, we can disaable it)
#    libxslt (ports)
#    gpgme (ports)
#    bison (ports)
#    gobject-introspection (ports)
#    Linux-PAM (ports) - who depens on it?
#
# indirect requirements:
#    gpgme requires: gnupg (ports)
#    gnupg requires: 
#       libgpg-error (ports)
#       libassuan (ports) 
#       libgcrypt (ports) 
#       libksba (ports)
#       npth (ports)
#    libarchive requres: attr (ports)
#
# TODO: bring other requirements, see https://git.alpinelinux.org/aports/tree/community/flatpak/APKBUILD as well
#




export CPPFLAGS="-I/opt/libcap/include"
export LDFLAGS="-L/opt/libcap/lib"




#./autogen.sh   # this will start configure automatically as well, but we don't want that
# NOTE: you only need to run the above if you get flatpak from git

./configure   --disable-xauth --disable-seccomp  --disable-maintainer-mode   # TODO: i'm starting by disabling non-necessary features, they can be enabled later

