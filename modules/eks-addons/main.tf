# Secrets Store CSI Driver (Helm)
resource "helm_release" "secrets_store_csi" {
  name             = "secrets-store-csi-driver"
  repository       = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart            = "secrets-store-csi-driver"
  namespace        = var.namespace
  create_namespace = false
  wait             = true

  values = [
    yamlencode({
      syncSecret = { enabled = false }
      enableSecretRotation = true
    })
  ]
}

# AWS provider (Helm)
# auto-install of the driver disabled to avoid RBAC/ownership clashes.
resource "helm_release" "secrets_provider_aws" {
  name             = "secrets-provider-aws"
  repository       = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart            = "secrets-store-csi-driver-provider-aws"
  namespace        = var.namespace
  create_namespace = false
  wait             = true
  cleanup_on_fail  = true

  values = [
    yamlencode({
      secrets-store-csi-driver = { install = false }
      serviceAccount = {
        create = false
        name   = "secrets-store-csi-driver"
      }
    })
  ]

  depends_on = [helm_release.secrets_store_csi]
}


