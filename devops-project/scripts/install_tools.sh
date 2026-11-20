#!/usr/bin/env bash
# Installs Terraform and Ansible inside GitHub Codespaces
set -e
sudo apt-get update -y
sudo apt-get install -y unzip curl python3-pip
TF_VERSION=1.9.8
curl -fsSL -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
sudo unzip -o /tmp/terraform.zip -d /usr/local/bin
pip3 install --user ansible || pip3 install --user --break-system-packages ansible
echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
export PATH=$PATH:$HOME/.local/bin
terraform -version
ansible --version | head -1
docker ps > /dev/null && echo "Docker OK"
