# Arch Linux Setup Script

A simple, readable automation script for fresh Arch Linux installations. Install packages, deploy configs, and configure your system with one command.

## Structure

```
arch-setup/
├── setup.sh                 # Main installation script
├── packages.txt            # List of pacman packages to install
├── aur-packages.txt        # List of AUR packages to install
├── configs/                # Configuration files to deploy
│   ├── .bashrc
│   ├── doas.conf
│   └── .config/
├── README.md               # This file
└── backups/                # Created automatically after first run
    └── YYYY-MM-DD-HHMMSS/
        ├── old-configs/    # Backups of your previous configs
        └── setup.log       # Complete log of what was installed
```

## Quick Start

### 1. Clone or Download This Repository

```bash
git clone <your-repo-url> arch-setup
cd arch-setup
```

### 2. (Optional) Customize

Edit the lists before running:

```bash
# Edit packages to install
vim packages.txt

# Edit AUR packages
vim aur-packages.txt
```

### 3. Run the Setup Script

```bash
./setup.sh
```

That's it! The script will:
- ✓ Update your system
- ✓ Install all packages from `packages.txt`
- ✓ Install all packages from `aur-packages.txt`
- ✓ Deploy config files from `configs/` directory
- ✓ Configure doas (if installed)
- ✓ Back up any existing configs before replacing them
- ✓ Log everything to `setup.log`

## Files Explained

### `packages.txt`

List of packages to install via `pacman`. One per line, comments start with `#`:

```
# System utilities
wget
git
vim

# Tools
doas
```

### `aur-packages.txt`

List of packages to install. The script tries pacman first, then skips if not found. Same format as above:

```
# AUR packages
# (Add packages here if needed)
```

### `configs/` Directory

Configuration files that will be deployed to your home directory. The directory structure mirrors your home directory:

- `configs/.bashrc` → deployed to `~/.bashrc`
- `configs/doas.conf` → special handling (see below)

## Backups

When you run the script, a timestamped backup is created:

```
~/arch-setup-backups/2026-04-17-144230/
├── old-configs/           # Your old config files (before overwrite)
│   ├── .bashrc
│   └── doas.conf
└── setup.log              # Complete log of what happened
```

If something breaks, you can restore from backups:

```bash
# Find your backup
ls ~/arch-setup-backups/

# Restore a file
cp ~/arch-setup-backups/2026-04-17-144230/old-configs/.bashrc ~/.bashrc
```

## Error Handling

If a package fails to install, the script will ask you:

```
What would you like to do?
  Options: R(etry)/S(kip)/A(bort)
Enter choice: _
```

- **R** - Retry installing the same package
- **S** - Skip it and continue with the next one
- **A** - Abort the entire setup

## How To Add New Packages

Once you've set up your system and configured packages:

1. **Install and configure** the package manually on your system
2. **Add to the list**: Edit `packages.txt` or `aur-packages.txt`
3. **Save config files**: Copy them to the `configs/` directory maintaining the home directory structure
4. **Commit to git**: Add to your repo and push
5. **Next fresh install**: Just run the script, everything will be there!

### Example: Adding a New Package

```bash
# 1. Manual install and configure
sudo pacman -S somepackage
vim ~/.config/somepackage/config
# ... edit and customize ...

# 2. Add to aur-packages.txt or packages.txt
echo "somepackage" >> packages.txt

# 3. Copy config to repo
mkdir -p arch-setup/configs/.config/somepackage
cp ~/.config/somepackage/config arch-setup/configs/.config/somepackage/config

# 4. Commit
cd arch-setup
git add .
git commit -m "Add somepackage with config"
git push

# 5. Next fresh install: ./setup.sh (handles everything!)
```

## Special Cases

### doas Configuration

The script has special handling for `doas.conf`. It will:
- Create `/etc/doas.conf` if it doesn't exist
- Add the line: `permit permit nopass USERNAME as root`
- Automatically use your current username

No manual root access needed!

### System Update

The script always runs `sudo pacman -Syu` first to update your system before installing packages.

## Logging

Everything is logged to `setup.log`. Check it if something goes wrong:

```bash
# View the log
cat ~/arch-setup-backups/2026-04-17-144230/setup.log

# Follow along in real-time
tail -f ~/arch-setup-backups/2026-04-17-144230/setup.log
```

## Troubleshooting

### "Please do not run as root"
The script must run as a regular user, not root. Use your normal user account.

### "sudo access required"
Your user must be in the sudoers group. Add with:
```bash
su - root
usermod -aG wheel username
exit
```

### "No internet connection"
Make sure you're connected to the internet before running the script.

### Package installation failed
The script will ask what to do. You can:
- Retry (useful for AUR builds that sometimes timeout)
- Skip (continue with other packages)
- Abort (stop and check logs)

Check `setup.log` for details about what failed.

### Want to restore from backup?
Your backups are in `~/arch-setup-backups/`. Each timestamp is a separate backup. Restore manually:

```bash
# Find your backup
cp ~/arch-setup-backups/[timestamp]/old-configs/.bashrc ~/.bashrc
```

## Making It Your Own

This script is designed to be simple and readable. Feel free to:

- Add/remove packages from the lists
- Modify config files in `configs/`
- Add your own scripts or special configurations
- Share with friends or fork for your own use

## Tips

1. **Start simple** - add packages as you configure them, not all at once
2. **Test on a VM** - test your setup on a virtual machine first
3. **Keep configs updated** - after tweaking a config, copy the updated version back to `configs/`
4. **Version control** - use git to track your setup changes
5. **Document additions** - add comments to `packages.txt` explaining why you added each package

## Questions?

Check `setup.log` for detailed logs of what the script did. It includes timestamps and status for every operation.
