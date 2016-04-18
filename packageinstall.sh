# usage: ./packageinstall.sh package_name

# the function called by default to build a package, works for most packages
defaultbuild(){
        package_fullname=$package_name-$package_version
        wget $url
        tar xvf $package_fullname.tar.$tarball_suffix
        cd $package_fullname/
        ./configure --prefix=/opt/$package_fullname/
        make
        make install
        ln -s /opt/$package_fullname /opt/$package_name
        ln -s /opt/$package_name/bin/* /bin/
        cd ..
}


installpackage(){
        echo "installing package $1"

        source $1
        echo "dependencies of $1: $build_dependencies"

        # installing the dependencies recursively
        for pkg_name in $build_dependencies
        do
                (installpackage $pkg_name)
        done

        # do a custom build if the package defines custombuild(), otherwise do a default build
        if test iscustombuild
        then custombuild
        else defaultbuild
        fi
        
        if test haspostinstall
        then postinstall
        fi
        
}


installpackage $1
