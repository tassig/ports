#!/bin/sh -e

package_name=libgcrypt
package_version=1.8.2
tarball_suffix=bz2
package_fullname=$package_name-$package_version
ports_build_dependencies=""
build_dependencies="libgpg-error"

source ./include.sh

main
