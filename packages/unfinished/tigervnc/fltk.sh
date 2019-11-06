#!/bin/sh

package_name=fltk
package_version=1.3.4
url=http://mirrors.tassig.com/fltk/fltk-1.3.4-1-source.tar.gz
no_check=1 # TODO: fix tests

export CPPFLAGS="-I/opt/xorg/include -I/opt/freetype/include -I/opt/fontconfig/include"
export LDFLAGS="-L/opt/xorg/lib -L/opt/freetype/lib -L/opt/fontconfig/lib -Wl,-rpath,/opt/xorg/lib:/opt/freetype/lib:/opt/fontconfig/lib"

[ -L /opt/fltk ] && exit 0

source ../defaultbuild.sh
