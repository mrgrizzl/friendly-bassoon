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

# REQUIRED for dms-greeter to work
tee /usr/lib/sysusers.d/greeter.conf <<'EOF'
g greeter 767
u greeter 767 "Greetd greeter"
EOF

# System conf (and os-release)
HOME_URL="https://github.com/mrgrizzl/friendly-bassoon"
DATE=$(date +'%Y%m%d')
echo "slimblue" | tee "/etc/hostname"
# OS Release File (changed in order with upstream)
# TODO: change ANSI_COLOR
sed -i -f - /usr/lib/os-release <<EOF
s|^NAME=.*|NAME=\"Slimblue Linux\"|
s|^VERSION=.*|VERSION=\"slim.${DATE} (Niri Atomic)\"|
s|^VERSION_CODENAME=.*|VERSION_CODENAME=""|
s|^PRETTY_NAME=.*|PRETTY_NAME=\"Slimblue Linux slim.${DATE} (Niri Atomic)\"|
s|^CPE_NAME=\".*\"|CPE_NAME=\"cpe:/o:mrgrizzl:friendly-bassoon\"|
s|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME=\"slimblue\"|
s|^HOME_URL=.*|HOME_URL=\"${HOME_URL}\"|
s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"${HOME_URL}\"|
s|^SUPPORT_URL=.*|SUPPORT_URL=\"${HOME_URL}/issues\"|
s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"${HOME_URL}/issues\"|
s|^VARIANT=.*|VARIANT=\"Niri Atomic\"|
s|^VARIANT_ID=.*|VARIANT_ID=\"niri-atomic\"|
s|^OSTREE_VERSION=.*|OSTREE_VERSION=\"slim.${DATE}\"|

/^REDHAT_BUGZILLA_PRODUCT=/d
/^REDHAT_BUGZILLA_PRODUCT_VERSION=/d
/^REDHAT_SUPPORT_PRODUCT=/d
/^REDHAT_SUPPORT_PRODUCT_VERSION=/d
EOF

# Cleanup
echo "==> Available space before cleanup"
df -h

rm -rf /usr/share/doc

echo "==> Available space after cleanup"
df -h

rm -rf /usr/bin/chsh

echo "==> Available space after cleanup"
df -h

dnf5 -y clean all

echo "==> Available space after cleanup"
df -h
