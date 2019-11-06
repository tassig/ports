# Flatpak

## Issues with Axiom

* ostree uses /tmp, and wants a big /tmp. This generates an error:
	Error: Not enough disk space to complete this operation
	error: Failed to install org.gnome.Platform: While pulling runtime/org.gnome.Platform/x86_64/3.34 from remote # flathub: Writing content object: min-free-space-size 500MB would be exceeded, at least 2.0 kB reques
	

	 But this error does not occur as root. So what is ostree doing when root vs normal user?

* needs export XDG_DATA_DIRS=/opt/gsettings-desktop-schemas-3.20.0/share . I guess it's fine, and not really an issue.

* error while adding new repo: "GLib-GIO-Message: Using the 'memory' GSettings backend.  Your settings will not be saved or shared with other applications.  For now I can guess it's related to missing dbus, which is required by dconf (default backend for gsettings)

## Issues with apps

* libreoffice: crashes (don't know the reason). strace shows some failure, maybe the application is not packaged properly

* steam:
  - pulseaudio error for mic
  - [1105/102624.534867:ERROR:sandbox_linux.cc(369)] InitializeSandbox() called with multiple threads in process gpu-process. => same kind of error as chrome, they use the same component
  - Fatal : VkResult is "ERROR_INITIALIZATION_FAILED" in /home/pgriffais/src/Vulkan/base/vulkanexamplebase.cpp at line 823
vulkandriverquery: /home/pgriffais/src/Vulkan/base/vulkanexamplebase.cpp:823: void VulkanExampleBase::initVulkan()
  - game could not be stopped form stram, STOP button won't work
  - steam uses systray for game icons, we don't have it, so once we quit game window, we can't re-enter, so game needs to be killed manually, before we can log off and quit steam
  - known steam issues with flatpak: `https://wiki.archlinux.org/index.php/Steam`

* spotify: cannot connect to pulseaudio




## Behavior of flatpak

* installation and running are done separately. You can do installation as "root" (run flatpak install XXX as root). I don't know what's the difference.

* as root, the installation of apps is done in /var/lib, which we have redirected to /home/varflatpak .

* when an application is run as jerry, it writes in ~/.var/ .

* installing a few apps takes 10G of data
