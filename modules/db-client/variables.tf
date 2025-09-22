variable "namespace"            { type = string  }
variable "service_account_name" { type = string  }
variable "irsa_role_arn"        { type = string  }
variable "secret_arn"           { type = string  }
variable "db_endpoint"          { type = string  }
variable "db_name"              { type = string  }
variable "job_name"             { 
    type = string  
    default = "psql-now" 
    }
