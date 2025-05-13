locals {
  dataset_name_final = var.dataset_name != "" ? var.dataset_name : var.bucket_name
}

data "aws_kms_key" "kms-key" {
  key_id = "alias/cloudtrail-key"
}

#Create S3 buckets for the dataset
resource "aws_s3_bucket" "s3_bucket" {
  count  = var.is_bucket_onboarding ? 1 : 0
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  tags          = {
                    Description  = "Landing bucket for ${local.dataset_name_final}"
                    Team         = var.team_name
                    Data_Classification = var.data_classification
                    Environment  = var.environment
                    Dataset      = local.dataset_name_final
                  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_kms" {
  count  = var.is_bucket_onboarding ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket[count.index].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.aws_kms_key.kms-key.id
    }
  }
}

#Enable Versioning for tamper-evidence
resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  count  = var.is_bucket_onboarding ? 1 : 0
  bucket    = aws_s3_bucket.s3_bucket[count.index].id
  versioning_configuration {
    status = "Enabled"
  }
}

#Create folders
resource "aws_s3_object" "folders" {
  for_each = var.is_bucket_onboarding ? toset(var.folder_prefixes) :toset([])
  bucket = aws_s3_bucket.s3_bucket[0].id
  key    = "${each.key}/"
  storage_class = "STANDARD"
  content = ""
}

#Create partitions
resource "aws_s3_object" "partitions" {
  for_each = var.is_bucket_onboarding ? toset(var.partition_paths) : toset([])
  bucket   = aws_s3_bucket.s3_bucket[0].id
  key      = "${each.value}/"
  content  = ""
}

resource "aws_s3_bucket_lifecycle_configuration" "my_bucket_lifecycle" {
  count  = var.is_bucket_onboarding ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket[count.index].id
  rule {
    id     = "ExpireObjectsAfter7Days"
    status = "Enabled"
    expiration {
      days = var.retention_period
    }
  }
}

resource "aws_s3_bucket_policy" "read_only_policy" {
  count = var.is_access_request ? 1 : 0
  bucket = var.bucket_name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = var.principal_arn
        },
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}
