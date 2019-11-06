package_name="mono"
package_version="5.18.1.0"
url="https://download.mono-project.com/sources/mono/mono-5.18.1.0.tar.bz2"

# TODO: remove the #include <sys/sysctl.h>
#

# /tmp is too small for mono compilation so we use another place
mkdir $HOME/tmp
export TMPDIR=$HOME/tmp


source "defaultbuild.sh"
