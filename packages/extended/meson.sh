# IMPORTANT: at the moment it's better to install python3-better as normal user, and install meson as normal user too

package_name=meson
build_dependencies="python3-better"


custombuild(){
	pip3 install meson
	ln -sv /opt/Python/bin/meson /bin/ || true
}
