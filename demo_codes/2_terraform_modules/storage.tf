/*
Demo 2: Storage resources (GCS)

Same idea as demo 1: use `for_each` to create one bucket per environment.
The resources in the root module are referred to as shared infrastructure.
*/

resource "google_storage_bucket" "environment_buckets" {
  for_each = toset(var.environment_list)
  name     = "${lower(each.key)}_${var.project-id}"
  location = "US"
  versioning {
    enabled = true
  }
}
