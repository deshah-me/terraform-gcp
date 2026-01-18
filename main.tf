resource "google_storage_bucket" "storage-bucket" {
  name          = "my-storage-bucket234234"
  location      = "us-east1"
  storage_class = "STANDARD"
  labels = {
    "key1" = "value1"
    "key2" = "value2"
  }
  uniform_bucket_level_access = true
}

data "http" "photo" {
  url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3kzRQxItrOQk7ASBMrRm_oZoanTO1ajAD9w&s"
}

resource "google_storage_bucket_object" "photos" {
  name   = "random_photo.jpg"
  bucket = google_storage_bucket.storage-bucket.name
  content = data.http.photo.response_body
}
