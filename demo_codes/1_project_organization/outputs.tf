/*
Demo 1: Outputs

Outputs are values Terraform prints after `apply` (and stores in state).
They’re useful for:
- handing information to humans (IPs, URLs)
- wiring modules together (one module's output becomes another's input)
*/

output "nginx-public-ip" {
  # Public (NAT) IP from the instance's first network interface.
  description = "Public IP of the nginx instance"
  value = google_compute_instance.nginx_instance.network_interface[0].access_config[0].nat_ip
}

output "webserver-ips" {
  # Private IPs of all instances created with `count`.
  # `[*]` is the "splat" operator: collect this attribute from each instance.
  description = "Private IPs of all instances created with `count`"
  value = google_compute_instance.web-instances[*].network_interface[0].network_ip
}

output "db-private-ip" {
  # Private IP for the DB VM (no external IP attached).
  description = "Private IP of the DB VM"
  value = google_compute_instance.mysqldb.network_interface[0].network_ip
  
  # The value of this output is sensitive and will not be printed to the console.
  # This is useful for sensitive data like passwords or API keys.
  sensitive = true
}