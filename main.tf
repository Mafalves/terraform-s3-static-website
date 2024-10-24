
# Step 1: Set Up Terraform Environment
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# Step 2: Define the Provider Configuration
# Use a variable for region to maintain flexibility in resource deployment.
provider "aws" {
  region = var.region
}

# Step 3: Create the S3 Bucket
# Define the S3 bucket that will host the static website.
resource "aws_s3_bucket" "static_website" {
  bucket = "mateusalves-staticwebiste-terraform-102324"
}

# Step 4: Set Ownership Controls
# Manage ownership of objects in the bucket.
resource "aws_s3_bucket_ownership_controls" "static_website_ownership" {
  bucket = aws_s3_bucket.static_website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Step 5: Configure Public Access Settings
# Public Access Block to control access settings for the bucket.
resource "aws_s3_bucket_public_access_block" "static_website_public_access" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Step 6: Bucket ACL
# Set the bucket's ACL to public-read.
resource "aws_s3_bucket_acl" "static_website_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.static_website_ownership,
    aws_s3_bucket_public_access_block.static_website_public_access,
  ]

  bucket = aws_s3_bucket.static_website.id
  acl    = "public-read"
}

# Step 8: Configure Static Website Hosting
# Set up the website configuration for the S3 bucket.
resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Step 8: Set Up Bucket Policy for Public Access
# Define a policy to allow public access to the bucket objects.
resource "aws_s3_bucket_policy" "public_access" {
  bucket = aws_s3_bucket.static_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_website.arn}/*"
      }
    ]
  })
}

# Step 9: Upload Website Files
# Use aws_s3_object to upload the static files for the website.
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.static_website.id
  key    = "index.html"
  source = "website/index.html"
  content_type = "text/html"  # Set the correct content type
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.static_website.id
  key    = "error.html"
  source = "website/error.html"
  content_type = "text/html"  # Set the correct content type
}

# Step 10: Define Outputs
# Outputs for easy retrieval of bucket name and website URL.
output "bucket_name" {
  value = aws_s3_bucket.static_website.id
}

output "website_url" {
  value = "http://${aws_s3_bucket.static_website.id}.s3-website-${var.region}.amazonaws.com"
}
