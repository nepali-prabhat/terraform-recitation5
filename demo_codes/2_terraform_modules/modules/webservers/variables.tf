/*
Child module: webservers (variables)

Modules define their own input variables; the root module passes values in via:
  module "webservers" { ... }

Tip for students:
- Strong types (map/object) make module interfaces clearer and catch mistakes earlier.
*/

variable "project_id" {
  # GCP project ID for the web instances.
  type = string
}

variable "server_settings" {
  # Map of settings keyed by environment name (e.g., DEV/PROD).
  # Each value is an object describing how that environment's VM should look.
  type = map(object({ machine_type = string, labels = map(string) }))
}

variable "prefix" {
  # Optional prefix used to build VM names. If empty, no prefix is used.
  type    = string
  default = "web"
}

variable "network_interface" {
  # Pass in the network/subnet IDs (self_links) so the module doesn't own networking.
  type = object({ network = string, subnetwork = string })
}

variable "region" {
  # Included to show that modules can accept region/zone too, even if this module
  # doesn't currently use them directly in the resource.
  type = string
}

variable "zone" {
  # Included for completeness / future expansion.
  type = string
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to web instances"
  default     = {}
}