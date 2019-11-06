#!/bin/sh

VERSION=3.28.2

# installs portable version of gnome-system-monitor, prepared for Axiom

# we need root privileges to properly setup application
if [ ! `id -u` = 0 ]; then
   echo "root privileges required"
   exit
fi 

# get real user name and verify if it exist
USERNAME=$(ls -l `tty` | awk '{print $3}')
IS_EXISTING_USER=`grep $USERNAME /etc/passwd`

if [ "$IS_EXISTING_USER" = "" ]; then
   echo "User $USERNAME not found in /etc/passwd"
fi

# make sure user installation folders exist, create then if not
cd /home/$USERNAME
if [ ! -d .opt/bin ]; then
    mkdir -p .opt/bin
    chown $USERNAME:$USERNAME .opt/
    chown $USERNAME:$USERNAME .opt/bin
fi
cd .opt

# download application tarball, unpack, set ownership and clean
wget http://axiom.tassig.com/applications/system-monitor/system-monitor-$VERSION.tar.gz
tar xf system-monitor-$VERSION.tar.gz
rm -rf system-monitor-$VERSION.tar.gz

# set ownership, set suid for appliaction launcher executable
chown -R $USERNAME:$USERNAME system-monitor-$VERSION
cd system-monitor-$VERSION/
chown root system-monitor
chmod +s system-monitor

# make app symlink in users .opt/bin
ln -sv /home/$USERNAME/.opt/system-monitor-$VERSION/system-monitor /home/$USERNAME/.opt/bin
