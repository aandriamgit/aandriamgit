# Quick Fix for Brave Desktop Issues

## Your Specific Issues

### Issue 1: Desktop entry not working
**Current setup:**
- File: `/home/aandriam/.local/share/applications/brave.desktop`
- Brave location: `/home/aandriam/.local/bin/Brave`
- Icon: `/home/aandriam/.local/share/icons/brave.png`

**Problem:** The desktop entry you created might be missing some important fields or have permission issues.

**Solution:** Use our improved `.desktop` file that includes:
- Proper MIME types for handling web links
- Action menu support (New Window, Private Window)
- Correct startup notifications
- `--no-sandbox` flag for compatibility

### Issue 2: AppImage shows something when double-clicking
**What you're seeing:** A dialog asking about "integrating this application" or similar.

**Why it happens:** AppImages have built-in integration that triggers on double-click. This is AppImageKit's feature, but it can be annoying and doesn't always work properly.

**Solution:** Disable it by creating:
```bash
mkdir -p ~/.config/appimagekit
touch ~/.config/appimagekit/no_desktopintegration
```

This tells all AppImages to skip the integration dialog.

## One-Command Fix

Just run this and everything will be set up correctly:

```bash
cd ~/path/to/this/repo/brave-setup
./install-brave-desktop.sh
```

The script will:
1. ✓ Make Brave executable
2. ✓ Disable the annoying AppImage dialog
3. ✓ Install proper desktop entry
4. ✓ Create desktop shortcut
5. ✓ Update application menu

## What Changed

### Old .desktop file (yours):
```ini
[Desktop Entry]
Name=Brave
Comment=Navigateur web Brave
Exec=/home/aandriam/.local/bin/Brave
Icon=/home/aandriam/.local/share/icons/brave.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
```

### New .desktop file (ours):
```ini
[Desktop Entry]
Name=Brave Browser
Comment=Brave Web Browser
Exec=/home/aandriam/.local/bin/Brave --no-sandbox %U
Icon=/home/aandriam/.local/share/icons/brave.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;...
StartupNotify=true
StartupWMClass=brave-browser
Actions=NewWindow;NewPrivateWindow;

[Desktop Action NewWindow]
Name=New Window
Exec=/home/aandriam/.local/bin/Brave --no-sandbox

[Desktop Action NewPrivateWindow]
Name=New Private Window
Exec=/home/aandriam/.local/bin/Brave --no-sandbox --incognito
```

### Key improvements:
1. **`%U` in Exec**: Allows opening URLs passed to Brave
2. **`--no-sandbox`**: Fixes common launch issues on Linux
3. **MIME types**: Makes Brave handle web links properly
4. **Actions menu**: Right-click context menu with options
5. **StartupWMClass**: Helps window manager identify Brave windows

## Manual Fix (if you prefer)

If you want to do it manually instead of using the script:

### Step 1: Fix the AppImage Dialog
```bash
mkdir -p ~/.config/appimagekit
touch ~/.config/appimagekit/no_desktopintegration
```

### Step 2: Make Brave Executable
```bash
chmod +x ~/.local/bin/Brave
```

### Step 3: Replace Desktop File
```bash
# Backup your old file
cp ~/.local/share/applications/brave.desktop ~/.local/share/applications/brave.desktop.old

# Copy the new one
cp brave.desktop ~/.local/share/applications/brave.desktop
chmod 644 ~/.local/share/applications/brave.desktop
```

### Step 4: Create Desktop Shortcut
```bash
cp ~/.local/share/applications/brave.desktop ~/Desktop/brave.desktop
chmod 755 ~/Desktop/brave.desktop

# On GNOME, you might need to mark it as trusted
gio set ~/Desktop/brave.desktop metadata::trusted true
```

### Step 5: Update Application Menu
```bash
update-desktop-database ~/.local/share/applications/
```

### Step 6: Refresh
Log out and log back in, or refresh your desktop (F5).

## Verify It's Working

Run the diagnostic script:
```bash
./check-brave-setup.sh
```

It will tell you if everything is set up correctly.

## Still Having Issues?

### Desktop icon doesn't launch
Right-click it and select "Allow Launching" or "Properties" → "Permissions" → "Allow executing file as program"

### Not in application menu
- Log out and log back in
- Or run: `update-desktop-database ~/.local/share/applications/`

### AppImage still shows dialog
Make sure the file exists and is empty:
```bash
ls -l ~/.config/appimagekit/no_desktopintegration
```

### Brave won't start at all
Try running from terminal to see error:
```bash
~/.local/bin/Brave --no-sandbox
```

## Questions?

See the full documentation: [README.md](README.md)
