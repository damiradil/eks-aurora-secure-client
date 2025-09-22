variable "oidc_provider_arn" {
  type        = string
  description = "EKS OIDC provider ARN (module.eks.oidc_provider_arn)"
}
variable "namespace" {
  type        = string
  description = "K8s namespace for the ServiceAccount"
}
variable "service_account_name" {
  type        = string
  description = "K8s ServiceAccount name to bind"
}
variable "secret_arn" {
  type        = string
  description = "ARN of the Secrets Manager secret to read"
}
variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN used to encrypt the secret"
}
variable "role_name" {
  type        = string
  default     = null
  description = "Optional fixed name for the IAM role"
}
variable "tags" {
  type        = map(string)
  default     = {}
}
