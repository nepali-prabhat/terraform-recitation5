/*
Demo 2: Data sources (read-only lookups)

We look up the default VPC network so we can reference it from:
- subnet creation
- VM network interfaces
- module inputs
*/

data "google_compute_network" "default" {
  name = "default"
}
