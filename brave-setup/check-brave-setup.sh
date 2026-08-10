#!/bin/bash

# Brave Browser Setup Diagnostic Script
# This script checks your Brave browser installation and reports any issues

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BRAVE_BINARY="${HOME}/.local/bin/Brave"
BRAVE_ICON="${HOME}/.local/share/icons/brave.png"
APPLICATIONS_DIR="${HOME}/.local/share/applications"
DESKTOP_FILE="${APPLICATIONS_DIR}/brave.desktop"
DESKTOP_SHORTCUT="${HOME}/Desktop/brave.desktop"
APPIMAGE_CONFIG="${HOME}/.config/appimagekit/no_desktopintegration"

echo -e "${BLUE}=== Brave Browser Setup Diagnostic ===${NC}\n"

# Function to check a file/directory
check_item() {
    local item=$1
    local description=$2
    local is_dir=$3
    
    if [ "$is_dir" = "dir" ]; then
        if [ -d "$item" ]; then
            echo -e "${GREEN}✓${NC} $description: ${GREEN}EXISTS${NC}"
            ls -ld "$item" | awk '{print "  Permissions: " $1}'
        else
            echo -e "${RED}✗${NC} $description: ${RED}NOT FOUND${NC}"
            return 1
        fi
    else
        if [ -f "$item" ]; then
            echo -e "${GREEN}✓${NC} $description: ${GREEN}EXISTS${NC}"
            ls -l "$item" | awk '{print "  Permissions: " $1 "  Size: " $5}'
            if [ -x "$item" ]; then
                echo -e "  Executable: ${GREEN}YES${NC}"
            else
                echo -e "  Executable: ${YELLOW}NO${NC}"
            fi
        else
            echo -e "${RED}✗${NC} $description: ${RED}NOT FOUND${NC}"
            return 1
        fi
    fi
    return 0
}

issues_found=0

# Check Brave binary
echo -e "${YELLOW}Checking Brave Binary...${NC}"
if ! check_item "$BRAVE_BINARY" "Brave AppImage"; then
    ((issues_found++))
    echo -e "  ${YELLOW}Fix: Place Brave AppImage at ${BRAVE_BINARY}${NC}"
fi
echo ""

# Check Brave icon
echo -e "${YELLOW}Checking Brave Icon...${NC}"
if ! check_item "$BRAVE_ICON" "Brave Icon"; then
    ((issues_found++))
    echo -e "  ${YELLOW}Fix: Download icon and place at ${BRAVE_ICON}${NC}"
    echo -e "  ${YELLOW}Note: This is optional but recommended${NC}"
fi
echo ""

# Check applications directory
echo -e "${YELLOW}Checking Applications Directory...${NC}"
if ! check_item "$APPLICATIONS_DIR" "Applications directory" "dir"; then
    ((issues_found++))
    echo -e "  ${YELLOW}Fix: mkdir -p ${APPLICATIONS_DIR}${NC}"
fi
echo ""

# Check desktop file
echo -e "${YELLOW}Checking Desktop Entry...${NC}"
if ! check_item "$DESKTOP_FILE" "Desktop entry file"; then
    ((issues_found++))
    echo -e "  ${YELLOW}Fix: Run the installation script${NC}"
else
    # Validate desktop file content
    echo -e "  ${BLUE}Validating desktop file content...${NC}"
    if grep -q "Exec.*Brave" "$DESKTOP_FILE"; then
        echo -e "  ${GREEN}✓${NC} Exec line present"
    else
        echo -e "  ${RED}✗${NC} Exec line missing or incorrect"
        ((issues_found++))
    fi
    
    if grep -q "Icon=" "$DESKTOP_FILE"; then
        echo -e "  ${GREEN}✓${NC} Icon line present"
    else
        echo -e "  ${RED}✗${NC} Icon line missing"
        ((issues_found++))
    fi
fi
echo ""

# Check desktop shortcut
echo -e "${YELLOW}Checking Desktop Shortcut...${NC}"
if [ -d "${HOME}/Desktop" ]; then
    if ! check_item "$DESKTOP_SHORTCUT" "Desktop shortcut"; then
        ((issues_found++))
        echo -e "  ${YELLOW}Fix: Run the installation script${NC}"
    fi
else
    echo -e "${YELLOW}⚠${NC} Desktop directory not found"
    echo -e "  ${YELLOW}Note: Some desktop environments don't use ~/Desktop${NC}"
fi
echo ""

# Check AppImage integration config
echo -e "${YELLOW}Checking AppImage Integration Settings...${NC}"
if check_item "$APPIMAGE_CONFIG" "AppImage no-integration flag"; then
    echo -e "  ${GREEN}✓${NC} AppImage integration dialog is disabled"
else
    ((issues_found++))
    echo -e "  ${YELLOW}Warning: AppImage may show integration dialog${NC}"
    echo -e "  ${YELLOW}Fix: Run the installation script or:${NC}"
    echo -e "  ${YELLOW}      mkdir -p ~/.config/appimagekit${NC}"
    echo -e "  ${YELLOW}      touch ~/.config/appimagekit/no_desktopintegration${NC}"
fi
echo ""

# Check if Brave can be executed
echo -e "${YELLOW}Testing Brave Launch...${NC}"
if [ -f "$BRAVE_BINARY" ] && [ -x "$BRAVE_BINARY" ]; then
    echo -e "${GREEN}✓${NC} Brave is executable"
    echo -e "  ${BLUE}Testing version output...${NC}"
    
    # Try to get version (timeout after 5 seconds)
    if timeout 5s "$BRAVE_BINARY" --version 2>/dev/null | head -n 1; then
        echo -e "  ${GREEN}✓${NC} Brave responds to --version"
    else
        echo -e "  ${YELLOW}⚠${NC} Could not get version (this may be normal for AppImages)"
    fi
else
    echo -e "${RED}✗${NC} Cannot execute Brave"
    ((issues_found++))
fi
echo ""

# Summary
echo -e "${BLUE}=== Summary ===${NC}\n"
if [ $issues_found -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo -e "Brave browser should be working correctly.\n"
    echo -e "If you're still having issues:"
    echo -e "  1. Try logging out and logging back in"
    echo -e "  2. Refresh your desktop (F5 or right-click > refresh)"
    echo -e "  3. Check if desktop icons are enabled in your desktop environment"
    echo -e "  4. Try launching from the application menu instead"
else
    echo -e "${YELLOW}⚠ Found $issues_found issue(s)${NC}"
    echo -e "Please review the output above and apply the suggested fixes.\n"
    echo -e "To fix most issues automatically, run:"
    echo -e "  ${GREEN}./install-brave-desktop.sh${NC}"
fi
echo ""
