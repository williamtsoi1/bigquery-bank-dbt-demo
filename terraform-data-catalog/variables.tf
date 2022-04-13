variable "catalog_project_id" {
    description = "The project id of the data catalog project, created in the previous step"
}

variable "datacatalog_location" {
    description = "region for Data Catalog"
    default = "us-central1"
}