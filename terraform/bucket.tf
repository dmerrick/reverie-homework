# first we create a new key to encrypt the bucket (at rest)
resource "aws_kms_key" "bucket-key" {
  description = "This is the key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

# next we can create the S3 bucket to store ping logs
resource "aws_s3_bucket" "ping-logs" {
  bucket = "reverie-hw-ping-logs-${var.application_environment}"
  region = var.region

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.bucket-key.arn
        sse_algorithm = "aws:kms"
      }
    }
  }
  tags = {
    Name = "ping-logs bucket - ${var.application_environment}"
  }
}

# in order to improve security, we can create a new IAM policy
# to allow access to the bucket only from the EKS cluster nodes
resource "aws_iam_role_policy" "bucket_iam_role_policy" {
  name = "bucket_iam_role_policy"
  role = aws_iam_role.node-role.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.ping-logs.bucket}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.ping-logs.bucket}/*"]
    }
  ]
}
POLICY
}
