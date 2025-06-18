module "s3_buckets" {
  for_each = {
    bucket1 = {
      bucket_name = "my-bucket-001"
    }
    bucket2 = {
      bucket_name = "my-bucket-002"
    }
    bucket3 = {
      bucket_name = "my-bucket-003"
    }
    bucket4 = {
      bucket_name = "my-bucket-004"
    }
  }

  source = "./modules/s3"
  bucket_name = each.value.bucket_name
  force_dstr = true
}