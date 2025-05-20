provider "google" {
  credentials = file(var.cred)
  project     = var.project
  region      = var.region
}

resource "google_storage_bucket" "data_lake_bike_project" {
  name          = var.datalake
  location      = var.location
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.dataset_name
  location = var.region
}