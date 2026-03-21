#!/bin/sh
pacman -Syu; exitCode=$?
if [ $exitCode -gt 0 ]; then
	tput bel; echo; echo "[ERROR] An error occured. Please see above for details."
	echo "Press ENTER to close this window."; read; exit $exitCode
else
	tput bel; echo; echo "[DONE] Upgrade complete - you may now close this window (press ENTER)"
	read; exit 0
fi
