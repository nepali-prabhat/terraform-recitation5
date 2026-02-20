/*
Demo 2: Outputs across modules

Notice how outputs can:
- read attributes from resources in the root module (nginx/db instances)
- read outputs from a child module (`module.webservers.*`)
*/

output "nginx-public-ip" {
  # Public IP of the proxy VM (created in the root module).
  description = "Public IP of the proxy VM"
  value = google_compute_instance.nginx_instance.network_interface[0].access_config[0].nat_ip
}

output "webserver-data" {
  # Bundle multiple values together in a single output object.
  # These values come from the child module's outputs.
  description = "Bundle of webserver IPs and names"
  value = {
    webserver-ips   = module.webservers.webserver-ips
    webserver-names = module.webservers.webserver-names
  }
}

output "db-private-ip" {
  # Private IP of the DB VM.
  description = "Private IP of the DB VM"
  value = google_compute_instance.mysqldb.network_interface[0].network_ip
  sensitive = true
}