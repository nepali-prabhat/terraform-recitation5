/*
Demo 1: Data sources

Data sources let Terraform *read* information about existing infrastructure
without creating/modifying it.

Here we look up the "default" VPC network so other resources can reference its ID/link.
*/

data "google_compute_network" "default" {
  # This is the pre-created default VPC in most GCP projects.
  name = "default"
}
