output "data_project_id" {
    value = google_project.my_project.project_id
}
output "catalog_project_id" {
    value = google_project.my_dc_project.project_id
}
output "tag_template_sa_email" {
    value = google_service_account.sa.email
}