#!/bin/bash

# ==============================================================================
# ARCH LINUX POST-INSTALLATION SCRIPT
# Edit the variables and add your GitHub URLs below!
# ==============================================================================

# --- YOUR GITHUB URLS ---
SRC_REPO="https://github.com/YOUR_USERNAME/YOUR_DOTFILES_REPO.git"
#DWM_REPO="https://github.com/YOUR_USERNAME/YOUR_DWM_REPO.git"
#ST_REPO="https://github.com/YOUR_USERNAME/YOUR_ST_REPO.git"
#DMENU_REPO="https://github.com/YOUR_USERNAME/YOUR_DMENU_REPO.git"
#DWMBLOCKS_REPO="https://github.com/YOUR_USERNAME/YOUR_DWMBLOCKS_REPO.git"

# ==============================================================================
# PHASE 1: INITIALIZATION & SYSTEM UPDATE
# ==============================================================================
echo "[+] Starting Arch Setup Script..."
echo "[+] Requesting administrator privileges..."
sudo -v # Caches the sudo password so it doesn't prompt you constantly

echo "[+] Updating system..."
sudo pacman -Syu --noconfirm

# ==============================================================================
# PHASE 2: OFFICIAL PACKAGE INSTALLATION
# ==============================================================================
echo "[+] Installing official packages from packages.txt..."
# Read the packages.txt file and pass it to pacman
sudo pacman -S --needed --noconfirm - < packages.txt

# ==============================================================================
# PHASE 3: AUR HELPER SETUP (YAY)
# ==============================================================================
echo "[+] Installing AUR helper (yay)..."
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay-bin
else
    echo "[+] yay is already installed, skipping..."
fi

# ==============================================================================
# PHASE 4: AUR PACKAGE INSTALLATION
# ==============================================================================
echo "[+] Installing AUR packages from aur_packages.txt..."
yay -S --needed --noconfirm - < aur_packages.txt

# ==============================================================================
# PHASE 5: DIRECTORY SKELETON
# ==============================================================================
echo "[+] Creating standard directories..."
# mkdir -p creates the directory, and its parents if needed. It won't error if it exists.
#mkdir -p ~/src
mkdir -p ~/.config
mkdir -p ~/Documents
mkdir -p ~/Downloads
mkdir -p ~/Pictures/Wallpapers
mkdir -p ~/suckless
mkdir -p ~/scripts

# ==============================================================================
# PHASE 6: DOTFILES
# ==============================================================================
echo "[+] Downloading and applying dotfiles..."
# Clone dotfiles to a temporary folder
git clone "$SRC_REPO" ~/src

# Copy the contents into your home directory (Example: copying to ~/.config)
# Adjust these paths based on how your dotfiles repo is structured!
cp -r ~/src/dotfiles/* ~/.config/

# Clean up the temp dotfiles folder
#rm -rf /tmp/my-dotfiles

# ==============================================================================
# PHASE 7: SUCKLESS COMPILATION (dwm, st, dmenu, dwmblocks)
# ==============================================================================
echo "[+] Compiling suckless tools..."

# Build dwm
#git clone "$DWM_REPO" ~/src/suckless/dwm
cd ~/src/suckless/dwm
sudo make install clean

# Build st
#git clone "$ST_REPO" ~/src/suckless/st
cd ~/src/suckless/st
sudo make install clean

# Build dmenu
#git clone "$DMENU_REPO" ~/suckless/dmenu
cd ~/src/suckless/dmenu
sudo make install clean

# Build dwmblocks
#git clone "$DWMBLOCKS_REPO" ~/suckless/dwmblocks
cd ~/src/suckless/dwmblocks
sudo make install clean

# Go back to home directory
cd ~

# ==============================================================================
# PHASE 8: MANUAL FILE & TEXT MANIPULATIONS (YOUR CUSTOM EDITS)
# ==============================================================================
echo "[+] Applying manual configurations..."

# --- 1. REPLACE TEXT IN A FILE ---
# Use 'sed' to search and replace text. Format: sed -i 's/OLD_TEXT/NEW_TEXT/g' file
# Example: Uncommenting "Color" in pacman.conf to make pacman output colorful
sudo sed -i 's/#Color/Color/g' /etc/pacman.conf

# --- 2. ADD TEXT TO THE END OF A FILE ---
# Use 'echo' with '>>' to append.
# Example: Setting the default text editor in bashrc
echo "export EDITOR=nvim" >> ~/.bashrc

# --- 3. CREATE A NEW MULTI-LINE FILE FROM SCRATCH ---
# Use "Heredocs" (cat << 'EOF' > file). Everything between the EOFs goes in the file.
# Example: Creating an .xinitrc to start dwm when you type 'startx'
cat << 'EOF' > ~/.xinitrc
setxkbmap -layout us,ara -variant -option grp:alts_toggle caps:swapescape &
sxhkd &
dwmblocks &
dwm 
EOF


# --- 4. DELETE UNWANTED FILES OR DIRECTORIES ---
# Use rm -rf to forcefully remove things. BE VERY CAREFUL WITH THIS.
# Example: Removing a default config you don't like
# rm -rf ~/.config/some_default_folder

# ==============================================================================
# PHASE 9: SERVICES & CLEANUP
# ==============================================================================
echo "[+] Enabling system services..."
# Enable NetworkManager to start on boot
#sudo systemctl enable --now NetworkManager

echo "[================================================================]"
echo "[+] SETUP COMPLETE! Please double-check for errors, then reboot."
echo "[================================================================]"
