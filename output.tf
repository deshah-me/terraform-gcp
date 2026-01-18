output "instance_name" {
  description = "Name of the compute instance"
  value       = google_compute_instance.terraform-instance.name
}

output "instance_zone" {
  description = "Zone of the compute instance"
  value       = google_compute_instance.terraform-instance.zone
}

output "instance_internal_ip" {
  description = "Internal IP address of the compute instance"
  value       = google_compute_instance.terraform-instance.network_interface[0].network_ip
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "gcloud compute ssh ${google_compute_instance.terraform-instance.name} --zone=${google_compute_instance.terraform-instance.zone} --project=us-con-gcp-sbx-dep0019-081424"
}
