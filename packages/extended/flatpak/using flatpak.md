# Using flatpak (quick guide)

more defailed instuctions here: `http://docs.flatpak.org/en/latest/using-flatpak.html`


## Installing flatpak

```sh
git clone ssh://yourusername@git.cacaoweb.org/../var/git/ports.git
cd ports
./packageinstall flatpak
```

Alternatively, there is a VM on the dev server (www.tassig.com) , running at vnc port 10, which was has flatpak pre-installed.

## Repositories

Before we can install apps, we have to install at least one repository.

```
# NOTE: we have to export XDG_DATA_DIRS, before we can add a repo
export XDG_DATA_DIRS=/opt/gsettings-desktop-schemas-3.20.0/share

# NOTE: be root

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo   # adds flathub
flatpak remote-ls flathub                                                                 # list available apps  
flatpak remote-delete flathub                                                             # delete repository

latpak remotes                                                                            # list installed repos
```

Some other useful repositories: (Gnome does not work)

```
Gnome Stable:
flatpak remote-add --if-not-exists gnome https://sdk.gnome.org/gnome.flatpakrepo
flatpak remote-add gnome-apps https://sdk.gnome.org/gnome-apps.flatpakrepo

Gnome Development/Unstable
flatpak remote-add --if-not-exists gnome-nightly https://sdk.gnome.org/gnome-nightly.flatpakrepo
flatpak remote-add gnome-apps-nightly https://sdk.gnome.org/gnome-apps-nightly.flatpakrepo

KDE Plasma Flatpak
flatpak remote-add --if-not-exists kdeapps --from https://distribute.kde.org/kdeapps.flatpakrepo

Deepin Linux:
flatpak remote-add --no-gpg-verify --if-not-exists deepin http://proposed.packages.deepin.com/deepin-flatpak/deepin/ --system
flatpak remote-add --no-gpg-verify --if-not-exists deepin-apps http://proposed.packages.deepin.com/deepin-flatpak/apps/ --system

Liri OS:
flatpak remote-add liri https://repo.liri.io/flatpak/liri.flatpakrepo
```

## Installing applications

flatpak application has a `name` and `ID`, which is 3 part identifier: `com.company.App`.
To search for apps, we user `name` and to install app we use `ID`

```sh
# NOTE: be root

flatpak search telegram
flatpak install org.telegram.desktop
```

For now, until we resolve user installations, all apps will be installed in `/opt/flatpak/var -> /home/varflatpak` because apps and runtimes uses lot of space, we have to keep them away form /opt

To uninstallm run `flatpak install org.telegram.desktop` (use ID)


## Running applications

We can run apps as normal users, using app ID's

```
flatpak run org.telegram.desktop
```
