import os
import configparser
import time

CONFIG_DIR = os.path.expanduser("~/.config/pacmgr")
DATA_DIR = os.path.expanduser("~/.local/share/pacmgr")
SETTINGS_FILE = os.path.join(CONFIG_DIR, "settings.conf")
LAST_UPDATE_FILE = os.path.join(DATA_DIR, "lastupdate")

# Default configurations
DEFAULT_SETTINGS = {
    'CheckFrequency': '1 week',
    'CheckDelay': '0 seconds',
    'ShowNews': 'true',
    'AutoDownload': 'false',
    'AutoInstall': 'off',
    'InstallMethod': 'ask',
    'IncludeAUR': 'false',
    'Notifications': 'true',
    'CleanCache': 'false'
}

def ensure_dirs():
    os.makedirs(CONFIG_DIR, exist_ok=True)
    os.makedirs(DATA_DIR, exist_ok=True)

def load_settings():
    ensure_dirs()
    config = configparser.ConfigParser()
    if not os.path.exists(SETTINGS_FILE):
        config['Settings'] = DEFAULT_SETTINGS
        with open(SETTINGS_FILE, 'w') as f:
            config.write(f)
    else:
        config.read(SETTINGS_FILE)
    return config['Settings']

def save_settings(settings_dict):
    ensure_dirs()
    config = configparser.ConfigParser()
    config['Settings'] = settings_dict
    with open(SETTINGS_FILE, 'w') as f:
        config.write(f)

def parse_time_string(time_str):
    # Converts strings like "1 week", "30 seconds", "2 hours" to seconds
    parts = time_str.split()
    if len(parts) != 2: return 0
    val, unit = int(parts[0]), parts[1].lower()
    multipliers = {
        'second': 1, 'seconds': 1,
        'minute': 60, 'minutes': 60,
        'hour': 3600, 'hours': 3600,
        'day': 86400, 'days': 86400,
        'week': 604800, 'weeks': 604800,
        'month': 2592000, 'months': 2592000 # Approx 30 days
    }
    return val * multipliers.get(unit, 0)