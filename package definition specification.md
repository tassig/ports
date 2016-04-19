# Packages management facilities specifications

## Package identifiers

Each package is identified by a unique identifier, which is the filename of the package definition in the directory `packages/`
Examples: an package unique identifier can be `strace` or `autoconf`


## Package definition

A package definition is a file in the directory `packages/`

### Local, optional variables

These variables are defined to be used internally within the package functions (if they exist) or by the function `defaultbuild()`. They MUST NOT be used anywhere else.

`package_name`: internal name used by the package. NB: This is *not* the unique identifier of the package
`package_version`
`tarball_suffix`
`url`

### Public, optional variables

`iscustombuild`: `0` or `1`, if `1` then a function `custombuild()` needs to be provided, such function will be called in place of the `defaultbuild()` function
`haspostinstall`: `0` or `1`, if `1` then a function `haspostinstall()` needs to be provided, such function will be called after the `defaultbuild()` has completed

### Public, mandatory variables

These variables are mandatory and can be used by without restrictions, by internal or external scripts.

`build_dependencies`: a list of packages unique identifiers separated by spaces and quoted, representing the packages needed by this package at build time. Empty if there are no build build_dependencies
`runtime_dependencies`: same as above, but representing the packages needed at runtime

example:
build_dependencies="m4 perl"

