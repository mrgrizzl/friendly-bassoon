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
dnf5 install -y gvfs-afc gvfs-mtp helix ifuse micro pass

# Use a COPR
dnf5 -y copr enable avengemedia/dms
dnf5 -y install niri dms dms-greeter
# Disable COPRs so they don't end up enabled on the final image:
dnf5 -y copr disable avengemedia/dms

#### Bind DMS to niri's service
systemctl add-wants niri.service dms

#### Enabling a System Unit File
systemctl enable greetd
systemctl enable podman.socket
