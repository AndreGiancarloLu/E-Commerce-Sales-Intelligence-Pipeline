terraform {
  required_version = ">= 0.12"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# --- GCS Bucket ---
resource "google_storage_bucket" "raw_bucket" {
  name     = var.bucket_name
  location = var.region
}

# --- BigQuery Dataset ---
resource "google_bigquery_dataset" "raw_dataset" {
  dataset_id = "raw"
  location   = var.region
}

# --- Service Account ---
resource "google_service_account" "pipeline_sa" {
  account_id   = "ecommerce-pipeline-sa"
  display_name = "E-Commerce Pipeline Service Account"
}

# --- IAM Bindings ---

# Run BigQuery jobs (required for copy_table, queries, dbt)
resource "google_project_iam_member" "bq_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.pipeline_sa.email}"
}

# Read/write tables and datasets in BigQuery
resource "google_project_iam_member" "bq_data_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.pipeline_sa.email}"
}

# Read from the public dataset in bigquery-public-data
resource "google_project_iam_member" "bq_data_viewer" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${google_service_account.pipeline_sa.email}"
}

# Read and write parquet files to your GCS bucket
resource "google_storage_bucket_iam_member" "gcs_object_admin" {
  bucket = google_storage_bucket.raw_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.pipeline_sa.email}"
}

# Generate and download the key file
resource "google_service_account_key" "pipeline_sa_key" {
  service_account_id = google_service_account.pipeline_sa.name
}

output "service_account_key" {
  value     = google_service_account_key.pipeline_sa_key.private_key
  sensitive = true
}