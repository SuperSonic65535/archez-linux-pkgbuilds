#!/usr/bin/env python3
import sys
import os
import time
import subprocess
import grp
import gi

gi.require_version('Gtk', '4.0')
gi.require_version('Vte', '3.91')
gi.require_version('AppIndicator3', '0.1')
from gi.repository import Gtk, GLib, Vte, Gio, AppIndicator3
from pacmgr_common import load_settings, parse_time_string, DATA_DIR, LAST_UPDATE_FILE

class UpdateTerminal(Gtk.ApplicationWindow):
    def __init__(self, app, title="Update Progress"):
        super().__init__(application=app)
        self.set_title(title)
        self.set_default_size(800, 600)
        
        # Prevent easy closing
        self.connect("close-request", self.on_close_request)
        
        # VTE Setup
        self.terminal = Vte.Terminal()
        self.terminal.set_colors(
            foreground=Gdk.RGBA(1, 1, 1, 1), 
            background=Gdk.RGBA(0, 0, 0, 1), 
            palette=[]
        )
        self.set_child(self.terminal)

    def on_close_request(self, window):
        # Dialog: Are you sure?
        dialog = Gtk.MessageDialog(
            transient_for=self,
            modal=True,
            message_type=Gtk.MessageType.WARNING,
            buttons=Gtk.ButtonsType.YES_NO,
            text="Are you sure?\nIf you cancel the update now, your operating system may become corrupted and unuseable."
        )
        response = dialog.run()
        dialog.destroy()
        if response == Gtk.ResponseType.YES:
            subprocess.run(["pkexec", "killall", "pacman", "yay"])
            sys.exit(1)
        return True # Prevent closing if NO

