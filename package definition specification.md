# Ports

The ports system allows to install software. Below we explain how to define a package.

## Package identifiers

Each package is identified by a unique identifier, which is the filename of the package definition in the directory `packages/`
Examples: an package unique identifier can be `strace` or `autoconf`


## Package definition

A package definition is a file in the directory `packages/`

### Public, mandatory variables

These variables are mandatory and can be used without restrictions, by internal or external scripts.

`package_name`: internal name used by the package. NB: This is *not* the unique identifier of the package
`package_version`: package version
`tarball_suffix`: suffix of tar archive. Example: for strace-4.0.tar.gz, `tarball_suffix` is `gz`

### Public, optional variables

`build_dependencies`: a list of packages unique identifiers separated by spaces and quoted, representing the packages needed by this package at build time. Empty if there are no build build_dependencies. example: build_dependencies="m4 perl"
`custombuild()`: can be provided, such function will be called in place of the `defaultbuild()` function
`haspostinstall()`: can be provided, such function will be called after the `defaultbuild()` has completed
`no_check`: `0` or `1`, if `1` then the `make check` won't be run for this package. This is useful if a test suite is buggy or if we want to temporarily work around a bug in our system

### Autodefined variables

packageinstall.sh script provides some variables, that can be used in custombuild function:

* `package_fullname` = `$package_name-$package_version` - variable contains package name and version
* `installdirectory` = contains path to destination (prefix) directory
* `mirror_prefix` = URL prefix. By default = `http://mirrors.tassig.com`

## Policies

* add the symlinks with `ln -sv`, not just `ln -s`. Rationale: we want to have some visual clue that the symlinks were correctly created.

* justify and comment every decision you make, using inline comments
