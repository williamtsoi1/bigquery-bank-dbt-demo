resource "google_service_account" "sa" {
  account_id = "tag-template-owner"
  display_name = "Tag Template owner"
  project = google_project.my_dc_project.project_id
}

resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.sa.name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = [
    "user:${var.terraform_user}",
  ]
}

resource "google_project_iam_binding" "project" {
  project = google_project.my_dc_project.project_id
  role    = "roles/owner"

  members = [
    "serviceAccount:${google_service_account.sa.email}",
  ]
}