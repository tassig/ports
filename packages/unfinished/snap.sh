#!/bin/sh


set -ex


# dependencies: 
# * Go, installed with golang.sh in hutchr.git
# * libseccomp TODO: seems that version 2.3.3 is needed, or maybe not (available in ports.git)
# * xfsprogs source distribution (don't think you need to compile) (available in hutchr.git)


export GOPATH=${HOME}/work
export PATH="$PATH:$GOPATH/bin"

rm -rf $GOPATH
mkdir -p $GOPATH


# then, follow instructions at https://github.com/snapcore/snapd/blob/master/HACKING.md

go get -d -v github.com/snapcore/snapd/...

go get -u github.com/kardianos/govendor

govendor sync

go install github.com/snapcore/snapd/cmd/snap/...

go install github.com/snapcore/snapd/cmd/snapd/...


# not mentioned in the instructions, but if you don't do it there is an error message:
go install github.com/snapcore/snapd/cmd/snap-seccomp
# TODO: fails with cmd/snap-seccomp/main.go:55:21: fatal error: xfs/xqm.h: No such file or directory
# -> solution:
# change main.go with the following (that's how you change CFLAGS and LDFLAGS in go):
#//#cgo CFLAGS: -D_FILE_OFFSET_BITS=64 -I/home/jerry/xfsprogs-5.0.0/include -I/opt/libuuid/include
#//#cgo pkg-config: libseccomp
#//#cgo LDFLAGS: -Wl,-rpath=/opt/libseccomp/lib


./run-checks   # TODO: patch mdlint.py with correct location of python3
               # fails with seemingly strange errors, not worth our time fixing


# TODO: problem with the build-id of the executables
#       on redhat, build ids have size 20
#       but on axiom, they have size 0x53, can see with readelf -n snapd
#       that's not something snapd is happy with, and i can't really explain what's going on since i'm not familar with build-id
#
#       => easy solution is to pretend the build-id is fine, even if it's not
#          to do that, simply comment out the lines 74-76 in snapcore/snapd/sandbox/seccomp/compiler.go

# TODO: also install unsquashfs from https://sourceforge.net/projects/squashfs/




