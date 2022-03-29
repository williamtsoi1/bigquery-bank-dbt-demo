provider "google-beta" {
  project     = "${var.project_prefix}-${random_id.project.hex}"
}

resource "google_data_catalog_policy_tag" "pii" {
  provider = google-beta
  taxonomy = google_data_catalog_taxonomy.bigquery_bank.id
  display_name = "PII"
  description = "PII data elements"
}

resource "google_data_catalog_policy_tag" "child_policy" {
  provider = google-beta
  taxonomy = google_data_catalog_taxonomy.bigquery_bank.id
  display_name = "SSN"
  description = "Social Security Number"
  parent_policy_tag = google_data_catalog_policy_tag.pii.id
}

resource "google_data_catalog_policy_tag" "child_policy2" {
  provider = google-beta
  taxonomy = google_data_catalog_taxonomy.bigquery_bank.id
  display_name = "First Name"
  description = "First Name"
  parent_policy_tag = google_data_catalog_policy_tag.pii.id
  // depends_on to avoid concurrent delete issues
  depends_on = [google_data_catalog_policy_tag.child_policy]
}

resource "google_data_catalog_policy_tag" "child_policy3" {
  provider = google-beta
  taxonomy = google_data_catalog_taxonomy.bigquery_bank.id
  display_name = "Last Name"
  description = "Last Name"
  parent_policy_tag = google_data_catalog_policy_tag.pii.id
  // depends_on to avoid concurrent delete issues
  depends_on = [google_data_catalog_policy_tag.child_policy2]
}

resource "google_data_catalog_policy_tag" "child_policy4" {
  provider = google-beta
  taxonomy = google_data_catalog_taxonomy.bigquery_bank.id
  display_name = "dob"
  description = "Date of Birth"
  parent_policy_tag = google_data_catalog_policy_tag.pii.id
  // depends_on to avoid concurrent delete issues
  depends_on = [google_data_catalog_policy_tag.child_policy3]
}

resource "google_data_catalog_policy_tag" "child_policy5" {
  provider = google-beta
  taxonomy = google_data_catalog_taxonomy.bigquery_bank.id
  display_name = "address"
  description = "Address"
  parent_policy_tag = google_data_catalog_policy_tag.pii.id
  // depends_on to avoid concurrent delete issues
  depends_on = [google_data_catalog_policy_tag.child_policy4]
}

resource "google_data_catalog_taxonomy" "bigquery_bank" {
  provider = google-beta
  region = var.bigquery_location
  project = google_project.my_project.project_id
  display_name =  "BigQuery Bank"
  description = "Policy tags for BigQuery Bank"
  # activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]

  depends_on = [
    google_project_service.datacatalog,
  ]
}