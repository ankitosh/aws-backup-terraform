data "aws_caller_identity" "current" {}
# provider "aws" {
#   access_key = var.access_key
#   secret_key = var.secret_key
#   region     = var.region_name
# }
# terraform {

#   backend "s3" {
#     bucket        = "YOUR-BUCKET-NAME-tf-state-dev"
#     key           = "YOUR_BACKUP_SCHEDULE.tfstate"
#     region        = "YOUR_REGION_BUCKET"
#     encrypt       = true
#   }
#}