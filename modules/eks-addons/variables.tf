variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "Namespace where the CSI driver and provider run"
}
