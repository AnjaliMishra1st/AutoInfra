output "web_names" {
  value = docker_container.web[*].name
}
output "web_ips" {
  value = [for c in docker_container.web : c.network_data[0].ip_address]
}
output "monitor_name" {
  value = docker_container.monitor.name
}
output "monitor_ip" {
  value = docker_container.monitor.network_data[0].ip_address
}
