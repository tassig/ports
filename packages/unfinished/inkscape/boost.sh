#!/bin/sh -xe


wget https://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.tar.bz2
tar xvf boost_1_68_0.tar.bz2
cd boost_1_68_0



./bootstrap.sh --prefix=/opt/boost

# NOTE: i'm not sure if this is the right way, please fix if not
./b2 -j4   # TODO: this will crash, but we can install anyway: boost doesn't have a very good build system
./b2 install


# at the end, i don't really know if boost is properly installed or not
# at least, it worked for inkscape
# TODO: it seems to be missing python libraries

