#!/bin/bash

# Brave Browser Desktop Integration Setup Script
# This script properly installs the Brave browser desktop entry

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BRAVE_BINARY="${HOME}/.local/bin/Brave"
BRAVE_ICON="${HOME}/.local/share/icons/brave.png"
APPLICATIONS_DIR="${HOME}/.local/share/applications"
DESKTOP_FILE="${APPLICATIONS_DIR}/brave.desktop"
DESKTOP_DIR="${HOME}/Desktop"

echo -e "${GREEN}=== Brave Browser Desktop Integration Setup ===${NC}\n"

# Check if Brave binary exists
if [ ! -f "$BRAVE_BINARY" ]; then
    echo -e "${RED}Error: Brave binary not found at ${BRAVE_BINARY}${NC}"
    echo "Please ensure Brave AppImage is located at ${BRAVE_BINARY}"
    exit 1
fi

# Make Brave AppImage executable
echo -e "${YELLOW}Making Brave AppImage executable...${NC}"
chmod +x "$BRAVE_BINARY"
echo -e "${GREEN}✓ Brave AppImage is now executable${NC}\n"

# Disable AppImage integration prompt
# This prevents the "Do you want to integrate this application?" dialog
echo -e "${YELLOW}Disabling AppImage integration prompt...${NC}"
if [ ! -f "${HOME}/.config/appimagekit/no_desktopintegration" ]; then
    mkdir -p "${HOME}/.config/appimagekit"
    touch "${HOME}/.config/appimagekit/no_desktopintegration"
    echo -e "${GREEN}✓ AppImage integration prompt disabled${NC}\n"
else
    echo -e "${GREEN}✓ AppImage integration prompt already disabled${NC}\n"
fi

# Check if icon exists
if [ ! -f "$BRAVE_ICON" ]; then
    echo -e "${YELLOW}Warning: Icon not found at ${BRAVE_ICON}${NC}"
    echo "The desktop entry will still work, but without an icon."
    echo "You can download the Brave icon and place it at ${BRAVE_ICON}"
    echo ""
fi

# Create applications directory if it doesn't exist
mkdir -p "$APPLICATIONS_DIR"

# Copy desktop file and update paths
echo -e "${YELLOW}Installing desktop entry...${NC}"
cp "$(dirname "$0")/brave.desktop" "$DESKTOP_FILE"
# Replace HOME_PATH placeholder with actual home directory
sed -i "s|HOME_PATH|${HOME}|g" "$DESKTOP_FILE"
chmod 644 "$DESKTOP_FILE"
echo -e "${GREEN}✓ Desktop entry installed at ${DESKTOP_FILE}${NC}\n"

# Create Desktop directory if it doesn't exist
if [ ! -d "$DESKTOP_DIR" ]; then
    echo -e "${YELLOW}Creating Desktop directory...${NC}"
    mkdir -p "$DESKTOP_DIR"
    echo -e "${GREEN}✓ Desktop directory created${NC}\n"
fi

# Copy desktop file to Desktop for easy access
echo -e "${YELLOW}Creating desktop shortcut...${NC}"
cp "$DESKTOP_FILE" "$DESKTOP_DIR/brave.desktop"
chmod 755 "$DESKTOP_DIR/brave.desktop"
# The desktop file already has paths replaced from the earlier copy

# Try to mark it as trusted (for some desktop environments)
if command -v gio &> /dev/null; then
    gio set "$DESKTOP_DIR/brave.desktop" metadata::trusted true 2>/dev/null || true
fi

echo -e "${GREEN}✓ Desktop shortcut created${NC}\n"

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    echo -e "${YELLOW}Updating desktop database...${NC}"
    update-desktop-database "$APPLICATIONS_DIR" 2>/dev/null || true
    echo -e "${GREEN}✓ Desktop database updated${NC}\n"
fi

echo -e "${GREEN}=== Installation Complete! ===${NC}\n"
echo -e "Brave browser should now be:"
echo -e "  1. Available in your application menu"
echo -e "  2. Available as a shortcut on your Desktop"
echo -e "  3. No longer show integration dialogs when launched\n"
echo -e "${YELLOW}Note:${NC} You may need to:"
echo -e "  - Log out and log back in for changes to take full effect"
echo -e "  - Right-click the desktop icon and select 'Allow Launching' (on some systems)"
echo -e "  - Refresh your desktop (F5 or right-click > refresh)\n"
