/*
Demo 1: Storage (GCS buckets)

This shows `for_each` with a *set* of strings:
- We take `var.environment_list` (e.g., ["DEV","PROD"])
- Convert it to a set via `toset(...)`
- Create one bucket per environment

Important notes for students:
- GCS bucket names must be globally unique across all of Google Cloud, not just your project.
  If `dev_<project-id>` is taken, you'll need to add more uniqueness (like a random suffix).
- Bucket versioning keeps old object versions, which is helpful for rollback and auditing.
*/

resource "google_storage_bucket" "environment_buckets" {
  # One bucket per environment (DEV/PROD).
  for_each = toset(var.environment_list)

  # `each.key` is the environment string from the set (ex: "DEV").
  # We lower-case it to keep names consistent.
  name     = "${lower(each.key)}_${var.project-id}"
  location = "US"
  versioning {
    enabled = true
  }
}