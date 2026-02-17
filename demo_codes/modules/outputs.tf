output "nginx-public-ip" {
  value = google_compute_instance.nginx_instance.network_interface[0].access_config[0].nat_ip
}

output "webserver-ips" {
  value     = module.web_instances.network_ips
  description = "Private IPs of web instances (from web-server module)"
}

output "db-private-ip" {
  value = google_compute_instance.mysqldb.network_interface[0].network_ip
}
