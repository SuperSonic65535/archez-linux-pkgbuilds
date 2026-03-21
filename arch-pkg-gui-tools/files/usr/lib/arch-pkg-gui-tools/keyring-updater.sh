#!/bin/sh
ps cax | grep pacman-key &> /dev/null && UPDATE_IN_PROGRESS=1 || UPDATE_IN_PROGRESS=0
if [ $UPDATE_IN_PROGRESS == 1 ]; then
    notify-send --urgency=low --app-name="Keyring updater" --icon=database-change-key --category=network "Pacman keyring update already in progress" "Pacman keyring update is already in progress. This will take a while. You will be notified when this is done."
    while [ $UPDATE_IN_PROGRESS == 1 ]; do
        ps cax | grep pacman-key &> /dev/null && UPDATE_IN_PROGRESS=1 || UPDATE_IN_PROGRESS=0
        sleep 1
    done
    notify-send --urgency=low --expire-time=0 --app-name="Keyring updater" --icon=database-change-key --category=network "Pacman keyring update complete" "You may now install software packages."
else
    notify-send --urgency=low --app-name="Keyring updater" --icon=database-change-key --category=network "Updating Pacman keyring" "This will take a while. You will be notified when this is done."
    AUTH_FAILED=0; pkexec pacman-key --refresh-keys || AUTH_FAILED=1
    if [ $AUTH_FAILED == 1 ]; then
        notify-send --urgency=low --app-name="Keyring updater" --icon=database-change-key --category=network "Authorisation failed" "Could not get administrative privileges required to update Pacman keyring."
    else
        notify-send --urgency=low --expire-time=0 --app-name="Keyring updater" --icon=database-change-key --category=network "Pacman keyring update complete" "You may now install software packages."
    fi
fi
