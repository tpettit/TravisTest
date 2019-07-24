terraform {
  backend "s3" {
    bucket = "staging-terraform-bucket"
    key    = "externaldns/terraform.tfstate"
    region = "us-east-2"
  }
}
