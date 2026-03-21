#!/bin/sh
# Ask for password
pkexec true && AUTH_FAILED=0 || AUTH_FAILED=1
[ "$AUTH_FAILED" == 1 ] && kdialog --title "Package reinstaller" --error "You do not have administrative permissions required to reinstall software packages.\nYou must be a member of the group \"wheel\"." &> /dev/null && exit 1

# Uncomment HoldPkg if not already
sudo sed -i '/HoldPkg/s/^#//g' /etc/pacman.conf && AUTH_FAILED=0 || AUTH_FAILED=1
[ "$AUTH_FAILED" == 1 ] && kdialog --title "Package reinstaller" --error "You do not have administrative permissions required to reinstall software packages.\nYou must be a member of the group \"wheel\"." &> /dev/null && exit 1

echo "Loading installed packages:"
notify-send --urgency=low --app-name="Package reinstaller" --icon="package-reinstall" --category=network "Loading packages..." "This may take a while." &> /dev/null

# First, get explicitly installed packages and add to explicit list
INSTALLED_PKGS="$(pacman -Qqe)"; EXP_PKGS="$(echo $INSTALLED_PKGS | xargs)"

# Next, get dependencies and append to list of installed packages
INSTALLED_PKGS="$INSTALLED_PKGS $(pacman -Qqd)"

# Compile list of packages into selection
PKG_CHOICES=""; for PKG in $INSTALLED_PKGS; do
    PKG_CHOICES="$PKG_CHOICES $PKG $PKG off"
    echo $PKG
done

PKG_SELECTION="$(kdialog --checklist "This is a list of packages explicitly installed by the user, followed by their dependencies.\n\n Select one or more packages to reinstall." $PKG_CHOICES)"
PKG_SELECTION="$(echo "$PKG_SELECTION" | xargs)"
if [ ! -z "$PKG_SELECTION" ]; then
    kdialog --yesno "The following package(s) will be reinstalled:\n$PKG_SELECTION\n\nDo you want to continue?" &> /dev/null && \
    CONFIRM=1 || CONFIRM=0

    if [ $CONFIRM == 1 ]; then
        # Check internet connection
        notify-send --urgency=low --app-name="Package reinstaller" --icon="package-reinstall" --category=network "Checking internet connection..." &> /dev/null
        ping -c 1 archlinux.org &> /dev/null && SUCCESS=1 || SUCCESS=0
        [ $SUCCESS == 0 ] && kdialog --title "Package reinstaller" --error "Failed to connect to the internet." &> /dev/null && exit 1

        # Download packages
        notify-send --urgency=low --app-name="Package reinstaller" --icon="package-reinstall" --category=network "Downloading packages..." "This may take a while." &> /dev/null
        DOWNLOAD_ATTEMPTS=0; CONTINUE=0
        while [ $DOWNLOAD_ATTEMPTS -lt 5 ] && [ $CONTINUE == 0 ] ; do
            DOWNLOAD_FAILED=0; sudo pacman --noconfirm -Syw $PKG_SELECTION || DOWNLOAD_FAILED=1
            if [ $DOWNLOAD_FAILED == 1 ]; then
                if [ $DOWNLOAD_ATTEMPTS -lt 5 ]; then
                    DOWNLOAD_ATTEMPTS=$(expr $DOWNLOAD_ATTEMPTS + 1)
                    notify-send --urgency=critical --app-name="Package reinstaller" --icon="dialog-error" --category=network "Failed to download packages" "Trying again in 5 seconds..." &> /dev/null
                    sleep 5
                else
                    kdialog --title "Package reinstaller" --error "The following packages failed to install:\n$PKG_SELECTION\n\nPlease verify that you are connected to the internet and you are a member of the group \"wheel\"." &> /dev/null && exit 1
                fi
            else CONTINUE=1; fi
        done

        # Temporarily comment HoldPkg to avoid problems with automation
        sudo sed -i '/HoldPkg/s/^/#/g' /etc/pacman.conf && AUTH_FAILED=0 || AUTH_FAILED=1
        [ "$AUTH_FAILED" == 1 ] && kdialog --title "Package reinstaller" --error "You do not have administrative permissions required to reinstall software packages.\nYou must be a member of the group \"wheel\"." &> /dev/null && exit 1

        # Uninstall packages
        notify-send --urgency=low --app-name="Package reinstaller" --icon="package-reinstall" --category=network "Uninstalling packages..." "This may take a while." &> /dev/null
        sudo pacman --noconfirm -Rusdd $PKG_SELECTION && AUTH_FAILED=0 || AUTH_FAILED=1
        [ "$AUTH_FAILED" == 1 ] && kdialog --title "Package reinstaller" --error "You do not have administrative permissions required to reinstall software packages.\nYou must be a member of the group \"wheel\"." &> /dev/null && exit 1

        # Reinstall packages
        notify-send --urgency=low --app-name="Package reinstaller" --icon="package-reinstall" --category=network "Reinstalling packages..." "This may take a while." &> /dev/null
        sudo pacman --noconfirm --asdeps -Sy $PKG_SELECTION && AUTH_FAILED=0 || AUTH_FAILED=1
        [ "$AUTH_FAILED" == 1 ] && kdialog --title "Package reinstaller" --error "The following packages failed to install:\n$PKG_SELECTION\n\nPlease verify that you are connected to the internet and you are a member of the group \"wheel\"." &> /dev/null && exit 1

        # Mark explicit packages
        notify-send --urgency=low --app-name="Package reinstaller" --icon="package-reinstall" --category=network "Cleaning up..." &> /dev/null
        for PKG in $EXP_PKGS; do
            sudo pacman --asexplicit -D $PKG && AUTH_FAILED=0 || AUTH_FAILED=1
            [ "$AUTH_FAILED" == 1 ] && kdialog --title "Package reinstaller" --error "You do not have administrative permissions required to reinstall software packages.\nYou must be a member of the group \"wheel\"." &> /dev/null && exit 1
        done
    fi
    notify-send --urgency=low --app-name="Package reinstaller" --icon="package-reinstall" --category=network "Finished reinstalling packages." "It is strongly recommended to perform a full software update." &> /dev/null
else echo "Cancelled."; fi

# Uncomment HoldPkg
sudo sed -i '/HoldPkg/s/^#//g' /etc/pacman.conf && AUTH_FAILED=0 || AUTH_FAILED=1
[ "$AUTH_FAILED" == 1 ] && kdialog --title "Package reinstaller" --error "You do not have administrative permissions required to reinstall software packages.\nYou must be a member of the group \"wheel\"." &> /dev/null && exit 1
