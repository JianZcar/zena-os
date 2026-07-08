set -ouex pipefail

shopt -s nullglob

mkdir -p /var/roothome
dnf5 -y install dnf5-plugins
echo -n "max_parallel_downloads=10" >>/etc/dnf/dnf.conf

dnf5 -y install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf5 -y install --nogpgcheck --repofrompath \
  'terra,https://repos.fyralabs.com/terra$releasever' terra-release

dnf5 config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo

coprs=(
  bieszczaders/kernel-cachyos-lto
  bieszczaders/kernel-cachyos-addons

  ublue-os/packages

  yalter/niri
  ulysg/xwayland-satellite
  avengemedia/danklinux
  avengemedia/dms
  lionheartp/Hyprland
  errornointernet/quickshell
  celestelove/libcava
  celestelove/app2unit
  brycensranch/gpu-screen-recorder-git
  celestelove/caelestia

  che/nerd-fonts
)

for copr in "${coprs[@]}"; do
    echo "Enabling copr: $copr"
    dnf5 -y copr enable "$copr"
done

echo "priority=1" | tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:yalter:niri.repo
echo "priority=2" | tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:ulysg:xwayland-satellite.repo
echo "priority=3" | tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:avengemedia:danklinux.repo
dnf5 -y config-manager setopt "*terra*".priority=3 "*terra*".exclude="nerd-fonts topgrade *scx-* steam python3-protobuf zlib-devel" && \
dnf5 -y config-manager setopt "terra-mesa".enabled=true
dnf5 -y config-manager setopt "*rpmfusion*".priority=5 "*rpmfusion*".exclude="mesa-*"
dnf5 -y config-manager setopt "*fedora*".exclude="mesa-* kernel-core-* kernel-modules-* kernel-uki-virt-*"
