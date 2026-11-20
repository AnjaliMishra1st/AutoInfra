#!/usr/bin/env bash
cd "$(dirname "$0")"
terraform -chdir=terraform destroy -auto-approve
