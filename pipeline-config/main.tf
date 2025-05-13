locals {
  dataset_name_final = var.dataset_name != "" ? var.dataset_name : var.bucket_name
}

data "aws_kms_key" "kms-key" {
  key_id = "alias/cloudtrail-key"
}

#Create S3 buckets for the dataset
resource "aws_s3_bucket" "s3_bucket" {
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
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.aws_kms_key.kms-key.id
    }
  }
}

#Enable Versioning for tamper-evidence
resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket    = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#Create folders
resource "aws_s3_object" "folders" {
  for_each = toset(var.folder_prefixes)
  bucket = aws_s3_bucket.s3_bucket.id
  key    = "${each.key}/"
  storage_class = "STANDARD"
  content = ""
}

#Create partitions
resource "aws_s3_object" "partitions" {
  for_each = toset(var.partition_paths)
  bucket   = aws_s3_bucket.s3_bucket.id
  key      = "${each.value}/"
  content  = ""
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
