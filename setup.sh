#!/usr/bin/env bash
# Cross-distro setup script
# Supports: Amazon Linux, RHEL/CentOS, Fedora, Ubuntu/Debian, Alpine

set -euo pipefail
# Colors for logs
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

echo "[+] Detecting OS type..."

detect_pkg_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        PKG_MGR="apt-get"
        UPDATE_CMD="apt-get update -y"
        INSTALL_CMD="apt-get install -y"
    elif command -v yum >/dev/null 2>&1; then
        PKG_MGR="yum"
        UPDATE_CMD="yum update -y"
        INSTALL_CMD="yum install -y"
    elif command -v dnf >/dev/null 2>&1; then
        PKG_MGR="dnf"
        UPDATE_CMD="dnf update -y"
        INSTALL_CMD="dnf install -y"
    elif command -v apk >/dev/null 2>&1; then
        PKG_MGR="apk"
        UPDATE_CMD="apk update"
        INSTALL_CMD="apk add --no-cache"
    else
        echo "❌ No supported package manager found. Exiting."
        exit 1
    fi
}

install_packages() {
    echo "📦 Installing required packages..."
    sudo $UPDATE_CMD
    sudo $INSTALL_CMD "$@"
}

main() {
    detect_pkg_manager
    echo "[+] Using package manager: $PKG_MGR"
    # Install system packages - curl git unzip python3 python3-pip
    install_packages --allowerasing curl git unzip python3 python3-pip
    echo "[+] 📦 set-1 Setup completed installing - curl git unzip python3 python3-pip"

    echo "[+] Installing Trivy package..."
    # Install Trivy
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh

    echo "[+] Installing tfsec package..."
    # Install tfsec
    curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

    echo "[+] Installing terraform-lint package..."
    # Install terraform-lint
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
    
    
    echo "[+] Installing just package..."
    # ignore if package in path already exists
    curl -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin || echo "Skipping install — already exists"
    /usr/local/bin/just --version
    #just --version
    which just
    echo "Setting alias for python & pip 3"
    alias python=python3
    alias pip=pip3
    echo "✅ Setup complete."

    #Creating Git pre-commit hook...
    echo -e "${GREEN}[+] Creating Git pre-commit hook...${NC}"

    HOOK_PATH=".git/hooks/pre-commit"
    cat > "$HOOK_PATH" << EOF
    #!/usr/bin/env bash
    set -e

    echo "[*] Running pre-commit checks..."

    # 1. Trivy secret scan
    echo "[*] Scanning for secrets..."
    trivy fs --security-checks secret .

    # 2. Terraform lint
    if command -v tflint &>/dev/null; then
        echo "[*] Running tflint..."
        tflint --recursive
    fi

    # 3. tfsec security scan
    if command -v tfsec &>/dev/null; then
        echo "[*] Running tfsec..."
        tfsec .
    fi

    # 4. General linting (example: shell scripts)
    if command -v shellcheck &>/dev/null; then
        echo "[*] Linting shell scripts..."
        find . -name "*.sh" -exec shellcheck {} \;
    fi

    echo "[✓] All checks passed!"
    EOF


    chmod +x "$HOOK_PATH"
    echo -e "${GREEN}[+] Pre-commit hook installed successfully!${NC}"
}

main "$@"
