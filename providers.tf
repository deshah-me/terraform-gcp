terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.16.0"
    }
  }
}

provider "google" {
  # Configuration options
  project     = "us-con-gcp-sbx-dep0019-081424"
  region      = "us-east1"
  zone        = "us-east1-b"
  credentials = "./keys.json"
}
