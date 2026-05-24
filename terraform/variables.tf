variable "project_id" {
  description = "The ID of the project in which to create the resources."
  type        = string
  default     = "career-practice"
}

variable "region" {
  description = "The region in which to create the resources."
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "The name of the GCS bucket to create."
  type        = string
  default     = "career-practice-ecommerce-data-bucket"
}