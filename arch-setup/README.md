# Arch Linux Post-Installation Setup

This folder contains your automated setup script for Arch Linux, tailored specifically for your `dwm` workflow.

## 📂 File Structure

* `setup.sh`: The master script that executes everything.
* `packages.txt`: A simple list of official Arch Linux packages to install.
* `aur_packages.txt`: A simple list of AUR packages to install using `yay`.

## 🚀 How to Use

1. **Edit the Variables:** Open `setup.sh` in your preferred text editor and replace the placeholder GitHub URLs at the very top with the actual links to your `dotfiles`, `dwm`, `st`, `dmenu`, and `dwmblocks` repositories.
2. **Review Packages:** Look at `packages.txt` and `aur_packages.txt` and add/remove any software you want.
3. **Make the Script Executable:**
   ```bash
   chmod +x setup.sh
   ```
4. **Run the Script:**
   ```bash
   ./setup.sh
   ```

## 🛠️ How to Edit and Add Your Own Commands

The beauty of this script is Phase 8 (`setup.sh`). It is designed for you to easily copy and paste examples to manipulate files without needing to open them manually.

Here is a quick cheat sheet for the commands you can add to Phase 8:

### 1. Find and Replace Text in a File (sed)
If you want to edit a config file automatically, use `sed`.
```bash
# Syntax: sed -i 's/WHAT_TO_FIND/WHAT_TO_REPLACE_IT_WITH/g' /path/to/file
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf
```

### 2. Add a Line to the End of a File (echo)
Use `>>` to append text without overwriting the whole file.
```bash
echo "alias ls='ls --color=auto'" >> ~/.bashrc
```

### 3. Create or Overwrite an Entire File (cat << EOF)
If you want to write a multi-line file directly from the script, use this block. It will overwrite the file.
```bash
cat << 'EOF' > ~/.config/dummy/config.txt
This is line one.
This is line two.
EOF
```

### 4. Create Directories (mkdir)
Use the `-p` flag so it creates parent folders and doesn't crash if the folder already exists.
```bash
mkdir -p ~/Pictures/Screenshots
```

### 5. Delete Files or Directories (rm)
Use `-rf` to permanently remove directories and their contents.
```bash
rm -rf ~/old_stuff_to_delete
```
