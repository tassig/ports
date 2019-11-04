package_name=android-platform-tools
package_version=29.0.5
tarball_suffix=gz
build_dependencies="go"

# TODO: should we put those on our mirror?

function custombuild(){
    PORTS_DIR=$PWD
	  builddir="builddir-$package_fullname"  # build directory is "builddir" followed by the name of the package, which allows multiple builds of different software in parallel
    if [ -d "$builddir" ]; then
        cd $builddir/build/soong
    else
        mkdir -p $builddir
        cd $builddir

        # mkdir build
        git clone https://android.googlesource.com/platform/build
        git checkout platform-tools-$package_version
        cd build
        git clone https://android.googlesource.com/platform/build/blueprint
        cd blueprint
        git checkout platform-tools-$package_version
        cd ..
        git clone https://android.googlesource.com/platform/build/soong
        cd soong
        git checkout platform-tools-$package_version
        cd ..

        cd ..

        mkdir external
        cd external
        git clone https://android.googlesource.com/platform/external/golang-protobuf
        cd golang-protobuf
        git checkout platform-tools-$package_version
        cd ..

        # soong needs customized version of ninja
        git clone https://android.googlesource.com/platform/external/ninja

        cd ..

        mkdir -p prebuilts/go
        ln -s $installdirectory/go/ prebuilts/go/linux-x86

        # now applying some patches
        for patch in $(find $PORTS_DIR/packages/extended/$package_name/ -name '*.patch'); do
            echo "patching $patch"
            patch -p1 < $patch
        done

        cd external/ninja
	      python configure.py --bootstrap
        cd ../..
        mkdir -p prebuilts/build-tools/linux-x86/bin
        ln -s $PORTS_DIR/$builddir/external/ninja/ninja prebuilts/build-tools/linux-x86/bin/

        cd build/soong
    fi

    sh -ex ./soong_ui.bash --make-mode --skip-make

}
