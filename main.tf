# Cloud SQL PostgreSQL Instance
resource "google_sql_database_instance" "postgres_instance" {
  name             = "postgres-instance-${random_id.db_suffix.hex}"
  database_version = "POSTGRES_15"
  region           = "us-east1"
  
  settings {
    tier = "db-f1-micro"
    
    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }
    
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "allow-all"
        value = "0.0.0.0/0"  # Change this to your specific IP range for security
      }
    }
    
    database_flags {
      name  = "max_connections"
      value = "100"
    }
  }
  
  deletion_protection = false  # Set to true in production
}

# Random suffix for unique instance name
resource "random_id" "db_suffix" {
  byte_length = 4
}

# PostgreSQL Database
resource "google_sql_database" "database" {
  name     = "my-database"
  instance = google_sql_database_instance.postgres_instance.name
}

# Root user password
resource "random_password" "root_password" {
  length  = 16
  special = true
}

# Set root user password
resource "google_sql_user" "root_user" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres_instance.name
  password = random_password.root_password.result
}

# Application user
resource "random_password" "app_user_password" {
  length  = 16
  special = true
}

resource "google_sql_user" "app_user" {
  name     = "app_user"
  instance = google_sql_database_instance.postgres_instance.name
  password = random_password.app_user_password.result
}

# Service Account for Cloud SQL access
resource "google_service_account" "sql_client" {
  account_id   = "sql-client-sa"
  display_name = "Cloud SQL Client Service Account"
}

# IAM Permissions for Cloud SQL
resource "google_project_iam_member" "sql_client_role" {
  project = "us-con-gcp-sbx-dep0019-081424"
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.sql_client.email}"
}

# Additional permission for Cloud SQL Editor (if needed for management)
resource "google_project_iam_member" "sql_editor_role" {
  project = "us-con-gcp-sbx-dep0019-081424"
  role    = "roles/cloudsql.editor"
  member  = "serviceAccount:${google_service_account.sql_client.email}"
}

# Outputs
output "instance_connection_name" {
  value       = google_sql_database_instance.postgres_instance.connection_name
  description = "Connection name for Cloud SQL Proxy"
}

output "instance_ip_address" {
  value       = google_sql_database_instance.postgres_instance.public_ip_address
  description = "Public IP address of the instance"
}

output "database_name" {
  value       = google_sql_database.database.name
  description = "Database name"
}

output "root_password" {
  value       = random_password.root_password.result
  sensitive   = true
  description = "Root user password"
}

output "app_user_name" {
  value       = google_sql_user.app_user.name
  description = "Application user name"
}

output "app_user_password" {
  value       = random_password.app_user_password.result
  sensitive   = true
  description = "Application user password"
}

output "service_account_email" {
  value       = google_service_account.sql_client.email
  description = "Service account email for Cloud SQL access"
}

