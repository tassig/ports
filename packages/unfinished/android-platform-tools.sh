package_name=android-platform-tools
package_version=29.0.5
tarball_suffix=gz
build_dependencies="go"

set -e

# TODO: should we put those on our mirror?

function custombuild(){
    PORTS_DIR=$PWD
	  builddir="builddir-$package_fullname"  # build directory is "builddir" followed by the name of the package, which allows multiple builds of different software in parallel
    mkdir -p $builddir
    cd $builddir

    if [ ! -e "build/prepared" ]; then
        rm -rf build
        git clone https://android.googlesource.com/platform/build
        cd build
        git checkout platform-tools-$package_version

        # now apply any patches, belonging to build-only
        for patch in $(find $PORTS_DIR/packages/extended/$package_name/ -name 'build*.patch'); do
            patch -p1 < $patch
        done
        # create mark
        touch prepared
    else
        # build had been cloned and patched, just navigate there and check the rest
        cd build
    fi

    if [ ! -e "blueprint/prepared" ]; then
        rm -rf blueprint
        git clone https://android.googlesource.com/platform/build/blueprint
        cd blueprint
        git checkout platform-tools-$package_version
        # now apply any patches, belonging to build-only
        for patch in $(find $PORTS_DIR/packages/extended/$package_name/ -name 'blueprint*.patch'); do
            patch -p1 < $patch
        done
        # create mark
        touch prepared
        cd ..
    fi
    if [ ! -e "soong/prepared" ]; then
        rm -rf soong
        git clone https://android.googlesource.com/platform/build/soong
        cd soong
        git checkout platform-tools-$package_version
        # now apply any patches, belonging to build-only
        for patch in $(find $PORTS_DIR/packages/extended/$package_name/ -name 'soong*.patch'); do
            patch -p1 < $patch
        done
        # create mark
        touch prepared
        cd ..
    fi

    if [ ! -e "kati/prepared" ]; then
        rm -rf kati
        git clone https://android.googlesource.com/platform/build/kati
        cd kati
        git checkout platform-tools-$package_version
        # now apply any patches, belonging to build-only
        for patch in $(find $PORTS_DIR/packages/extended/$package_name/ -name 'kati*.patch'); do
            patch -p1 < $patch
        done
        make
        # create mark
        touch prepared
        cd ..
    fi
    if [ ! -e "make/prepared" ]; then
        rm -rf make
        git clone https://android.googlesource.com/platform/build/make
        cd make
        git checkout platform-tools-$package_version
        # now apply any patches, belonging to build-only
        for patch in $(find $PORTS_DIR/packages/extended/$package_name/ -name 'make*.patch'); do
            patch -p1 < $patch
        done
        make
        # create mark
        touch prepared
        cd ..
    fi

    cd ..
    mkdir -p packages
    cd packages
    if [ -e "modules/vndk/prepared" ]; then
        rm -rf modules/vndk
        mkdir -p modules
        cd modules
        git clone https://android.googlesource.com/platform/packages/modules/vndk
        cd vndk
        git checkout platform-tools-$package_version
        # now apply any patches, belonging to build-only
        for patch in $(find $PORTS_DIR/packages/extended/$package_name/ -name 'packages-modules-vndk*.patch'); do
            patch -p1 < $patch
        done
        exit 1
        touch prepared
        cd ../..
    fi
    cd ..

    if [ ! -e "sdk/prepared" ]; then
        rm -rf sdk
        mkdir -p sdk
        git clone https://android.googlesource.com/platform/sdk
        cd sdk
        git checkout platform-tools-$package_version
        # now apply any patches
        for patch in $(find $PORTS_DIR/packages/extended/$package_name/ -name 'sdk*.patch'); do
            patch -p1 < $patch
        done
        touch prepared
        cd ..
    fi

    if [ ! -e "development/prepared" ]; then
        rm -rf development
        mkdir -p development
        git clone https://android.googlesource.com/platform/development
        cd development
        git checkout platform-tools-$package_version
        # now apply any patches
        for patch in $(find $PORTS_DIR/packages/extended/$package_name/ -name 'development*.patch'); do
            patch -p1 < $patch
        done
        touch prepared
        cd ..
    fi

    mkdir -p external
    cd external

    if [ ! -e "golang-protobuf/prepared" ]; then
        rm -rf golang-protobuf
        git clone https://android.googlesource.com/platform/external/golang-protobuf
        cd golang-protobuf
        git checkout platform-tools-$package_version
        # now apply any patches, belonging to build-only
        for patch in $(find $PORTS_DIR/packages/extended/$package_name/ -name 'golang*.patch'); do
            patch -p1 < $patch
        done
        # create mark
        touch prepared
        cd ..
    fi

    if [ ! -e "ninja/prepared" ]; then
        rm -rf ninja
        # soong needs customized version of ninja
        git clone https://android.googlesource.com/platform/external/ninja
        cd ninja
        # now apply any patches, belonging to build-only
        for patch in $(find $PORTS_DIR/packages/extended/$package_name/ -name 'ninja*.patch'); do
            patch -p1 < $patch
        done
	      python configure.py --bootstrap
        # create mark
        touch prepared
        cd ..
    fi

    cd ..

    mkdir -p prebuilts
    cd prebuilts

    if [ ! -e "go/prepared" ]; then
        rm -rf go
        mkdir -p go
        ln -s $installdirectory/go/ go/linux-x86
        touch go/prepared
    fi

    if [ ! -e "build-tools/prepared" ]; then
        rm -rf build-tools
        mkdir -p build-tools/linux-x86/bin
        ln -s $PORTS_DIR/$builddir/external/ninja/ninja build-tools/linux-x86/bin/
        ln -s $PORTS_DIR/$builddir/build/kati/ckati build-tools/linux-x86/bin/

        # now place prepared flag, so at the next iteration, you will not need to refetch everything again (in case of building issue)
        touch build-tools/prepared
    fi
    cd ..


    cd build/soong

    sh -ex ./soong_ui.bash --make-mode --skip-make

}
