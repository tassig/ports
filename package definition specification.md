# Packages management facilities specifications

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
`url`: the ABSOLUTE url of the package. If not defined, then URL `http://mirrors.tassig.com/$rel_url` will be used.
`rel_url`: the RELATIVE suffix-part of URL to package. Default value is `$package_name/$package_fullname.tar.$tarball_suffix`. Need to be used, when relative tar archive location is not matched with default value. SHOULD NOT contain "http://mirrors.tassig.com" prefix in its value.
`iscustombuild`: `0` or `1`, if `1` then a function `custombuild()` needs to be provided, such function will be called in place of the `defaultbuild()` function
`haspostinstall`: `0` or `1`, if `1` then a function `haspostinstall()` needs to be provided, such function will be called after the `defaultbuild()` has completed
`no_check`: `0` or `1`, if `1` then the `make check` won't be run for this package. This is useful if a test suite is buggy or if we want to temporarily work around a bug in our system


## Policies

* add the symlinks with `ln -sv`, not just `ln -s`. Rationale: we want to have some visual clue that the symlinks were correctly created.

* justify and comment every decision you make, using inline comments
