
#!/usr/bin/env bash

set -Eeuo pipefail

# ==========================================
# OpenTofu Installation - Debian Bullseye
# ==========================================

log() {
    echo -e "\n[INFO] $1"
}

error() {
    echo -e "\n[ERROR] $1" >&2
    exit 1
}

# Check privileges
if [[ "$EUID" -eq 0 ]]; then
    SUDO=""
else
    command -v sudo >/dev/null 2>&1 || error "sudo is required."
    SUDO="sudo"
fi

# Detect OS
source /etc/os-release

if [[ "$ID" != "debian" ]]; then
    error "This script is intended for Debian."
fi

if [[ "$VERSION_CODENAME" != "bullseye" ]]; then
    error "Expected Debian Bullseye, detected: $VERSION_CODENAME"
fi

ARCH=$(dpkg --print-architecture)

case "$ARCH" in
    amd64|arm64) ;;
    *) error "Unsupported architecture: $ARCH" ;;
esac

log "Detected: $PRETTY_NAME ($ARCH)"

# Step 1: Backup existing APT sources
log "Backing up APT configuration..."

BACKUP="/etc/apt/sources.list.bak"

if [[ ! -f "$BACKUP" ]]; then
    $SUDO cp /etc/apt/sources.list "$BACKUP"
fi

# Step 2: Configure Debian Bullseye archive
log "Configuring Debian archive repositories..."

$SUDO tee /etc/apt/sources.list > /dev/null <<'EOF'
deb http://archive.debian.org/debian bullseye main contrib non-free
deb http://archive.debian.org/debian bullseye-updates main contrib non-free
deb http://archive.debian.org/debian bullseye-backports main contrib non-free
deb http://archive.debian.org/debian-security bullseye-security main contrib non-free
EOF

# Disable expired Release metadata checks for archived repositories
$SUDO tee /etc/apt/apt.conf.d/99no-check-valid-until > /dev/null <<'EOF'
Acquire::Check-Valid-Until "false";
EOF

# Step 3: Remove old package indexes
log "Cleaning APT cache..."

$SUDO apt-get clean
$SUDO rm -rf /var/lib/apt/lists/*

# Step 4: Update package indexes
log "Updating Debian package indexes..."

$SUDO apt-get update

# Step 5: Install dependencies
log "Installing dependencies..."

$SUDO apt-get install -y \
    curl \
    ca-certificates \
    gnupg

# Step 6: Create APT keyring directory
log "Creating APT keyring directory..."

$SUDO install -d -m 0755 /etc/apt/keyrings

# Step 7: Download OpenTofu signing keys
log "Downloading OpenTofu signing keys..."

$SUDO curl -fsSL \
    https://get.opentofu.org/opentofu.gpg \
    -o /etc/apt/keyrings/opentofu.gpg

curl -fsSL \
    https://packages.opentofu.org/opentofu/tofu/gpgkey \
    | $SUDO gpg --dearmor --batch --yes \
        -o /etc/apt/keyrings/opentofu-repo.gpg

$SUDO chmod 0644 \
    /etc/apt/keyrings/opentofu.gpg \
    /etc/apt/keyrings/opentofu-repo.gpg

# Step 8: Configure OpenTofu repository
log "Configuring OpenTofu repository..."

echo "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" \
    | $SUDO tee /etc/apt/sources.list.d/opentofu.list > /dev/null

# Step 9: Update package indexes
log "Updating APT with OpenTofu repository..."

$SUDO apt-get update

# Step 10: Install OpenTofu
log "Installing OpenTofu..."

$SUDO apt-get install -y tofu

# Step 11: Verify installation
log "Verifying OpenTofu..."

if command -v tofu >/dev/null 2>&1; then
    tofu version
    log "OpenTofu installation completed successfully!"
else
    error "OpenTofu installation failed."
fi

