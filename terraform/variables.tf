variable "cred" {
  description = "you service account credentials json file"
  default     = "path .json file"
}

variable "project" {
  description = "The ID of the GCP project"
  default     = "bike project name"
}

variable "region" {
  description = "The region to create the GCS bucket in"
  default     = "europe-west2"
}

variable "datalake" {
  description = "datalake for raw data"
  default     = "data_lake_locations"
}

variable "location" {
  description = "my location"
  default     = "EU"
}

variable "dataset_name" {
  description = "dataset name"
  default     = "bike_project"
}