#!/bin/bash
## Change UID and GID for live user
usermod -u 1024 live; groupmod -g live 1024

## Fix permissions for live user
chown -R 1024:1024 /home/live

## Enable sudo for wheel members
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/10_wheel

## Create mkinitcpio preset
if [ -f /usr/bin/mkinitcpio ]; then
	rm /etc/mkinitcpio.d/*.preset
	KERNEL_NAME="$(ls /boot/vmlinu* | cut -d ' ' -f 1 | cut -c 15-)"
	echo "# mkinitcpio preset file for the '$KERNEL_NAME' package" > /etc/mkinitcpio.d/$KERNEL_NAME.preset
	echo >> /etc/mkinitcpio.d/$KERNEL_NAME.preset
	echo "#ALL_config=\"/etc/mkinitcpio.conf\"" >> /etc/mkinitcpio.d/$KERNEL_NAME.preset
	echo "ALL_kver=\"/boot/vmlinuz-$KERNEL_NAME\"" >> /etc/mkinitcpio.d/$KERNEL_NAME.preset
	echo >> /etc/mkinitcpio.d/$KERNEL_NAME.preset
	echo "PRESETS=('default')" >> /etc/mkinitcpio.d/$KERNEL_NAME.preset
	echo "#default_config=\"/etc/mkinitcpio.conf\"" >> /etc/mkinitcpio.d/$KERNEL_NAME.preset
	echo "default_image=\"/boot/initramfs-$KERNEL_NAME.img\"" >> /etc/mkinitcpio.d/$KERNEL_NAME.preset
	echo "#default_uki=\"/efi/EFI/Linux/arch-$KERNEL_NAME.efi\"" >> /etc/mkinitcpio.d/$KERNEL_NAME.preset
	echo "#default_options=\"--splash /usr/share/systemd/bootctl/splash-arch.bmp\"" >> /etc/mkinitcpio.d/$KERNEL_NAME.preset
fi

## Automatically remove drivers for GPUs not present
UNNEEDED_PKGS=""
if (! (lspci | grep -i "VGA compatible controller: NVIDIA" &> /dev/null)); then
    echo "No NVIDIA GPUs found, drivers will be uninstalled."
	UNNEEDED_PKGS="$UNNEEDED_PKGS bundle-nvidia-free"
	UNNEEDED_PKGS="$UNNEEDED_PKGS bundle-nvidia-pro"
	UNNEEDED_PKGS="$UNNEEDED_PKGS bundle-nvidia-pro-340xx"
	UNNEEDED_PKGS="$UNNEEDED_PKGS bundle-nvidia-pro-390xx"
	UNNEEDED_PKGS="$UNNEEDED_PKGS bundle-nvidia-pro-470xx"
	UNNEEDED_PKGS="$UNNEEDED_PKGS bundle-nvidia-pro-525xx"
else echo "Found NVIDIA GPU(s)"; fi
if (! (lspci | grep -i "VGA compatible controller: Intel" &> /dev/null)); then
    echo "No Intel GPUs found, drivers will be uninstalled."
	UNNEEDED_PKGS="$UNNEEDED_PKGS bundle-intel-gpu"
else echo "Found Intel GPU(s)"; fi
if (! (lspci | grep -i "VGA compatible controller: Advanced Micro Devices" &> /dev/null)); then
    echo "No AMD GPUs found, drivers will be uninstalled."
	UNNEEDED_PKGS="$UNNEEDED_PKGS bundle-amd-gpu"
else echo "Found AMD GPU(s)"; fi

## Automatically remove microcode for CPUs not present
echo "Checking CPU manufacturer..."
CPU_VENDOR_ID="$(lscpu | grep -i "Vendor ID:" | cut -d ':' -f 2 | xargs)"
[ -z "$CPU_VENDOR_ID" ] && CPU_VENDOR_ID="GenericCPU"
if [ "$CPU_VENDOR_ID" != "GenuineIntel" ]; then
    echo "Not an Intel CPU, uninstalling intel-ucode"
	UNNEEDED_PKGS="$UNNEEDED_PKGS intel-ucode"
	rm /intel-ucode.img
else echo "Found Intel CPU"; mv /intel-ucode.img /boot/; fi
if [ "$CPU_VENDOR_ID" != "AuthenticAMD" ]; then
    echo "Not an AMD CPU, uninstalling amd-ucode"
	UNNEEDED_PKGS="$UNNEEDED_PKGS amd-ucode"
	rm /amd-ucode.img
else echo "Found AMD CPU"; mv /amd-ucode.img /boot/; fi

## Automatically detect and remove unneeded packages for other hardware
[ "$(mmcli -L | cut -d ' ' -f 1)" == "No" ] && UNNEEDED_PKGS="$UNNEEDED_PKGS bundle-modemmanager modemmanager"

## Remove packages only needed for ArchISO
UNNEEDED_PKGS="$UNNEEDED_PKGS mkinitcpio-archiso syslinux archez-archiso-files archez-installer"

## Check which unneeded packages are still present, and add them to a list to uninstall
PKGS_TO_UNINSTALL=""
echo "Checking installed packages..."
for PKG in $UNNEEDED_PKGS; do
    pacman -Qi $PKG &> /dev/null && PKGS_TO_UNINSTALL="$PKGS_TO_UNINSTALL $PKG"
done
echo "To remove: $PKGS_TO_UNINSTALL"

## Uninstall unneeded packages
pacman --asexplicit -D kdialog
sed -i 's/^HoldPkg/#&/' /etc/pacman.conf
pacman --noconfirm -Rus $PKGS_TO_UNINSTALL
sed -i '/HoldPkg/s/#//g' /etc/pacman.conf

## Mark as dependencies
pacman --asdeps -D bash gnu-free-fonts iptables-nft lib32-sdl12-compat libglvnd noto-fonts ntfs-3g qt6-multimedia-gstreamer pacman phonon-qt6-gstreamer-git polkit wireplumber &> /dev/null
[ -f /usr/bin/mkinitcpio ] && pacman --asdeps -D mkinitcpio
[ -f /usr/bin/booster ] && pacman --asdeps -D booster

## InitRAMFS/GRUB
[ -f /usr/bin/mkinitcpio ] && mkinitcpio -P
[ -f /usr/bin/booster ] && /usr/lib/booster/regenerate_images
/usr/lib/arch-tweaks/system-tools/install-grub --install

## Remove files needed only by ArchISO
(pacman -Qi lightdm &> /dev/null) || rm -rf /etc/lightdm
rm -f /version /etc/mkinitcpio.conf.system /etc/sudoers.d/10-installer /etc/systemd/journald.conf.d/volatile-storage_archiso.conf /etc/systemd/system/getty@tty1.service.d/autologin_archiso.conf /usr/share/polkit-1/rules.d/49-archiso_nopasswd_global.rules
rmdir /etc/systemd/journald.conf.d /etc/systemd/system/getty@tty1.service.d &> /dev/null

## Exit gracefully even if errors occurred
exit 0
