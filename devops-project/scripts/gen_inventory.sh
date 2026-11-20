#!/usr/bin/env bash
# Converts Terraform outputs into an Ansible inventory file
set -e
cd "$(dirname "$0")/.."
python3 - <<'PY'
import json, subprocess
def out(n):
    return json.loads(subprocess.check_output(["terraform", "-chdir=terraform", "output", "-json", n]))
names, ips = out("web_names"), out("web_ips")
lines = ["[webservers]"]
for n, ip in zip(names, ips):
    lines.append(f"{n} ip={ip}")
lines += ["", "[monitoring]", f"{out('monitor_name')} ip={out('monitor_ip')}", "",
          "[all:vars]",
          "ansible_connection=community.docker.docker",
          "ansible_python_interpreter=/usr/bin/python3", ""]
open("ansible/inventory.ini", "w").write("\n".join(lines))
print("\n".join(lines))
PY
