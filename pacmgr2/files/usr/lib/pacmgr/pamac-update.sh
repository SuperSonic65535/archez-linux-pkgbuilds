#!/bin/sh
groups $(whoami) | grep wheel && \
sudo /usr/lib/pacmgr/pacman-repo-update.sh || \
pkexec /usr/lib/pacmgr/pacman-repo-update.sh
pamac-manager --updates $@ &> /dev/null
