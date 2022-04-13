provider "google" {
  project     = "${var.project_prefix}-${random_id.project.hex}"
  # region      = var.region
}

# Create a random 4 byte suffix on the project id to prevent id collisions
resource "random_id" "project" {
    byte_length = 4
}

# project for BigQuery Bank Data
resource "google_project" "my_project" {
    name = "dbt demo data project"
    project_id = "${var.project_prefix}-${random_id.project.hex}"
    billing_account = var.billing_account_id
}

# project for Data Catalog
resource "google_project" "my_dc_project" {
    name = "dbt demo catalog project"
    project_id = "${var.project_prefix}-${random_id.project.hex}-dc"
    billing_account = var.billing_account_id
}

# Enable APIs
resource "google_project_service" "bigquery" {
    project = google_project.my_project.project_id
    service = "bigquery.googleapis.com"
    disable_dependent_services = true
}

resource "google_project_service" "resource_manager" {
    project = google_project.my_dc_project.project_id
    service = "cloudresourcemanager.googleapis.com"
    disable_dependent_services = true
}

resource "google_project_service" "service_usage" {
    project = google_project.my_dc_project.project_id
    service = "serviceusage.googleapis.com"
    disable_dependent_services = true
}