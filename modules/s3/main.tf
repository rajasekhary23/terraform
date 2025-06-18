variable "tags" {
  type    = map(string)
  default = {}
}

variable "bucket_name" {
  type = string
}

variable "force_dstr" {
  type = bool
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
  force_destroy = var.force_dstr
}