# ArchEZ
Are you tired of Windows or MacOS being slow and breaking all the time? You've probably considered switching to Linux, but you don't know if it's right for you. Introducing ArchEZ: A free and easy to use Arch Linux installer. It features an easy to use graphical installer and comes bundled with a desktop environment, basic utilities, networking and device drivers as well as performance and security optimisations. It is designed to be small, fast and secure. Your data will never be collected or shared, ever.

## About ArchEZ
ArchEZ Linux is based on Arch Linux, which is is a highly customisable Linux distribution that aims to keep it simple. You install the system yourself from scratch, choosing whatever software packages you need, and configure it afterwards for your specific use case. This is a very hands on approach that may not be for everyone. It is very time consuming, especially if you need to install it on multiple machines, or if you need to reinstall Arch Linux for some reason. It's easy to forget things, and you may find yourself spending more time troubleshooting issues.

ArchEZ was created to make installing Arch Linux quick and easy, while still being highly customisable. It is preconfigured for to suit the needs of most PC users like web browsing, office work, multimedia and gaming. All important services are already set up and enabled, like networking, bluetooth, sound, printing and scanning. You can still install, uninstall and configure whatever you want, including ArchEZ software bundles. ArchEZ just works, and doesn't stop you from tweaking and customising the OS.

## ArchEZ software repositories
In the ArchEZ software repositories, you'll find custom software packages and bundles to help you quickly and easily install and configure software and services. Each package includes all the necessary components required for use, and when installed, will set up everything for you. There is no need to do anything manually, just install the package and you're done.
[Desktop environments]
 - bundle-kde: KDE Plasma desktop environment
 - bundle-xfce: XFCE lightweight desktop environment
 - archez-config-kde: Custom configuration for ArchEZ KDE Plasma
 - archez-config-kde-gaming: Custom configuration for ArchEZ KDE Plasma Gaming Edition
[Drivers]
bundle-amd-gpu: AMD GPU drivers
bundle-bluetooth: Bluetooth drivers
bundle-intel-gpu: Intel GPU drivers
bundle-modemmanager: Mobile networking drivers
bundle-networking: Networking drivers
bundle-nvidia-foss: NVIDIA GPU open source drivers
bundle-nvidia-pro: NVIDIA GPU proprietary drivers (latest version)
bundle-nvidia-pro-340xx: NVIDIA GPU proprietary drivers (version 340xx)
bundle-nvidia-pro-390xx: NVIDIA GPU proprietary drivers (version 390xx)
bundle-nvidia-pro-470xx: NVIDIA GPU proprietary drivers (version 470xx)
bundle-nvidia-pro-525xx: NVIDIA GPU proprietary drivers (version 525xx)
bundle-printing: Printing and scanning drivers
[Extra functionality]
arch-tweaks: Performance and convenience optimisations
bashrc-d: Load bash configs from /etc/bashrc.d/
bundle-archives: Support for extra compressed file types
bundle-cli-utils: Useful command-line utilities
bundle-desktop: Desktop utilities and software
bundle-filesystems: Support for extra filesystems
bundle-gvfs: Support for file and picture transfer in GTK based desktop environments like XFCE and GNOME
bundle-media-codecs: Additional multimedia codecs
bundle-wine: Support for Windows programs and games
[Themes]
fruit-cursors: Free open-source cursor theme inspired by a certain fruit-named company
plasma-colors-midnight: Black and dark grey colour scheme for KDE Plasma
plymouth-theme-arch-breeze: KDE Breeze Plymouth boot splash with Arch Linux logo
plymouth-theme-breeze: KDE Breeze Plymouth boot splash
[Apps]
winerunner: Automatically configure Wine while running Windows games and apps
[Misc]
archez-archiso-files: ArchEZ live ISO installer files

## System requirements
The system requirements vary depending on the desktop environment and use case (i.e. casual work or gaming).
Currently, only devices with a 64-bit Intel or AMD processor are supported (x64, x86_64 or amd64).
ArchEZ and Arch Linux may come to more devices in the future, like smartphones/tablets, Chromebooks, Apple Silicon Macs and others. But that will take a very long time to happen.
Older 32-bit devices will NEVER be supported as they are just too slow, limited in functionality and complicated to maintain.
#### KDE Plasma: minimum requirements
- CPU: 1GHz
- GPU: Any GPU or integrated graphics from after 2008
- RAM: 2GiB
- Storage: 12GiB free disk space
#### KDE Plasma: recommended requirements
- CPU: 1.4GHz dual-core
- GPU: Any GPU or integrated graphics from after 2012
- RAM: 4GiB
- Storage: 16GiB free disk space

## System requirements for gaming
The Linux Gaming Ready certification has different tiers that determine how good your hardware is, and what kind of games your device can run.
These range from the lowest tier to the highest tier. The tier given depends on the age of your hardware, compatibility with games and general performance. NVIDIA GPUs have limited support as well as some issues with certain software. For that reason the highest tier you can achieve with any NVIDIA GPU is Silver.

