# IMPORTANT: at the moment it's better to install python3-better as normal user, and install meson as normal user too

package_name=meson
build_dependencies="python3" # or "python3-better"


custombuild(){
	pip3 install meson
	ln -sv $installdirectory/$package_name/bin/* /bin/ || true
}