class PacmgrDaemon(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="com.arch.pacmgr.daemon")
        self.settings = load_settings()
        self.pacman_pkgs = []
        self.aur_pkgs = []
        
        # Tray setup (Ayatana AppIndicator)
        self.indicator = AppIndicator3.Indicator.new(
            "pacmgr", "update-none", AppIndicator3.IndicatorCategory.APPLICATION_STATUS
        )
        self.indicator.set_status(AppIndicator3.IndicatorStatus.PASSIVE) # Hidden initially
        
    def check_permissions_and_time(self):
        # 1. Check wheel group
        try:
            wheel_group = grp.getgrnam('wheel')
            if os.getlogin() not in wheel_group.gr_mem: sys.exit(0)
        except KeyError: sys.exit(0)

        # 2. Check early exit conditions
        notify = self.settings.getboolean('Notifications')
        auto_dl = self.settings.getboolean('AutoDownload')
        auto_inst = self.settings.get('AutoInstall') != 'off'
        
        if not notify and not auto_dl and not auto_inst:
            sys.exit(0)

        # 3. Check time
        freq_secs = parse_time_string(self.settings.get('CheckFrequency'))
        delay_secs = parse_time_string(self.settings.get('CheckDelay'))
        
        last_update = 0
        if os.path.exists(LAST_UPDATE_FILE):
            with open(LAST_UPDATE_FILE, 'r') as f:
                last_update = float(f.read().strip())
                
        time_passed = time.time() - last_update
        if delay_secs != 0:
            time_passed += delay_secs
            
        if time_passed < freq_secs:
            sys.exit(0)

    def send_notification(self, title, body, icon, action_name=None, action_target=None):
        if not self.settings.getboolean('Notifications'): return
        notification = Gio.Notification.new(title)
        notification.set_body(body)
        notification.set_icon(Gio.ThemedIcon.new(icon))
        
        if action_name:
            notification.add_button("Update", f"app.{action_target}")
            
        self.send_notification(None, notification)

    def get_updates(self):
        # Using checkupdates (pacman-contrib) to safely check without root lock
        try:
            pacman_out = subprocess.check_output(["checkupdates"]).decode('utf-8')
            self.pacman_pkgs = [line.split()[0] for line in pacman_out.strip().split('\n') if line]
        except subprocess.CalledProcessError:
            pass # checkupdates returns 2 if no updates

        if self.settings.getboolean('IncludeAUR'):
            try:
                yay_out = subprocess.check_output(["yay", "-Qu"]).decode('utf-8')
                self.aur_pkgs = [line.split()[0] for line in yay_out.strip().split('\n') if line]
            except subprocess.CalledProcessError:
                pass

        if not self.pacman_pkgs and not self.aur_pkgs:
            sys.exit(0) # No updates

    def do_activate(self):
        self.check_permissions_and_time()
        self.get_updates()
        
        total_pac = len(self.pacman_pkgs)
        total_aur = len(self.aur_pkgs)
        all_pkg_names = " ".join(self.pacman_pkgs + self.aur_pkgs)

        # Register notification action
        action = Gio.SimpleAction.new("start_update", None)
        action.connect("activate", self.on_start_update)
        self.add_action(action)

        if self.settings.getboolean('AutoDownload'):
            self.perform_download()

        auto_install = self.settings.get('AutoInstall') != 'off'
        
        if not self.settings.getboolean('Notifications') and not auto_install:
            sys.exit(0)

        if not auto_install:
            # Wait for user
            self.indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)
            self.indicator.set_icon("update-medium-symbolic")
            
            body = f"{total_pac + total_aur} updates available ({total_pac} + {total_aur} AUR)\n{all_pkg_names}"
            self.send_notification("Updates available", body, "update-medium-symbolic", "Update", "start_update")
            
            # Setup Tray Menu
            menu = Gtk.Menu()
            item_update = Gtk.MenuItem(label="Update now")
            item_update.connect('activate', lambda _: self.on_start_update(None, None))
            menu.append(item_update)
            
            item_quit = Gtk.MenuItem(label="Quit")
            item_quit.connect('activate', lambda _: sys.exit(0))
            menu.append(item_quit)
            
            menu.show_all()
            self.indicator.set_menu(menu)
        else:
            self.on_start_update(None, None)

    def perform_download(self):
        self.send_notification("Downloading pacman packages", 
            f"Downloading {len(self.pacman_pkgs)} updates\nThis may take a while depending on the number of packages and your internet connection speed.", 
            "download-symbolic")
        # Network retry logic
        for attempt in range(5):
            res = subprocess.run(["pkexec", "pacman", "-Sw", "--noconfirm"] + self.pacman_pkgs)
            if res.returncode == 0: break
            time.sleep(10)
            
    def show_news(self):
        if self.settings.getboolean('ShowNews'):
            # Placeholder for archlinux-news extraction
            dialog = Gtk.MessageDialog(
                message_type=Gtk.MessageType.INFO,
                buttons=Gtk.ButtonsType.NONE,
                text="Arch Linux News\n\n(Latest news regarding your packages will appear here.)"
            )
            dialog.add_button("Continue", Gtk.ResponseType.OK)
            dialog.add_button("Quit", Gtk.ResponseType.CANCEL)
            response = dialog.run()
            dialog.destroy()
            if response == Gtk.ResponseType.CANCEL:
                sys.exit(0)

    def on_start_update(self, action, param):
        self.show_news()
        
        method = self.settings.get('InstallMethod')
        # Logic to handle 'ask' vs others would map to a UI dialog if 'ask'
        
        if method in ["automatic-terminal", "manual-terminal"]:
            self.term_win = UpdateTerminal(self)
            self.term_win.present()
            
            cmd_pacman = ["pkexec", "pacman", "-Syu"]
            if method == "automatic-terminal":
                cmd_pacman.append("--noconfirm")
                
            # Execute in VTE (simplified spawn)
            self.term_win.terminal.spawn_async(
                Vte.PtyFlags.DEFAULT,
                None, cmd_pacman, None,
                GLib.SpawnFlags.DEFAULT, None, None, -1, None, None
            )
            
            # Note: You would chain the `yay` execution via the VTE's `child-exited` signal
        
        elif method == "automatic-background":
            self.send_notification("Installing pacman packages", 
                f"Installing {len(self.pacman_pkgs)} updates\nPlease keep your device on. This shouldn't take very long.", 
                "update-busy-symbolic")
            subprocess.run(["pkexec", "pacman", "--noconfirm", "-Syu"])
            
            if self.settings.getboolean('IncludeAUR') and self.aur_pkgs:
                self.send_notification("AUR install", 
                    f"Building {len(self.aur_pkgs)} AUR updates\nPlease keep your device on. This may take a while...", 
                    "run-build-symbolic")
                subprocess.run(["yay", "--noconfirm", "--answerclean", "None", "--answerdiff", "None", "--answeredit", "None", "--answerupgrade", "None", "--removemake", "--devel", "--pgpfetch", "--sudoloop", "-Syu"])

        self.finish_update()

    def finish_update(self):
        # Update timestamp
        with open(LAST_UPDATE_FILE, 'w') as f:
            f.write(str(time.time()))
            
        self.send_notification("Update complete", "Your system is now up to date and ready to use.", "data-success")
        sys.exit(0)

if __name__ == "__main__":
    app = PacmgrDaemon()
    app.run(sys.argv)