# arch-tweaks
Tweaks and bug fixes to improve performance, energy efficiency, security and convenience on Arch Linux.

# Features
 - Automatically configure and update Limine and GRUB bootloader after Pacman update
 - Preserve old kernel modules after kernel update, so devices keep working before rebooting
 - Automatically clean up junk files after Linux kernel update (mkinitcpio presets, kernel modules, kernel files)
 - Force data to sync to disk after using Pacman, to prevent data corruption
 - List packages that are installed as dependencies but are no longer required by other packages after using Pacman, so the user can easily remove them
 - Automatically update time and date with systemd-timesyncd
 - Automatically update time zone and wireless regulatory domain when travelling to different countries
 - Fix an issue on HP laptops where closing the lid turns off wireless communications
 - Fix an issue where external optical drives go to sleep while in use and don't wake back up
 - Disable watchdog for better performance
 - Reload Udev rules when waking system from suspend
 - Enable energy saving features for GPUs, disks and other system devices
 - Enable faster I/O schedulers for storage devices
 - Enable TRIM for SSDs to prolong life span

# TODO
 - Automatically update Pacman mirrorlist with the fastest mirrors for your region
 - Easily enable or disable encryption for user home directory with a single command
 - Set a customised MAC address for your network interfaces: Real, Custom or Random
