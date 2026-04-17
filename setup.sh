#!/bin/bash

# Exit on any error
set -e

################################
# Arch Linux Setup Script
# Minimal and readable for everyone
################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/arch-setup-backups"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
BACKUP_PATH="$BACKUP_DIR/$TIMESTAMP"
LOG_FILE="$BACKUP_PATH/setup.log"

# Username (for doas config)
USERNAME=$(whoami)

# Determine if we need sudo or not
if [[ $EUID -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

################################
# Helper Functions
################################

# Wait for pacman lock to be released
wait_for_pacman() {
    local timeout=300  # 5 minutes max wait
    local elapsed=0
    
    while fuser /var/lib/pacman/db.lck >/dev/null 2>&1; do
        if [[ $elapsed -ge $timeout ]]; then
            print_error "Timeout waiting for pacman lock"
            log "Timeout waiting for pacman lock after ${timeout}s"
            exit 1
        fi
        
        print_info "Waiting for pacman lock to be released..."
        sleep 2
        ((elapsed+=2))
    done
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}   Arch Linux Setup Script${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

print_section() {
    echo -e "${BLUE}[$1]${NC} $2"
}

print_success() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "  ${RED}✗${NC} $1"
}

print_info() {
    echo -e "  ${YELLOW}→${NC} $1"
}

ask_user() {
    local prompt="$1"
    local choices="$2"
    echo ""
    echo -e "${YELLOW}$prompt${NC}"
    echo "  Options: $choices"
    read -p "  Enter choice: " response
    echo "$response"
}

################################
# Prerequisite Checks
################################

check_prerequisites() {
    print_section "CHECK" "Checking prerequisites..."
    
    # Check internet
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        print_error "No internet connection"
        exit 1
    fi
    print_success "Internet connection OK"
    
    echo ""
}

################################
# Backup Setup
################################

setup_backups() {
    print_section "BACKUP" "Creating backup directory..."
    
    mkdir -p "$BACKUP_PATH/old-configs"
    print_success "Backup directory created: $BACKUP_PATH"
    
    # Initialize log file
    log "Setup script started"
    log "Backup directory: $BACKUP_PATH"
    log "Username: $USERNAME"
    
    echo ""
}

################################
# System Update
################################

update_system() {
    print_section "UPDATE" "Updating pacman database..."
    
    wait_for_pacman
    
    if $SUDO pacman -Syu --noconfirm; then
        print_success "System updated"
        log "pacman -Syu completed successfully"
    else
        print_error "Failed to update system"
        log "pacman -Syu failed"
        exit 1
    fi
    
    echo ""
}

################################
# Package Installation
################################

install_packages() {
    print_section "PACKAGES" "Installing packages from packages.txt..."
    
    local packages_file="$SCRIPT_DIR/packages.txt"
    
    if [[ ! -f "$packages_file" ]]; then
        print_error "packages.txt not found"
        return 1
    fi
    
    # Read all packages into array, filtering out comments and empty lines
    local packages=()
    while IFS= read -r package || [[ -n "$package" ]]; do
        # Skip empty lines and comments
        [[ -z "$package" || "$package" =~ ^# ]] && continue
        
        # Trim whitespace
        package=$(echo "$package" | xargs)
        
        # Check if package is already installed
        if pacman -Qi "$package" &> /dev/null; then
            print_success "$package already installed"
            log "Package $package already installed"
        else
            packages+=("$package")
        fi
    done < "$packages_file"
    
    # Install all packages in one call
    if [[ ${#packages[@]} -gt 0 ]]; then
        print_info "Installing ${#packages[@]} package(s) in batch..."
        
        wait_for_pacman
        
        if $SUDO pacman -S --noconfirm "${packages[@]}"; then
            print_success "All packages installed successfully"
            log "All ${#packages[@]} packages installed successfully"
        else
            print_error "Failed to install some packages"
            log "Failed to install packages: ${packages[*]}"
            
            local choice=$(ask_user "What would you like to do?" "R(etry)/S(kip)/A(bort)")
            case $choice in
                [Rr]) install_packages "$packages_file" ;;
                [Ss]) log "Skipped package installation" ;;
                [Aa]) log "Aborted by user"; exit 1 ;;
                *) log "Invalid choice, skipping packages" ;;
            esac
        fi
    else
        print_success "All packages already installed"
        log "All packages already installed"
    fi
    
    echo ""
}

install_packages_single() {
    local package="$1"
    wait_for_pacman
    if $SUDO pacman -S "$package" --noconfirm; then
        print_success "$package installed successfully"
        log "Package $package installed (retry successful)"
    else
        print_error "Still failed to install $package, skipping"
        log "Retry failed for $package"
    fi
}

install_aur_packages() {
    print_section "AUR" "Installing AUR packages from aur-packages.txt..."
    
    local aur_file="$SCRIPT_DIR/aur-packages.txt"
    
    if [[ ! -f "$aur_file" ]]; then
        print_error "aur-packages.txt not found"
        return 1
    fi
    
    # Read all packages into array, filtering out comments and empty lines
    local packages=()
    while IFS= read -r package || [[ -n "$package" ]]; do
        # Skip empty lines, comments, and yay
        [[ -z "$package" || "$package" =~ ^# || "$package" == "yay" ]] && continue
        
        # Trim whitespace
        package=$(echo "$package" | xargs)
        
        # Check if package is already installed
        if pacman -Qi "$package" &> /dev/null; then
            print_success "$package already installed"
            log "AUR package $package already installed"
        else
            packages+=("$package")
        fi
    done < "$aur_file"
    
    # Install all packages in one call
    if [[ ${#packages[@]} -gt 0 ]]; then
        print_info "Installing ${#packages[@]} AUR package(s) in batch..."
        
        wait_for_pacman
        
        if $SUDO pacman -S --noconfirm "${packages[@]}"; then
            print_success "All AUR packages installed successfully"
            log "All ${#packages[@]} AUR packages installed successfully"
        else
            print_info "Some AUR packages not available in pacman (this is normal)"
            log "Some AUR packages not available in pacman, skipping"
        fi
    else
        print_success "All AUR packages already installed"
        log "All AUR packages already installed"
    fi
    
    echo ""
}

################################
# Configuration Deployment
################################

deploy_configs() {
    print_section "CONFIG" "Deploying configuration files..."
    
    local configs_dir="$SCRIPT_DIR/configs"
    
    if [[ ! -d "$configs_dir" ]]; then
        print_info "No configs directory found, skipping config deployment"
        return 0
    fi
    
    # Find all files in configs directory
    while IFS= read -r config_file; do
        # Get relative path from configs directory
        local relative_path="${config_file#$configs_dir/}"
        
        # Skip doas.conf - it's handled separately by configure_doas
        if [[ "$relative_path" == "doas.conf" ]]; then
            print_info "Skipping: doas.conf (handled separately)"
            continue
        fi
        
        local target_path="$HOME/$relative_path"
        local target_dir=$(dirname "$target_path")
        
        print_info "Deploying: $relative_path"
        
        # Create target directory if it doesn't exist
        mkdir -p "$target_dir"
        
        # Backup existing file
        if [[ -f "$target_path" ]]; then
            # Create backup with safe filename
            local backup_name=$(echo "$relative_path" | sed 's/\//\-/g')
            cp "$target_path" "$BACKUP_PATH/old-configs/$backup_name"
            print_success "Backup saved: $BACKUP_PATH/old-configs/$backup_name"
            log "Backed up $target_path to old-configs/$backup_name"
        fi
        
        # Deploy config file
        cp "$config_file" "$target_path"
        print_success "Deployed to: $target_path"
        log "Deployed $relative_path to $target_path"
        
    done < <(find "$configs_dir" -type f)
    
    echo ""
}

################################
# Special Configurations
################################

configure_doas() {
    print_section "SPECIAL" "Configuring doas..."
    
    if ! command -v doas &> /dev/null; then
        print_info "doas not installed, skipping doas config"
        return 0
    fi
    
    local doas_config="/etc/doas.conf"
    local doas_config_line="permit nopass $USERNAME as root"
    
    # Check if config already exists
    if [[ -f "$doas_config" ]]; then
        # Backup existing doas.conf
        $SUDO cp "$doas_config" "$BACKUP_PATH/old-configs/etc-doas.conf"
        print_success "Backed up existing doas.conf"
        log "Backed up existing doas.conf"
    fi
    
    # Check if line already exists
    if $SUDO grep -q "permit nopass $USERNAME as root" "$doas_config" 2>/dev/null; then
        print_success "doas already configured correctly"
        log "doas already configured correctly"
        return 0
    fi
    
    # Add the configuration line
    if echo "$doas_config_line" | $SUDO tee -a "$doas_config" > /dev/null; then
        $SUDO chmod 600 "$doas_config"
        print_success "doas.conf configured successfully"
        log "doas.conf configured: $doas_config_line"
    else
        print_error "Failed to configure doas"
        log "Failed to configure doas"
    fi
    
    echo ""
}

################################
# Summary
################################

print_summary() {
    echo ""
    print_section "SUMMARY" "Setup completed!"
    echo ""
    print_success "Backup directory: $BACKUP_PATH"
    print_success "Log file: $LOG_FILE"
    echo ""
    echo -e "${BLUE}================================${NC}"
    echo ""
}

################################
# Main Execution
################################

main() {
    print_header
    check_prerequisites
    setup_backups
    update_system
    install_packages
    install_aur_packages
    deploy_configs
    configure_doas
    print_summary
    
    log "Setup script completed successfully"
}

main "$@"
