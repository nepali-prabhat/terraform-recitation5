/*
Child module: webservers (outputs)

Outputs are the public "return values" of a module.
The root module can reference them as:
  module.webservers.webserver-ips
  module.webservers.webserver-names
*/

output "webserver-ips" {
  # Collect private IPs for each created instance.
  value = [for instance in google_compute_instance.web-instances : instance.network_interface[0].network_ip]
}
output "webserver-names" {
  # Collect instance names (useful for debugging/verification).
  value = [for instance in google_compute_instance.web-instances : instance.name]
}