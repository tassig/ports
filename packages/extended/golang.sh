#!/bin/sh


# TODO: merge with go.sh

# we bootstrap Go from the current release
# other option is to bootstrap from a release where Go was bootstrapped from C, as explained in the instructions: https://golang.org/doc/install/source

set -ex

# do build in the temporary folder, for tidyness
rm -rf builddir
mkdir -p builddir
cd builddir

wget https://dl.google.com/go/go1.12.5.src.tar.gz   # the sources
wget https://dl.google.com/go/go1.12.5.linux-amd64.tar.gz   # the binary, for bootstrapping purposes


tar xvf go1.12.5.linux-amd64.tar.gz
export GOROOT_BOOTSTRAP=$PWD/go

mkdir mybuild
cd mybuild
mv ../go1.12.5.src.tar.gz ./
tar xvf go1.12.5.src.tar.gz

mkdir tmpdir
export TMPDIR=$PWD/tmpdir


# as root, copy musl to another directory, go was linked with glibc but we will pretend musl is glibc (it works)
mkdir /lib64
cp /lib/ld* /lib64/
cp /lib64/ld-musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2


cd go/src
#sh all.bash   # TODO: edit, replace bash at line 13 by sh
sh make.bash   # same as above, but without the tests, which stupidly fail



# clean up
rm -rf /lib64

cd ../..
rm -rf builddir



# TODO: at that point, probably good to put it in ~/.opt/
