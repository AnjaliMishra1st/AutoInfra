#!/usr/bin/env bash
# One command runs the whole pipeline: Terraform -> inventory -> Ansible (+Puppet) -> Nagios
set -e
export PATH=$PATH:$HOME/.local/bin
cd "$(dirname "$0")"
echo "=== 1. Terraform: create servers ==="
terraform -chdir=terraform init
terraform -chdir=terraform apply -auto-approve
echo "=== 2. Generate Ansible inventory ==="
./scripts/gen_inventory.sh
echo "=== 3. Ansible: configure servers, run Puppet, set up Nagios ==="
(cd ansible && ansible-playbook -i inventory.ini site.yml)
echo "=== DONE ==="
echo "Web1: http://localhost:8081   Web2: http://localhost:8082"
echo "Nagios: http://localhost:8080/nagios4  (user nagiosadmin / password admin123)"
