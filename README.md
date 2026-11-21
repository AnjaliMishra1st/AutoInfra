<div align="center">

# AutoInfra

### Automated Infrastructure Provisioning, Configuration and Monitoring

**Terraform | Ansible | Puppet | Nagios | Docker**

![Terraform](https://img.shields.io/badge/Terraform-Provisioning-7B42BC?style=for-the-badge)
![Ansible](https://img.shields.io/badge/Ansible-Configuration-EE0000?style=for-the-badge)
![Puppet](https://img.shields.io/badge/Puppet-Enforcement-E69500?style=for-the-badge)
![Nagios](https://img.shields.io/badge/Nagios-Monitoring-1A1A1A?style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-Containers-2496ED?style=for-the-badge)
![Tests](https://img.shields.io/badge/Tests-5%20of%205%20Passed-2EA44F?style=for-the-badge)

**One command builds, configures and monitors a complete server environment.**

*Terraform builds it. Ansible sets it up. Puppet keeps it correct. Nagios watches it.*

</div>

---

## Project Details

| | |
|---|---|
| **Student** | Anjali Mishra |
| **Course** | Configuration Management / DevOps |
| **Submitted To** | Vineet Kaundal |
| **Environment** | GitHub Codespaces and Docker |

---

## Overview

AutoInfra is a fully automated DevOps pipeline. A single script creates three servers, installs and configures their software, keeps that configuration correct, and monitors the servers for failures. No server is set up by hand.

## The Problem

A small company runs a web application on several servers, and it faces four common problems:

| Problem | Impact |
|---|---|
| Servers are created and configured manually | Slow and error-prone |
| Two servers set up by different people differ | Inconsistent environments |
| A failed service is noticed only when users complain | Long downtime |
| A crashed server is hard to rebuild | Risky recovery |

## The Solution

The entire environment is written as code (Infrastructure as Code), and each tool does the job it is best at.

| Tool | Role | What it does in this project |
|:---:|---|---|
| **Terraform** | Provisioning | Creates the network and three servers from code |
| **Ansible** | Configuration | Installs Apache, Puppet and Nagios using a playbook |
| **Puppet** | Enforcement | Keeps Apache running and repairs drift automatically |
| **Nagios** | Monitoring | Checks PING, HTTP, disk, CPU and Apache, and raises alerts |

---

## System Architecture

```
+------------------------------------------------------------------+
|                CONTROL NODE  (GitHub Codespace)                  |
|                                                                  |
|   +--------------+    +----------------+    +----------------+   |
|   |  TERRAFORM   |    |    ANSIBLE     |    |     PUPPET     |   |
|   |  provisions  |    |   configures   |    |    enforces    |   |
|   +--------------+    +----------------+    +----------------+   |
+------------------------------------------------------------------+
            |                    |                     |
            |   1 create   2 configure   3 enforce     |
            v                    v                     v
   +----------------+   +----------------+   +--------------------+
   |      web1      |   |      web2      |   |      monitor       |
   |  Apache  :8081 |   |  Apache  :8082 |   |   Nagios   :8080   |
   +----------------+   +----------------+   +--------------------+
            ^                    ^                     |
            |                    |                     |
            +--------------------+---------------------+
                  4 Nagios checks PING, HTTP, DISK, CPU
```

### Workflow

| Step | Action | Tool |
|:---:|---|---|
| 1 | Create the network, `web1`, `web2` and `monitor` | Terraform |
| 2 | Convert Terraform output into an Ansible inventory | Script |
| 3 | Install Apache, the Puppet agent, Nagios plugins and Nagios | Ansible |
| 4 | Apply the manifest so Apache runs and serves the page | Puppet |
| 5 | Check each web server and alert on failure | Nagios |

---

## Quick Start

All steps run in **GitHub Codespaces**, where Docker is already installed.

```bash
# 1. Go into the project folder
cd devops-project

# 2. Install Terraform and Ansible
bash scripts/install_tools.sh
source ~/.bashrc

# 3. Build, configure and monitor everything with one command
chmod +x *.sh scripts/*.sh
./deploy.sh

# 4. Run all tests
./test.sh

# 5. Remove everything
./destroy.sh
```

### Access (Ports tab in Codespaces)

| Service | Port | Address |
|---|:---:|---|
| Web Server 1 | 8081 | `http://localhost:8081` |
| Web Server 2 | 8082 | `http://localhost:8082` |
| Nagios Dashboard | 8080 | `http://localhost:8080/nagios4` |

Nagios login: user `nagiosadmin`, password `admin123`.

---

## Test Results

| # | Test | Result | What it proves |
|:-:|---|:-:|---|
| 1 | Web pages load from both servers | Pass | Provisioning and configuration work |
| 2 | Second Puppet run reports `changed=0` | Pass | Servers are already in the desired state |
| 3 | Apache stopped on web1, Puppet restarts it | Pass | Self-healing |
| 4 | Nagios checks HTTP, PING, DISK and LOAD all return OK | Pass | Monitoring works |
| 5 | Apache stopped on web2, Nagios returns `HTTP CRITICAL` | Pass | Failure detection and alerting |

Ansible result: `failed=0` on `monitor`, `web1` and `web2`.

---

## Project Structure

```
AutoInfra/
|-- README.md
`-- devops-project/
    |-- deploy.sh                  One command runs the full pipeline
    |-- test.sh                    Runs all five tests
    |-- destroy.sh                 Removes the whole environment
    |-- terraform/
    |   |-- main.tf                Network, web1, web2 and monitor containers
    |   |-- variables.tf           Number of web servers
    |   |-- outputs.tf             Server names and IP addresses
    |   `-- docker/Dockerfile      Base server image
    |-- ansible/
    |   |-- site.yml               Playbook for Apache, Puppet and Nagios
    |   |-- files/webserver.pp     Puppet manifest (self-healing Apache)
    |   `-- templates/             Nagios hosts, services and commands
    `-- scripts/
        |-- install_tools.sh       Installs Terraform and Ansible
        `-- gen_inventory.sh       Terraform output to Ansible inventory
```

---

## Key Features

- **Infrastructure as Code:** every setting is a file that can be reviewed, versioned and reused.
- **One-command deployment:** `./deploy.sh` runs all four tools in the correct order.
- **Self-healing:** Puppet restarts Apache automatically after a failure.
- **Proactive monitoring:** Nagios detects problems before users report them.
- **Reproducible:** running `destroy.sh` and then `deploy.sh` rebuilds an identical environment.

## Design Decisions

| Decision | Reason |
|---|---|
| Docker containers as servers | The practical runs in GitHub Codespaces, which supports Docker but not VirtualBox |
| Terraform and Ansible kept separate | Terraform creates infrastructure, Ansible configures it |
| Masterless Puppet (`puppet apply`) | Removes the certificate signing step and keeps setup simple |
| Apache process check instead of SSH check | The containers do not run an SSH server |

## Challenge and Solution

| Challenge | Solution |
|---|---|
| Puppet failed with `Provider init is not functional on this host` because containers have no systemd | Replaced the `service` resource with `exec` resources that start Apache when it is down and reload it only when the page changes |

---

## Viva Questions

**Why are Terraform and Ansible both used?**
Terraform creates the infrastructure and Ansible configures it, so each tool does what it does best.

**What does Puppet add that Ansible does not?**
Puppet continuously enforces the desired state and repairs drift. When Apache was stopped, the next Puppet run restarted it.

**Why Docker?**
The practical was done in GitHub Codespaces, so containers act as servers.

**How do you prove the environment is reproducible?**
Run `./destroy.sh` and then `./deploy.sh`. The same environment is rebuilt with the same configuration.

---

## Future Scope

- CI/CD pipeline with GitHub Actions or Jenkins
- Docker and Kubernetes support
- Load balancer in front of the web servers
- Grafana dashboards for metrics

## References

1. Terraform Documentation: https://developer.hashicorp.com/terraform/docs
2. Ansible Documentation: https://docs.ansible.com
3. Puppet Documentation: https://www.puppet.com/docs
4. Nagios Core Documentation: https://www.nagios.org/documentation

---

<div align="center">

**AutoInfra** | Anjali Mishra | 

</div>
