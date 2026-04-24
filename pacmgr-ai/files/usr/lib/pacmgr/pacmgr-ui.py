#!/usr/bin/env python3
import sys
import gi
gi.require_version('Gtk', '4.0')
from gi.repository import Gtk, Gio
from pacmgr_common import load_settings, save_settings

class PacmgrSettingsWindow(Gtk.ApplicationWindow):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.set_title("Arch Update Settings")
        self.set_default_size(400, 500)
        self.settings = load_settings()

        grid = Gtk.Grid(margin_start=20, margin_end=20, margin_top=20, margin_bottom=20, row_spacing=10, column_spacing=15)
        self.set_child(grid)

        # Helper to create rows
        self.row_idx = 0
        
        # UI Elements
        self.freq_entry = self.add_entry(grid, "Check Frequency (e.g., 1 week):", self.settings.get('CheckFrequency'))
        self.delay_entry = self.add_entry(grid, "Check Delay (e.g., 0 seconds):", self.settings.get('CheckDelay'))
        
        self.news_switch = self.add_switch(grid, "Show News:", self.settings.getboolean('ShowNews'))
        self.dl_switch = self.add_switch(grid, "Auto Download:", self.settings.getboolean('AutoDownload'))
        
        self.install_combo = self.add_combo(grid, "Auto Install:", ["off", "background", "shutdown"], self.settings.get('AutoInstall'))
        self.method_combo = self.add_combo(grid, "Install Method:", ["ask", "automatic-background", "automatic-terminal", "manual-terminal"], self.settings.get('InstallMethod'))
        
        self.aur_switch = self.add_switch(grid, "Include AUR:", self.settings.getboolean('IncludeAUR'))
        self.notify_switch = self.add_switch(grid, "Notifications:", self.settings.getboolean('Notifications'))
        self.cache_switch = self.add_switch(grid, "Clean Cache:", self.settings.getboolean('CleanCache'))

        save_btn = Gtk.Button(label="Save Settings")
        save_btn.connect("clicked", self.on_save_clicked)
        grid.attach(save_btn, 0, self.row_idx, 2, 1)

    def add_entry(self, grid, label_text, default):
        label = Gtk.Label(label=label_text, halign=Gtk.Align.START)
        entry = Gtk.Entry()
        entry.set_text(default)
        grid.attach(label, 0, self.row_idx, 1, 1)
        grid.attach(entry, 1, self.row_idx, 1, 1)
        self.row_idx += 1
        return entry

    def add_switch(self, grid, label_text, active):
        label = Gtk.Label(label=label_text, halign=Gtk.Align.START)
        switch = Gtk.Switch(active=active, halign=Gtk.Align.END)
        grid.attach(label, 0, self.row_idx, 1, 1)
        grid.attach(switch, 1, self.row_idx, 1, 1)
        self.row_idx += 1
        return switch

    def add_combo(self, grid, label_text, options, default):
        label = Gtk.Label(label=label_text, halign=Gtk.Align.START)
        combo = Gtk.DropDown.new_from_strings(options)
        try:
            combo.set_selected(options.index(default))
        except ValueError:
            combo.set_selected(0)
        grid.attach(label, 0, self.row_idx, 1, 1)
        grid.attach(combo, 1, self.row_idx, 1, 1)
        self.row_idx += 1
        return combo

    def on_save_clicked(self, button):
        install_opts = ["off", "background", "shutdown"]
        method_opts = ["ask", "automatic-background", "automatic-terminal", "manual-terminal"]
        
        new_settings = {
            'CheckFrequency': self.freq_entry.get_text(),
            'CheckDelay': self.delay_entry.get_text(),
            'ShowNews': str(self.news_switch.get_active()).lower(),
            'AutoDownload': str(self.dl_switch.get_active()).lower(),
            'AutoInstall': install_opts[self.install_combo.get_selected()],
            'InstallMethod': method_opts[self.method_combo.get_selected()],
            'IncludeAUR': str(self.aur_switch.get_active()).lower(),
            'Notifications': str(self.notify_switch.get_active()).lower(),
            'CleanCache': str(self.cache_switch.get_active()).lower()
        }
        save_settings(new_settings)
        self.close()

class PacmgrApp(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="com.arch.pacmgr.settings")

    def do_activate(self):
        win = PacmgrSettingsWindow(application=self)
        win.present()

if __name__ == "__main__":
    app = PacmgrApp()
    app.run(sys.argv)