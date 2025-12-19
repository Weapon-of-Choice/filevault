// S3 File Vault Bucket
resource "aws_s3_bucket" "filevault_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "File Vault Bucket"
    Environment = "Production"
  }
}