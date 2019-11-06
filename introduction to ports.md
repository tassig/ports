# Introduction to Ports

Ports is a system that allows installing software on Axiom. It follows the Axiom convention for installing software. But it is not limited in its usage to Axiom, and Ports can possibly be used in other contexts and on other operating systems.

## Purpose of Ports

Ports allows to build and install software from sources.


## Non-purposes of Ports (what it is not for)

Ports is not a software distribution mechanism for all software. Ports is aimed at developers, although it can certainly be used by non-developers.
On Axiom, for instance distribution of software applications with a graphical user interface is generally done via the Hutchr system.

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

### Base and Extended packages

In `packages/base/`, we have packages that constitute the core of the Axiom system. These packages are well maintained, any mistake in there will result in the build of Axiom (which is fully built from sources) to fail. Most packages there use the default build.

In `packages/extended/` is for packages that are not part of the core Axiom system. Builds are often less clean in this directory. All sort of third party optional software ends up in this directory.

An example of dirty build with patches is `gnupg`, which is located in dedicated folder, and has `gnupg.sh` script which does installation job. 

In `packages/unfinished/` we keep scripts that don't work yet, waiting for being integrated in `base` or `extended`.


### Policies

In `extended` we keep package scripts with `.sh` extension.


## Design decisions and limitations

Ports `base` is designed for easy maintenance. As a result, we prefer to use default build rather than custom build (default build adds no additional code). As a result of having packages following a default build, verification and upgrade of packages is simplified and maintenance can be done easily.

We are trying to keep Axiom base system minimal and clean as possible. The set of software versions in `packages` works together smoothly, and in case we need an upgrade, only few libraries will be updated in a lockstep, unlike other distibutions which will have to update 1000+ libraries in a lockstep. Upgrading large number of libraries is very hard to test. Consequently, we want `base` to be as small as possible.

In contrast, `extended` contains more packages, complex build scripts and a complex graph of dependencies. The `packages/extended/` directory contains all sorts of libraries. Everything is accepted in there and builds can be quite dirty. Such software is not usually part of default Axiom.
