#!/bin/sh
# to list all packages and related dependences

case $1 in
    deps)
        echo ""
        for package in $(ls packages/*)                     # list all directory entries, these are container examples
        do
            pname=`basename $package`
            deps=`grep "build_dependencies" $package | cut -d'=' -f2`
            pad=`expr 32 - ${#pname}`
            echo `basename $package` `printf '%0.s.' $(seq 1 $pad)` $deps
        done
        echo ""
        ;;
    *)
    ;;
esac

