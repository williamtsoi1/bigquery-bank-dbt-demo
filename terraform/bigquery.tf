module "bigquery_raw" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 4.4"

  dataset_id                  = "raw"
  dataset_name                = "raw dataset"
  description                 = "Contains raw data ingested from operational systems"
  project_id                  = google_project.my_project.project_id
  location                    = var.bigquery_location
  delete_contents_on_destroy  = true
  # default_table_expiration_ms = 3600000

  depends_on = [
    google_project_service.bigquery,
  ]
}