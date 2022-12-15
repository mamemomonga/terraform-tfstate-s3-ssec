# 256ビットのランダムな値を生成する
resource "random_string" "ssec-key" {
  length           = 32 // 256bit
  special          = true
  override_special = "!*()-_=+[]{}<>:"
}

# Makefikeのテンプレート
resource "local_file" "makefile" {
  filename        = "${path.cwd}/../etc/ssec.mk"
  file_permission = "0600"
  content         = <<EOF
S3_BUCKET      := ${aws_s3_bucket.tfstate.bucket}
S3_SSEC_KEY    := ${random_string.ssec-key.id}
S3_TFSTATE_KEY := ${local.tfstate_s3key}
EOF
}

# terraform backendのテンプレート
resource "local_file" "backend" {
  filename        = "${path.cwd}/../etc/backend.tf"
  file_permission = "0600"
  content         = <<EOF
terraform {
  backend "s3" {
    encrypt          = true
    bucket           = "${aws_s3_bucket.tfstate.bucket}"
    sse_customer_key = "${base64encode(random_string.ssec-key.id)}"
    region           = "ap-northeast-1"
    key              = "${local.tfstate_s3key}"
  }
}
EOF
}