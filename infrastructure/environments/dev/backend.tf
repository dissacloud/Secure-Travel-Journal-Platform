terraform {
  backend "s3" {
    key          = "platform/dev/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}