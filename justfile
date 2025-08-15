# Default target when running `just`
default:
    @echo "Available commands:"
    @echo "  just setup         - Run cross-distro setup script"
    @echo "  just install-tools - Install Trivy, Terraform lint, detect-secrets"
    @echo "  just scan-all      - Run all security scans"
    @echo "  just scan-secrets  - Run secret scan"
    @echo "  just scan-trivy    - Run Trivy filesystem scan"
    @echo "  just scan-terraform- Run Terraform lint"
    @echo "  just clean         - Clean up artifacts"

# Run setup.sh
setup:
    bash setup.sh

# Install security tools
install-tools:
    @echo "📦 Installing Trivy..."
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
    @echo "📦 Installing TFLint..."
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
    @echo "📦 Installing detect-secrets..."
    pip3 install detect-secrets

# Run Trivy filesystem scan
scan-trivy:
    ./trivy fs . --exit-code 1 --severity HIGH,CRITICAL || true

# Run Terraform lint
scan-terraform:
    tflint --recursive || true

# Run secret scan
scan-secrets:
    detect-secrets scan > .secrets.baseline
    detect-secrets audit .secrets.baseline || true

# Run all scans
scan-all: scan-trivy scan-terraform scan-secrets

# Clean artifacts
clean:
    rm -f .secrets.baseline
    rm -rf trivy.log
    @echo "🧹 Clean complete."
