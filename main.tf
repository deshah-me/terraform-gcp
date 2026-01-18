data "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

data "google_compute_subnetwork" "subnet" {
  name   = "terraform-subnet"
  region = "us-east1"
}

resource "google_compute_firewall" "allow_iap_ssh" {
  name      = "allow-iap-ssh"
  network   = data.google_compute_network.vpc_network.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["iap-ssh"]
}

resource "google_compute_firewall" "allow_egress" {
  name      = "allow-egress"
  network   = data.google_compute_network.vpc_network.name
  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["iap-ssh"]
}

resource "google_compute_firewall" "allow_http" {
  name      = "allow-http-iap"
  network   = data.google_compute_network.vpc_network.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["iap-ssh"]
}

resource "google_compute_instance" "terraform-instance" {
  name         = "terraform-instance"
  machine_type = "e2-medium"
  zone         = "us-east1-b"
  tags         = ["iap-ssh"]


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }


  network_interface {
    network    = data.google_compute_network.vpc_network.name
    subnetwork = data.google_compute_subnetwork.subnet.name
  }
  metadata_startup_script = file("${path.module}/nginx.sh")

}


## gcloud compute ssh terraform-instance --zone=us-east1-b --project=us-con-gcp-sbx-dep0019-081424 
## to run compute engine in vscode terminal command
## to format terraform script use terraform fmt


  # HOW TO CREATE SERVICE ACCOUNT AND GET KEYS (keys.json):
  # 1. Go to Google Cloud Console: https://console.cloud.google.com/
  # 2. Navigate to: IAM & Admin > Service Accounts
  # 3. Click "CREATE SERVICE ACCOUNT"
  # 4. Enter a name (e.g., "terraform-sa") and description
  # 5. Click "CREATE AND CONTINUE"
  # 6. Grant roles: Permissions (optional) -> Basic -> Owner
  # 7. Click "CONTINUE" and then "DONE"
  # 8. Click on the created service account
  # 9. Go to "KEYS" tab > "ADD KEY" > "Create new key"
  # 10. Select "JSON" format and click "CREATE"
  # 11. The JSON key file will download automatically - save it as "keys.json" in this directory
  # 
  # OR using gcloud CLI:
  # gcloud iam service-accounts create terraform-sa --display-name="Terraform Service Account"
  # gcloud projects add-iam-policy-binding PROJECT_ID --member="serviceAccount:terraform-sa@PROJECT_ID.iam.gserviceaccount.com" --role="roles/compute.admin"
  # gcloud iam service-accounts keys create keys.json --iam-account=terraform-sa@PROJECT_ID.iam.gserviceaccount.com
