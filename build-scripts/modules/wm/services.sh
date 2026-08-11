set -ouex pipefail

shopt -s nullglob

system_services=(
  greetd.service
  flatpak-theme.service
)

user_services=(
  dms.service
  dms-watch.path
  dsearch.service
  wm-setup.service
  flathub-setup.service
  gnome-keyring-daemon.socket
  gnome-keyring-daemon.service
  dms-greeter-sync-trigger.service
)

systemctl enable "${system_services[@]}"

preset_file="/usr/lib/systemd/system-preset/01-zena.preset"
touch "$preset_file"

for service in "${system_services[@]}"; do
  echo "enable $service" >> "$preset_file"
done

mkdir -p "/etc/systemd/user-preset/"
preset_file="/etc/systemd/user-preset/01-zena.preset"
touch "$preset_file"

for service in "${user_services[@]}"; do
  echo "enable $service" >> "$preset_file"
done

systemctl --global preset-all
