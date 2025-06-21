module "s3_buckets" {
  for_each = {
    bucket1 = {
      bucket_name = "my-bucket-001"
      force_dstr = true
      tags = {
        owner = "YRS"
      }
    }
    bucket2 = {
      bucket_name = "my-bucket-002"
      force_dstr = true
      tags = {
        
      }
    }
    bucket3 = {
      bucket_name = "my-bucket-003"
      force_dstr = false
      tags = {
        
      }
    }
    bucket4 = {
      bucket_name = "my-bucket-004"
      force_dstr = true
      tags = {
        
      }
    }
  }

  source = "./modules/s3"
  bucket_name = each.value.bucket_name
  force_dstr = each.value.force_dstr
  tags = each.value.tags
}