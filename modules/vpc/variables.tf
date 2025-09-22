variable "name"          { type = string }
variable "cidr"          { type = string }
variable "az_count"      { type = number }
variable "private_cidrs" { type = list(string) }
variable "public_cidrs"  { type = list(string) }
variable "tags"          { type = map(string) }
variable "cluster_name"  { type = string }