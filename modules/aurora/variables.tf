variable "name"               { type = string }
variable "vpc_id"             { type = string }
variable "subnet_ids"         { type = list(string) }
variable "eks_node_sg_id"     { type = string }
variable "db_engine_version"  { type = string }
variable "db_name"            { type = string }
variable "db_master_username" { type = string }
variable "min_acu"            { type = number }
variable "max_acu"            { type = number }
variable "tags"               { type = map(string) }
variable "secret_name"        { type = string }

