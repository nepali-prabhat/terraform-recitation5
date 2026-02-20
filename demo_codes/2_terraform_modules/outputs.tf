output "nginx-public-ip" {
    value = google_compute_instance.nginx_instance.network_interface[0].access_config[0].nat_ip
}

output "webserver-data" {
    value = {
        webserver-ips = module.webservers.webserver-ips
        webserver-names = module.webservers.webserver-names
    }
}

output "db-private-ip" {
    value = google_compute_instance.mysqldb.network_interface[0].network_ip
}