resource "google_cloud_run_v2_service" "default" {
  name     = "cloudrun-service-tf"
  location = "us-east1"
  
  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello" ## docker image
      
      ports {
        container_port = 8080
      }
    }
  }
  
  # 50-50 traffic split between previous revision and latest
  traffic {
    type     = "TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION"
    revision = "cloudrun-service-tf-00001-5hq"
    percent  = 50
  }
  
  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 50
  }
}

# Make the Cloud Run service publicly accessible
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  name     = google_cloud_run_v2_service.default.name
  location = google_cloud_run_v2_service.default.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Output the service URL
output "service_url" {
  value       = google_cloud_run_v2_service.default.uri
  description = "The URL of the Cloud Run service"
}
