if [ ! -f "$HOME/.config/dotfiles-installer" ]; then
	case $USER in
		live) DOTFILES_DIR="/etc/dotfiles.d/live";;
		root) DOTFILES_DIR="/etc/dotfiles.d/root";;
		*) DOTFILES_DIR="/etc/dotfiles.d/user";;
	esac; if [ -d "$DOTFILES_DIR" ]; then
		if [ -d "/etc/dotfiles.d/user" ]; then
			for FOUND_FILE in $(ls -Aw 1 "/etc/dotfiles.d/user"); do
				cp -r "/etc/dotfiles.d/user/$FOUND_FILE" "$HOME/"
			done
		fi; if [ "$DOTFILES_DIR" != "/etc/dotfiles.d/user" ]; then
			for FOUND_FILE in $(ls -Aw 1 "$DOTFILES_DIR"); do
				cp -r "$DOTFILES_DIR/$FOUND_FILE" "$HOME/"
			done
		fi; mkdir -p "$HOME/.config"; touch "$HOME/.config/dotfiles-installer"
	fi
fi
