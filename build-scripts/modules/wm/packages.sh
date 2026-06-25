set -ouex pipefail

shopt -s nullglob

packages=(
  adw-gtk3-theme
  alacritty
  cava
  danksearch
  dgop
  dms
  dms-greeter
  glycin-thumbnailer
  kanshi
  khal
  kf6-kimageformats
  nautilus
  papirus-icon-theme
  quickshell
  xdg-desktop-portal-gtk
  xdg-desktop-portal-gnome
  wl-clipboard
)
dnf5 -y install "${packages[@]}" --exclude=matugen --exclude=noctalia-qs
dnf5 -y install nautilus-python matugen --releasever=44 --disablerepo='*copr*'

packages=(
  gnome-keyring
  gnome-keyring-pam
  mangowc
  pinentry-gnome3
  zenity
)

dnf5 -y install "${packages[@]}" --setopt=install_weak_deps=False

XDG_EXT_TMPDIR="$(mktemp -d)"
curl -fsSLo - "$(curl -fsSL https://api.github.com/repos/tulilirockz/xdg-terminal-exec-nautilus/releases/latest | jq -rc .tarball_url)" | tar -xzvf - -C "${XDG_EXT_TMPDIR}"
install -Dpm0644 -t "/usr/share/nautilus-python/extensions/" "${XDG_EXT_TMPDIR}"/*/xdg-terminal-exec-nautilus.py
rm -rf "${XDG_EXT_TMPDIR}"

dconf update
systemctl set-default graphical.target
mv /usr/share/wayland-sessions/niri.desktop.disabled /usr/share/wayland-sessions/niri.desktop
sed -i 's|^Exec=.*|Exec=bash -c "niri-session > /dev/null 2>\&1"|' \
  /usr/share/wayland-sessions/niri.desktop

sed -i 's|^Exec=.*|Exec=bash -c "mango -s mango-session > /dev/null 2>\&1"|' \
  /usr/share/wayland-sessions/mango.desktop

