provider "google" {
  project     = var.catalog_project_id
  # region      = var.region
}

provider "google-beta" {
  project     = var.catalog_project_id
}

resource "google_project_service" "datacatalog" {
    project = var.catalog_project_id
    service = "datacatalog.googleapis.com"
    disable_dependent_services = true
}

resource "random_id" "taxonomy" {
    byte_length = 4
}
