# IMPORTANT NOTE: about openvpn usage on Axiom. We need to run it in several steps:
#  1. Login as root (use su)
#  2. In our openvpnconfig.ovpn file (wherever we got it from, airvpn or similar), comment line with "dev tun"
#  3. modprobe tun
#  4. openvpn --mktun --dev tun0
#  5. openvpn --dev tun0 --config openvpnconfig.ovpn

package_name="openvpn"
package_version="2.4.6"
package_url="http://mirrors.tassig.com/openvpn/openvpn-2.4.6.tar.gz"


custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $package_url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	./configure --prefix=/opt/$package_name-$package_version --disable-lzo --disable-plugin-auth-pam

	ncpu=`cat /proc/cpuinfo | grep processor | wc -l`
	make -j$ncpu
	make install

	ln -sv /opt/$package_name-$package_version /opt/$package_name || true
	ln -sv /opt/$package_name-$package_version/sbin/* /bin/ || true

	if [ -d "/opt/$package_name-$package_version/lib/pkgconfig" ]; then
		ln -svf /opt/$package_name-$package_version/lib/pkgconfig/* /opt/pkgconf/lib/pkgconfig
	fi

	cd ../..
	rm -r builddir
}
