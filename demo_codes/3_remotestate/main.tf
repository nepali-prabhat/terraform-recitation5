/*
Demo 3: Remote state setup (GCS backend prerequisite)

Terraform state contains the mapping between your configuration and real cloud resources.
Keeping state locally works for a single-person demo, but teams typically use *remote state*.

On GCP, a common choice is a GCS bucket. This demo creates a bucket you can later use
as the backend for other Terraform configurations.

Typical workflow:
1) Run this demo once to create the bucket.
  We could also create the bucket manually in the GCP console/gcloud cli and then use it in other configs.
  But this way we can automate the creation of the bucket.

2) In other configs, add:
     terraform {
       backend "gcs" {
         bucket = "<bucket-name-created-here>"
         prefix = "some/path"
       }
     }
*/

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
  # Provider config for creating the state bucket.
  project     = var.project-id
  region      = var.region
  zone        = var.zone
  credentials = file("../../key.json")
}

resource "google_storage_bucket" "environment_buckets" {
  # Bucket name must be globally unique. This pattern tries to make it unique per project.
  name     = "remotestate_${var.project-id}"
  location = "US"
  versioning {
    # Versioning is strongly recommended for state buckets (accidental overwrites happen).
    enabled = true
  }
}