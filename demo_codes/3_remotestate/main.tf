terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project-id
  region  = var.region
  zone    = var.zone
  credentials = file("../../key.json")
}

resource "google_storage_bucket" "environment_buckets" {
  name = "remotestate_${var.project-id}"
  location = "US"
  versioning {
    enabled = true
  }
}