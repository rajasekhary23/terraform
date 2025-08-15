# Set Python venv directory
VENV_DIR := .venv

# Default target
default:
    @echo "Available commands:"
    @echo "  just setup         - Run cross-distro setup script"
    @echo "  just install-tools - Install Trivy, Terraform lint, detect-secrets in venv"
    @echo "  just scan-all      - Run all security scans"
    @echo "  just scan-secrets  - Run secret scan (venv)"
    @echo "  just scan-trivy    - Run Trivy filesystem scan"
    @echo "  just scan-terraform - Run Terraform lint"
    @echo "  just clean         - Clean artifacts and venv"

# Run setup.sh
setup:
    bash setup.sh

# Create venv if it doesn't exist
$(VENV_DIR)/bin/activate:
    python3 -m venv $(VENV_DIR)
    @echo "✅ Virtual environment created at $(VENV_DIR)"

# Install security tools (Trivy, TFLint, detect-secrets inside venv)
install-tools: $(VENV_DIR)/bin/activate
    @echo "📦 Installing Trivy..."
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
    @echo "📦 Installing TFLint..."
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
    @echo "📦 Installing detect-secrets in venv..."
    . $(VENV_DIR)/bin/activate && pip install --upgrade pip && pip install detect-secrets

# Run Trivy filesystem scan
scan-trivy:
    ./trivy fs . --exit-code 1 --severity HIGH,CRITICAL || true

# Run Terraform lint
scan-terraform:
    tflint --recursive || true

# Run secret scan inside venv
scan-secrets:
    . $(VENV_DIR)/bin/activate && detect-secrets scan > .secrets.baseline
    . $(VENV_DIR)/bin/activate && detect-secrets audit .secrets.baseline || true

# Run all scans
scan-all: scan-trivy scan-terraform scan-secrets

# Clean artifacts and venv
clean:
    rm -f .secrets.baseline
    rm -rf trivy.log
    rm -rf $(VENV_DIR)
    @echo "🧹 Clean complete."
