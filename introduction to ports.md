# Introduction to Ports

Ports is a system that allows installing software on Axiom. It follows the Axiom convention for installing software. But it is not limited in its usage to Axiom, and Ports can possibly be used in other contexts.

## Purpose of Ports

Ports allows to build and install any open source software that follows the GNU conventions for software building and installing.
A program can be run by invocation of a simple command: ./packageinstall.sh name_of_the_package


## Non-purposes of Ports (what it is not for)

Ports is not a software distribution mechanism for all software. Ports is aimed at developers.
On Axiom, for instance distribution of software applications with a grpahical user interface is generally done via the Hutchr system.
It is much simpler to use Hutchr: a user does not have to build the software, does not need to use command line, and gets tight integration with Axiom done automatically by the Hutchr system.


## Design of Ports

One program "packageinstall.sh", is doing all the work. For most packages, the function defaultbuild() is run on the package information, and this installs the package.

### Base packages

In `packages/` , there is one file per package, generally consisting of just data information such as version and name of the package.

An example of a clean package that uses defaultbuild() is `autoconf`

```sh
package_name=automake
package_version=1.15
tarball_suffix=xz
build_dependencies=autoconf
no_check=1
```

### Extended packages

In `packages/extended/` , it's the same, but we also accept directories. That way packages can put patches and other files. Builds are allowed to be less clean in this directory.

An example of dirty build with patches is `gnupg`, which is located in dedicated folder, and has `gnupg.sh` script which do installation job. 

Note that in `extended` we keep package scripts with `.sh` extension, and we follow convention `package_name.sh` in case we have simpler procedure of installation, and `package_name/package_name.sh` in case we have dirty build with patches.


## Design decisions and limitations

Ports is designed for easy maintenance. As a result, we generally not allow developers to upload packages in the `packages/` root directory with "custombuild()" defined. The software should build smoothly on Axiom, with a default build. Some packages in Ports have custombuild() defined, because they are useful to build or to run Axiom, but we have them in Ports only as an exception. For example, X.org is one such package. These packages are an essential part of Axiom, so we leave them in the `packages/` root directory

We are trying to keep Axiom base system minimal and clean as possible. The set of software versions in `packages` works together smoothly, and in case we need an upgrade, only few libraries will be updated in a lockstep, unlike other distibutions which will have to update 1000+ libraries in a lockstep. Upgrading large number of libraries is very hard to test.

As a result of having packages following a default build, verification and upgrade of packages is simplified and maintenance can be done easily.

The `packages/extended/` directory contains all sorts of libraries. Everything is accepted in there and builds can be quite dirty. Such software is not usually part of default Axiom.
