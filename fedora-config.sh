#!/bin/bash

# Exit if not running as root
if [[ ! $(whoami) = "root" ]]; then
    echo "Please run the script as root."
    exit 1
fi


# Set Hostname
echo 'Enter a Hostname:'
read hstnme
echo $hstnme > /etc/hostname


# Lock the root account
passwd -l root


# Setup repositories
# RPM Fusion free
dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
# RPM Fusion non-free
dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm


# Remove unwanted software
# System Software

# GUI software
dnf remove -y cheese eog evolution firefox gnome-{boxes,characters,clocks,documents,font-viewer,maps} rhythmbox shotwell


# Software Installs
# CLI tools
dnf install -y nano

# Generic OS GUI software and Gnome packages
dnf install -y deja-dup deja-dup-nautilus epiphany gedit-code-assistance gedit-plugins geary gimp gnome-{music,terminal-nautilus,tweak-tool} gthumb simple-scan

# Keepassx
dnf install -y keepassx

# Dropbox
dnf install -y dropbox nautilus-dropbox

# Language tools
dnf install -y hunspell-en-GB

# Add required packages for mp3 playback (ffmpeg / gstreamer)
dnf install -y gstreamer1-plugins-{base,good,ugly,bad-{free,freeworld,free-extras}} ffmpeg

# Powerline
dnf install -y powerline powerline-fonts
cat <<EOF >> /etc/bashrc

# Powerline
if [ -f `which powerline-daemon` ]; then
  powerline-daemon -q
  POWERLINE_BASH_CONTINUATION=1
  POWERLINE_BASH_SELECT=1
  . /usr/share/powerline/bash/powerline.sh
fi
EOF

# Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
dnf install -y google-chrome-stable_current_x86_64.rpm
rm google-chrome-stable_current_x86_64.rpm

# Zotero
wget https://download.zotero.org/client/release/5.0.23/Zotero-5.0.23_linux-x86_64.tar.bz2
tar xfj Zotero-5.0.23_linux-x86_64.tar.bz2 -C /opt
rsync -Du --chmod=664 applications/zotero/zotero.desktop /usr/share/applications
rsync -rlDu --chmod=D775,F664 applications/zotero/icons /usr/share
rm Zotero-5.0.23_linux-x86_64.tar.bz2


# Shell extensions
# From repos
dnf install -y gnome-shell-extension-{alternate-tab,common,drive-menu,openweather,places-menu,pomodoro,topicons-plus}
# dash-to-dock
wget -O extension.zip "https://extensions.gnome.org/download-extension/dash-to-dock@micxgx.gmail.com.shell-extension.zip?version_tag=6265"
mkdir -p "/usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com"
unzip -oqq extension.zip -d "/usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com"
chmod -R o+r "/usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com"
rm extension.zip
# Install gschemas
cp "/usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/org.gnome.shell.extensions.dash-to-dock.gschema.xml" /usr/share/glib-2.0/schemas
# 2> /dev/null prevents warnings / errors from displaying
glib-compile-schemas /usr/share/glib-2.0/schemas 2> /dev/null


# Theming
# Backroungs
dnf install -y f26-backgrounds-animated
# gtk theme
dnf install -y arc-theme
# Papirus icon theme
dnf copr enable -y dirkdavidis/papirus-icon-theme
dnf install -y papirus-icon-theme


# Install custom dconf profiles
# Install gschemas
rsync -rlDu --chmod=D775,F664 schemas /usr/share/glib-2.0
# 2> /dev/null prevents warnings / errors from displaying
glib-compile-schemas /usr/share/glib-2.0/schemas 2> /dev/null
# Set defaults
rsync -rlDu --chmod=D775,F664 dconf /etc
dconf update

# File Templates
rsync -rlDu --chmod=D775,F664 Templates /etc/skel


# For existing users:
for dir in /home/*; do
    if [ ! $dir = "/home/lost+found" ]; then
        # Get user name
        user="$(basename $dir)"
        # File Templates
        rsync -a Templates $dir
        chown $user:$user -R $dir/Templates
        # Reset all dconf keys to default
        sudo -u $user dconf reset -f /
    fi
done