#### Poop
The worst tier, given to hardware that does not meet the requirements of higher tiers. Only good for 8-bit and 16-bit retro game emulation and maybe Linux native games or old Windows games using DirectX 9 and below. No support for any recent Windows games. You don't have a Gaming PC, stop calling it a Gaming PC.

#### Rust
Basically obsolete. Enough to run for Indie games, older Windows games and possibly emulation of 6th and 7th generation consoles. Don't expect any modern AAA game to run at all.
CPU: 1.4GHz, 4 cores or 2 cores with hyperthreading
RAM: 4GB DDR2
GPU: 2GB VRAM, Vulkan 1.3

## Getting ArchEZ Linux
There are no online hosted images available to download (yet). You will have to build them yourself. Please read the next 2 sections for build instructions.
archez-kde: Arch Linux with KDE Plasma desktop environment and pre-installed applications
archez-kde-gaming: Arch Linux with KDE Plasma desktop environment and pre-installed applications for gaming and streaming
archez-kde-lite: Arch Linux with KDE Plasma desktop environment and minimal set of pre-installed applications
archez-xfce: Arch Linux with XFCE lightweight desktop environment and pre-installed applications

## How the build process works
The official Arch Linux releases are built with archiso, so this is what I am using for ArchEZ Linux. Archiso reads a custom profile (preset) and builds the ISO (the Arch Linux boot/install media).
You can specify what software/services you want to include, system configuration and first-boot setup, ISO info/build options and more.
ArchISO has a few limitations however:
 - The only supported boot loaders are Syslinux for legacy BIOS systems, and GRUB or Systemd-boot for modern UEFI systems.
 - ArchISO only supports booting an initramfs created with mkinitcpio using udev (busybox) init system. Systemd init and Dracut/Booster are not supported.
See also https://wiki.archlinux.org/title/Archiso for more information on building images with ArchISO.

## Building ArchEZ Linux
You will need a computer running Arch Linux x86_64.
1) Install required dependencies while updating databases and installed packages:
```
sudo pacman --needed -Syu archiso base-devel git
```
2) Clone the ArchEZ ArchISO Github repository and enter the archez folder:
```
git clone https://github.com/dankcuddlybear/archez-linux-archiso.git
cd archez-linux-archiso
```
Then enter the folder for the ArchEZ ArchISO preset you want to build:
(currently available: archez-kde archez-kde-gaming archez-kde-lite archez-xfce archez-lite)
```
cd archez-kde
```
3) To add or remove repositories, edit pacman.conf. This configuration file is only used to build the ISO. These repositories will not be available in the final image after booting. To add repositories to the final image, you need to edit airootfs/etc/pacman.conf.
4) By default, the core, extra, multilib, archez and chaotic-aur repositories are enabled. For ArchISO the alci_repo repository is also enabled (needed for Calamares installer). If you want to use Chaotic-AUR, you will need to first add the keys and mirrorlist to your system:
```
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
```
Make sure you also add keys for other repositories you need if necessary.
4) Edit packages.x86_64 to include whatever software packages you want. Do not remove any entries with warnings not to remove them.
5) The file profiledef.sh defines properties for the ISO, such as the filename, label, version, file permissions and more. Bootloader configuration is found inside the folders grub (for UEFI) and syslinux (for BIOS). The airootfs folder contains files to include in the root filesystem in the final ISO image. See also https://wiki.archlinux.org/title/Archiso#Profile_structure for more information.
6) The file airootfs/etc/pacman.d/scripts/archiso-setup.sh is a script that will finish setting up the ISO after pacman has finished installing packages. For example, uncomment mirrors in the pacman mirrorlist, enable services, initialise pacman keyring and add keys. The script will automatically add keys for Chaotic-AUR. Make sure to add commands to add keys for any custom repositories you need. Make sure to enable whatever services you need.
7) OPTIONAL: configure default hostname (airootfs/etc/hostname), system locale (airootfs/etc/locale.conf and airootfs/etc/locale.gen), console keyboard layout and font (airootfs/etc/vconsole.conf) and timezone (ln -sf /usr/share/zoneinfo/Region/City airootfs/etc/localtime).
8) OPTIONAL: Place a custom wallpaper (named default-wallpaper.png or default-wallpaper.jpg) inside airootfs/usr/share/wallpapers.
9) Go back to the archez folder. If you have 16GB RAM or less, run this command to build the ISO:
```
sudo mkarchiso -v ./archez-kde
```
If you have more than 16GB RAM, you can use the /tmp directory in RAM to avoid storing temporary files on the disk:
```
sudo mkarchiso -v -w /tmp/archez-tmp ./archez-kde
```
10) Once the ISO has been built, you can flash a USB stick with Ventoy and drop the ISO on the USB stick. This is the reccomended method as Ventoy allows booting multiple different ISOs from the same USB drive, and it's as simple as dragging and dropping the ISO files.

That's it, you can now boot the image on a PC.
