#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

echo "==> Starting Docker, Minikube, and Kubectl Installation..."

# 1. Install Docker
if command -v docker &> /dev/null; then
    echo "[+] Docker is already installed. Skipping..."
else
    echo "[+] Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm -f get-docker.sh
fi

# 2. Add current user to docker group (removes need for 'sudo docker' / '--force')
if ! groups "$USER" | grep &>/dev/null "\bdocker\b"; then
    echo "[+] Adding current user ($USER) to the docker group..."
    sudo usermod -aG docker "$USER"
    echo "[!] NOTE: You may need to log out and log back in for docker group changes to apply."
fi

# Ensure Docker service is running
sudo systemctl enable --now docker

# 3. Install Minikube
if command -v minikube &> /dev/null; then
    echo "[+] Minikube is already installed. Skipping binary download..."
else
    echo "[+] Downloading and installing Minikube..."
    curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm -f minikube-linux-amd64
fi

# 4. Install kubectl
if command -v kubectl &> /dev/null; then
    echo "[+] kubectl is already installed. Skipping binary download..."
else
    echo "[+] Downloading and installing kubectl..."
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f kubectl
fi

# 5. Start Minikube
echo "[+] Starting Minikube..."
# Try starting normally; if running as root or encountering permission issues, fallback to --force
minikube start || minikube start --force

# 6. Verify Installation
echo "==> Verifying installation:"
kubectl version --client --output=yaml

echo "==> Setup complete!"
