#!/bin/sh

set -ex



# requirements: sbc (from kernel.org), possibly libfilesnd

# TODO: configure script is not testing for presence of bluetooth/bluetooth.h (i'm assuming this is coming from the kernel headers)
#       the build is using a set of sanitized kernel headers that we don't have (make headers_install doesn't install that), and using the raw kernel headers doesn't work, so i'm not quite sure what to use
#       i got bluetooth related headers from debian: https://packages.debian.org/stretch/amd64/libbluetooth-dev/download
#       => either ask the author what to do, or get the set of headers in /usr/include from debian
