#!/usr/bin/env bash
# Cross-distro setup script
# Supports: Amazon Linux, RHEL/CentOS, Fedora, Ubuntu/Debian, Alpine

set -euo pipefail

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
    install_packages --allowerasing curl git unzip python3 python3-pip
    echo "set-1 Setup completed installing - curl git unzip python3 python3-pip"
    curl -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin
    /usr/local/bin --version
    which just
    echo "Setting alias for python & pip 3"
    alias python=python3
    alias pip=pip3
    echo "✅ Setup complete."
}

main "$@"
