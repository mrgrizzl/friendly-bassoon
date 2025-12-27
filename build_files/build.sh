#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 remove -y tmux

# this installs a package from fedora repos
dnf5 install -y \
    foot \
    gnome-keyring \
    gnome-keyring-pam \
    gvfs-afc \
    gvfs-mtp \
    helix \
    ifuse \
    micro \
    pass \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-gtk \
    xdg-user-dirs

# Use a COPR
dnf5 -y copr enable avengemedia/dms
dnf5 -y install --setopt=install_weak_deps=False \
    niri \
    dms \
    dms-greeter
# Disable COPRs so they don't end up enabled on the final image:
dnf5 -y copr disable avengemedia/dms

###
sed --sandbox -i -e '/gnome_keyring.so/ s/-auth/auth/ ; /gnome_keyring.so/ s/-session/session/' /etc/pam.d/greetd

#### Enabling a System Unit File
systemctl enable greetd
# systemctl enable podman.socket

cp -avf "/ctx/files"/. /

#### Bind DMS to niri's service
# systemctl --global add-wants niri.service dms

###
systemctl enable --global dms.service
# systemctl --global enable dsearch

# Saving space
rm -rf /usr/share/doc
rm -rf /usr/bin/chsh

# REQUIRED for dms-greeter to work
tee /usr/lib/sysusers.d/greeter.conf <<'EOF'
g greeter 767
u greeter 767 "Greetd greeter"
EOF
