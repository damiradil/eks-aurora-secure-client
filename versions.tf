terraform {
  required_version = ">= 1.11.0"
  required_providers {
    aws        = { source = "hashicorp/aws",        version = ">= 5.95, < 6.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.32" }
    kubectl    = { source = "gavinbunney/kubectl",  version = "~> 1.14" }
    random     = { source = "hashicorp/random",     version = "~> 3.6" }
    helm       = { source = "hashicorp/helm",       version = "~> 2.13" }
    tls        = { source = "hashicorp/tls",        version = "~> 4.0" }
    time       = { source = "hashicorp/time",       version = "~> 0.11" }
    cloudinit  = { source = "hashicorp/cloudinit",  version = "~> 2.3" }
    null       = { source = "hashicorp/null",       version = "~> 3.2" }
  }
}

