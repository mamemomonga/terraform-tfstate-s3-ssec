# AWS プロバイダ
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.32.0"
    }
  }
  required_version = ">= 1.1.6"
}

# AWS 東京リージョン
provider "aws" {
  region = "ap-northeast-1"
  # AWSプロファイル
  #   これを設定しない場合は、デフォルトが使用される
  #   明示する場合はここで設定するか
  #   export AWS_DEFAULT_PROFILEでプロファイルを指定すること
  # profile = "myprofile"
}
