

# see https://git.alpinelinux.org/aports/tree/main/gnupg
#
# requirements (in order): libgpg-error
#                          libassuan
#                          libgcrypt
#                          libksba
#                          npth
#                          sqlite (from ports.git, but i think it's optional)
#                          gnutls (from ports.git)


export CPPFLAGS="-I/opt/libgcrypt/include"
export LDFLAGS="-Wl,-rpath=/opt/libksba/lib -Wl,-rpath=/opt/libgcrypt/lib -Wl,-rpath=/opt/libgpg-error/lib -Wl,-rpath=/opt/libassuan/lib  -Wl,-rpath=/opt/npth/lib -Wl,-rpath=/opt/sqlite/lib"


# => then ./configure


# NOTE: add both bin/* and sbin/*
