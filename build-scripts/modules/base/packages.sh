set -ouex pipefail

shopt -s nullglob

packages=(
  # Network / Connectivity
  NetworkManager
  NetworkManager-adsl
  NetworkManager-bluetooth
  NetworkManager-config-connectivity-fedora
  NetworkManager-libnm
  NetworkManager-openconnect
  NetworkManager-openvpn
  NetworkManager-strongswan
  NetworkManager-ssh
  NetworkManager-ssh-selinux
  NetworkManager-vpnc
  NetworkManager-wifi
  NetworkManager-wwan
  openconnect
  spoofdpi
  vpnc
  wireguard-tools
  mobile-broadband-provider-info
  ifuse
  jmtpfs
  gvfs-mtp
  gvfs-nfs
  gvfs-smb
  gvfs-archive

  # Printing / CUPS / Drivers
  cups
  cups-pk-helper
  dymo-cups-drivers
  gutenprint-cups
  hplip
  printer-driver-brlaser
  ptouch-driver
  system-config-printer-libs
  system-config-printer-udev

  # Audio / Firmware
  alsa-firmware
  alsa-sof-firmware
  alsa-tools-firmware
  intel-audio-firmware
  atheros-firmware
  brcmfmac-firmware
  iwlegacy-firmware
  iwlwifi-dvm-firmware
  iwlwifi-mvm-firmware
  realtek-firmware
  mt7xxx-firmware
  nxpwireless-firmware
  tiwilink-firmware

  # Security / Authentication
  audispd-plugins
  audit
  fprintd
  fprintd-pam
  pam_yubico
  pcsc-lite
  firewalld

  # Containers
  distrobox
  systemd-container

  # Fonts
  default-fonts
  default-fonts-core-emoji
  glibc-all-langpacks
  google-noto-emoji-fonts
  google-noto-color-emoji-fonts
  nerd-fonts

  # Performance
  cachyos-ksm-settings
  cachyos-settings
  ksmtuned
  scxctl
  scx-manager
  scx-scheds-git
  scx-tools-git
  power-profiles-daemon
  thermald

  # System / Utilities
  fuse
  fuse-common
  fwupd
  inotify-tools
  libcamera
  libcamera-v4l2
  libcamera-gstreamer
  libcamera-tools
  libimobiledevice
  libimobiledevice-utils
  libratbag-ratbagd
  man-db
  man-pages
  plymouth
  plymouth-system-theme
  rsync
  steam-devices
  switcheroo-control
  unzip
  usb_modeswitch
  uxplay
  whois
  xdg-user-dirs
  xdg-terminal-exec

  # Extra
  bazaar
  fastfetch
  firewall-config
  flatpak
  glx-utils
  tailscale
  v4l2loopback
)

dnf5 -y install "${packages[@]}"

# Dependencies for the First Boot Setup
packages=(
  niri
  python3-gobject
  gtk4
  gtk4-layer-shell
  webkitgtk6.0
)

dnf5 -y install "${packages[@]}" --setopt=install_weak_deps=False
mv /usr/share/wayland-sessions/niri.desktop /usr/share/wayland-sessions/niri.desktop.disabled

# First Boot Setup GUI
curl -fsSL https://github.com/Zena-Linux/Zena-Setup/raw/refs/heads/main/zena-setup | install -m 755 /dev/stdin /usr/libexec/zena-setup
curl -fsSL https://github.com/Zena-Linux/Zena-Setup/raw/refs/heads/main/zena-setup-daemon | install -m 755 /dev/stdin /usr/libexec/zena-setup-daemon
