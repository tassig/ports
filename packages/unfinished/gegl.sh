package_name="gegl"
package_version="0.2.0"
url="http://mirrors.tassig.com/gegl/gegl-0.2.0.tar.bz2"
no_check=1   # tests fail because of busybox diff


# TODO: does not build if ffmpeg is on the file system


export CFLAGS="-I/opt/libjpeg-turbo/include" 
export LDFLAGS="-Wl,-rpath=/opt/glib/lib  -L/opt/libjpeg-turbo/lib -Wl,-rpath=/opt/libjpeg-turbo/lib"

# hack because of broken configure.ac
mkdir -p /usr/local/include
ln -sv /opt/libjpeg-turbo/include/* /usr/local/include/


source "defaultbuild.sh"



rm -r /usr
