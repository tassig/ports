# IMPORTANT: at the moment it's better to install python3-better as normal user, and install meson as normal user too

package_name=meson
build_dependencies="python3-better"


custombuild(){
	pip3 install meson
	ln -svf /opt/Python-3.8.0/bin/meson /bin/ || true
}
