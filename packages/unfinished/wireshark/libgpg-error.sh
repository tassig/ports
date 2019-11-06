#!/bin/sh -e

package_name=libgpg-error
package_version=1.29
tarball_suffix=bz2
package_fullname=$package_name-$package_version
ports_build_dependencies=""
build_dependencies=""

source ./include.sh

main
