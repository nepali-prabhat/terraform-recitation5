variable "instance_count" {
  type        = number
  description = "Number of web instances to create"
  default     = 3
}

variable "machine_type" {
  type        = string
  description = "GCP machine type for web instances"
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to web instances"
  default     = {}
}

variable "network_self_link" {
  type        = string
  description = "Self link of the VPC network for the instances"
}

variable "subnetwork_self_link" {
  type        = string
  description = "Self link of the subnetwork for the instances"
}

variable "boot_image" {
  type        = string
  description = "Boot disk image for the instances"
  default     = "debian-cloud/debian-11"
}
