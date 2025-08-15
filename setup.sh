#!/usr/bin/env bash

set -e

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

echo -e "${GREEN}[+] Detecting OS type...${NC}"
OS_TYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"

install_linux() {
    echo -e "${GREEN}[+] Installing prerequisites for Linux${NC}"
    sudo apt update || true
    sudo apt install -y curl unzip git shellcheck

    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh
    curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
}

install_macos() {
    echo -e "${GREEN}[+] Installing prerequisites for macOS${NC}"
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}[!] Homebrew not found. Installing...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    brew install aquasecurity/trivy/tfsec tflint shellcheck
}

install_wsl() {
    echo -e "${GREEN}[+] Installing prerequisites for WSL${NC}"
    install_linux
}

case "$OS_TYPE" in
    linux)
        if grep -qi microsoft /proc/version; then
            install_wsl
        else
            install_linux
        fi
        ;;
    darwin)
        install_macos
        ;;
    *)
        echo -e "${YELLOW}[!] Unsupported OS: $OS_TYPE${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}[+] Creating Git pre-commit hook...${NC}"

HOOK_PATH=".git/hooks/pre-commit"
mkdir -p "$(dirname "$HOOK_PATH")"

cat > "$HOOK_PATH" << 'EOF'
#!/usr/bin/env bash
set -e

echo "[*] Running pre-commit checks..."

echo "[*] Scanning for secrets..."
trivy fs --security-checks secret .

if command -v tflint &>/dev/null; then
    echo "[*] Running tflint..."
    tflint --recursive
fi

if command -v tfsec &>/dev/null; then
    echo "[*] Running tfsec..."
    tfsec .
fi

if command -v shellcheck &>/dev/null; then
    echo "[*] Linting shell scripts..."
    find . -name "*.sh" -exec shellcheck {} \;
fi

echo "[✓] All checks passed!"
EOF

chmod +x "$HOOK_PATH"
echo -e "${GREEN}[+] Pre-commit hook installed successfully!${NC}"
