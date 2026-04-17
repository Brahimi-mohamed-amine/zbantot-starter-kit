# Quick Start Guide

## What Was Created

You now have a complete Arch Linux setup automation script. Here's what's in the repo:

### Files
- **setup.sh** - The main script (executable, ready to use)
- **packages.txt** - List of packages to install via pacman
- **aur-packages.txt** - List of packages to install via AUR
- **configs/** - Your configuration files (will be auto-deployed)
  - `.bashrc` - Example bash config
  - `doas.conf` - Template for sudo replacement
  - `.config/` - For application configs

## How to Use It

### On Your Current PC (Test it)

```bash
# Navigate to the script
cd /home/zbantot/zbantot-starter-kit

# Look at what it will do
cat setup.sh      # Read the main script
cat packages.txt  # See what packages it installs
cat README.md     # Full documentation
```

### On Your Other PC (Fresh Arch Install)

```bash
# 1. Clone the repository
git clone https://github.com/your-username/zbantot-starter-kit.git
cd zbantot-starter-kit

# 2. (Optional) Check what will be installed
cat packages.txt
cat aur-packages.txt
ls -R configs/

# 3. Run the script
./setup.sh

# Done! Your system is configured
```

## What The Script Does (In Order)

1. **Checks prerequisites** - Verifies internet, sudo access, not running as root
2. **Creates backups** - Timestamped backup directory at `~/arch-setup-backups/`
3. **Updates system** - Runs `sudo pacman -Syu`
4. **Installs yay** - AUR helper (if not already installed)
5. **Installs packages** - All packages from `packages.txt`
6. **Installs AUR packages** - All packages from `aur-packages.txt`
7. **Deploys configs** - Copies all files from `configs/` to your home directory
8. **Configures doas** - Sets up `/etc/doas.conf` for passwordless sudo
9. **Logs everything** - Creates `setup.log` with all details

## What You Can Customize

### Add More Packages

```bash
# 1. Edit the package lists
vim packages.txt        # System packages via pacman
vim aur-packages.txt    # Packages from AUR

# 2. Commit to git
git add .
git commit -m "Add more packages"
git push
```

### Add Your Own Configs

After you configure something on your system:

```bash
# 1. Create directory structure (mirrors home directory)
mkdir -p configs/.config/yourapp

# 2. Copy your config
cp ~/.config/yourapp/config configs/.config/yourapp/config

# 3. Commit to git
git add .
git commit -m "Add yourapp with config"
git push

# 4. On next install, it will be auto-deployed!
```

## Where Your Backups Go

```
~/arch-setup-backups/
├── 2026-04-17-144230/          # First run
│   ├── old-configs/             # Previous configs (if any)
│   └── setup.log                # What was installed
├── 2026-04-18-100230/          # Second run (if you run again)
│   ├── old-configs/
│   └── setup.log
└── ...
```

If something breaks, restore from the backup:

```bash
cp ~/arch-setup-backups/2026-04-17-144230/old-configs/.bashrc ~/.bashrc
```

## Troubleshooting

### Script fails with "sudo access required"
Your user needs to be in the sudoers group:
```bash
su - root
usermod -aG wheel YOUR_USERNAME
exit
```

### Package installation fails
The script will ask: **Retry / Skip / Abort**
- Retry: Try again (useful for AUR timeouts)
- Skip: Continue with other packages
- Abort: Stop the script

### Check what went wrong
Look at the log:
```bash
cat ~/arch-setup-backups/2026-04-17-144230/setup.log
```

## Next Steps

1. **Test the script** on your other PC
2. **Add your packages** as you configure them
3. **Add your configs** to `configs/` directory
4. **Keep it updated** in git
5. **Use it** for every fresh install!

## Example Workflow

```bash
# 1. Fresh Arch install on new PC
git clone https://github.com/your-username/zbantot-starter-kit.git
cd zbantot-starter-kit
./setup.sh
# Everything is set up!

# 2. Manual install a new package
sudo pacman -S neovim
vim ~/.config/nvim/init.vim
# Configure it

# 3. Add it to your automation
echo "neovim" >> packages.txt
mkdir -p configs/.config/nvim
cp ~/.config/nvim/init.vim configs/.config/nvim/
git add .
git commit -m "Add neovim with config"
git push

# 4. Next fresh install: ./setup.sh does it all!
```

## File Organization

```
configs/              # Mirrors home directory structure
├── .bashrc           # → ~/.bashrc
├── .zshrc            # → ~/.zshrc
├── doas.conf         # → Special handling by script
└── .config/
    ├── nvim/
    │   └── init.vim  # → ~/.config/nvim/init.vim
    ├── alacritty/
    │   └── alacritty.toml  # → ~/.config/alacritty/alacritty.toml
    └── ...

packages.txt          # Packages to install
aur-packages.txt      # AUR packages to install
setup.sh              # Main automation script
README.md             # Full documentation
```

---

**Ready to test on your other PC?** Just clone the repo and run `./setup.sh`!
