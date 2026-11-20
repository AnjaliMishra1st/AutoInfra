#!/usr/bin/env bash
# Runs the tests from Section 9 of the report
export PATH=$PATH:$HOME/.local/bin
cd "$(dirname "$0")"
echo "--- Test 1: web pages load ---"
curl -s localhost:8081; curl -s localhost:8082
echo "--- Test 2: Puppet second run (should show no changes) ---"
(cd ansible && ansible-playbook -i inventory.ini site.yml --tags puppet | grep -E "changed|ok=")
echo "--- Test 3: Self-healing: stop Apache on web1 ---"
docker exec web1 service apache2 stop
curl -s -m 3 localhost:8081 || echo "web1 is DOWN"
(cd ansible && ansible webservers -i inventory.ini -m command -a "puppet apply /opt/puppet/webserver.pp")
curl -s localhost:8081
echo "--- Test 4: Nagios plugin checks from the monitor server ---"
docker exec monitor /usr/lib/nagios/plugins/check_http -H web1
docker exec monitor /usr/lib/nagios/plugins/check_http -H web2
docker exec monitor /usr/lib/nagios/plugins/check_ping -H web1 -w 100,20% -c 500,60%
docker exec monitor /usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /
docker exec monitor /usr/lib/nagios/plugins/check_load -w 5,4,3 -c 10,8,6
echo "--- Test 5: Nagios alert: stop Apache on web2, check CRITICAL ---"
docker exec web2 service apache2 stop
docker exec monitor /usr/lib/nagios/plugins/check_http -H web2 ; echo "exit code: $? (2 = CRITICAL)"
docker exec web2 service apache2 start
