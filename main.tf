resource "google_bigquery_dataset" "bg_tf" {

dataset_id = "my_dataset_tf"
friendly_name = "My Dataset"
description = "This is my dataset created with Terraform"
location = "US"
default_table_expiration_ms = 3600000

labels = {
  env= "default"
}
}

resource "google_bigquery_table" "table_tf" {
dataset_id = google_bigquery_dataset.bg_tf.dataset_id
table_id =   "table_from_tf"

labels = {
  env= "default"
}

deletion_protection = false
}
