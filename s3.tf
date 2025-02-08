resource "aws_s3_bucket" "chip" {
  bucket = format("%s-%s-chip-shared", var.project_name, data.aws_caller_identity.current.account_id)
}

resource "aws_s3_bucket_ownership_controls" "chip" {
  bucket = aws_s3_bucket.chip.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "chip" {
  bucket                  = aws_s3_bucket.chip.id
  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_ownership_controls.chip]
}

resource "aws_s3_bucket_acl" "chip" {
  bucket = aws_s3_bucket.chip.bucket
  acl    = "private"

  depends_on = [aws_s3_bucket_public_access_block.chip]
}