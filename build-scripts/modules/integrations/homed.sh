set -ouex pipefail

shopt -s nullglob

authselect select sssd with-systemd-homed with-faillock without-nullok
authselect apply-changes

system_services=(
  systemd-homed.service
)

systemctl enable "${system_services[@]}"
semanage permissive -a systemd_homed_t

preset_file="/usr/lib/systemd/system-preset/01-zena.preset"
touch "$preset_file"

for service in "${system_services[@]}"; do
  echo "enable $service" >> "$preset_file"
done
