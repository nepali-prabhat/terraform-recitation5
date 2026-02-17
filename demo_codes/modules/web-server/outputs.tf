output "network_ips" {
  value       = google_compute_instance.web-instances[*].network_interface[0].network_ip
  description = "Private IP addresses of the web instances"
}

output "instance_names" {
  value       = google_compute_instance.web-instances[*].name
  description = "Names of the web instances"
}

output "instances" {
  value       = google_compute_instance.web-instances
  description = "The web instance resources (for advanced use)"
  sensitive   = true
}
