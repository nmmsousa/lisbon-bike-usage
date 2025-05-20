variable "cred" {
  description = "my cred"
  default     = "/home/nmmsousa/bike_project/keys/my-service-account-cred.json"
}

variable "project" {
  description = "my project"
  default     = "bike-project-458013"
}

variable "region" {
  description = "my region"
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