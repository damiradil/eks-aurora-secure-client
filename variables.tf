variable "project_name" {
  type        = string
  description = "Name prefix for resources"
  default     = "helium" 
}

variable "cluster_name"{
  type        = string
  description = "Name prefix for resources"
  default     = ""
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.20.0.0/16"
}

variable "az_count" {
  type        = number
  description = "AZ"
  default     = 2
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.0.0/19", "10.20.32.0/19"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.96.0/20", "10.20.112.0/20"]
}

variable "eks_cluster_version" {
  type        = string
  description = "EKS Kubernetes version"
  default     = "1.33"
}

variable "eks_endpoint_public_access" {
  type        = bool
  description = "Public EKS API (restrict by CIDRs below)"
  default     = true
}

variable "eks_public_access_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to reach the public EKS API endpoint"
  default     = ["0.0.0.0/0"] # change to your IP/CIDR for tighter security
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "take-home-assignment"
    ManagedBy   = "terraform"
  }
}

variable "db_engine_version" { 
  type = string
  default = null 
  }

variable "db_name"             { 
  type = string
  default = "appdb" 
  }

variable "db_master_username"  { 
  type = string
  default = "app_admin" 
  }

# Aurora Serverless v2 capacity (cheap)
variable "aurora_min_acu"      { 
  type = number
  default = 0.5 
  }
  
variable "aurora_max_acu"      { 
  type = number
  default = 1 
  }
