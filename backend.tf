terraform {
  backend "s3" {
    bucket       = "helium-tfstate-dm"
    key          = "helium/terraform.tfstate"
    region       = "us-east-2"
    profile      = "default"
    encrypt      = true
    use_lockfile = true
  }
}

