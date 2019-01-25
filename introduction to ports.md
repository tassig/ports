# Introduction to Ports

Ports is a system that allows installing software on Axiom. It follows the Axiom convention for installing software. But it is not limited in its usage to Axiom, and Ports can possibly be used in other contexts.

## Purpose of Ports

Ports allows to build and install any open source software that follows the GNU conventions for software building and installing.
A program can be run by invocation of a simple command: ./packageinstall.sh name_of_the_package


## Non-purposes of Ports (what it is not for)

Ports is not a software distribution mechanism for all software. Ports is aimed at developers.
On Axiom, software application distribution is done via the Hutchr system.
It is much simpler to use Hutchr: a user does not have to build the software, does not need to use command line, and gets tight integration with Axiom done automatically by the Hutchr system.


## Design decisions and limitations

Ports is designed for easy maintenance. As a result, we do not allow developers to upload packages with "custombuild()" defined. The software should be smoothly on Axiom, with a default build. Some packages in Ports have custombuild() defined, because they are useful to build or to run Axiom, but we have them in Ports only as an exception.

As a result of having packages following a default build, verification and upgrade of packages is simplified and maintenance can be done easily.
