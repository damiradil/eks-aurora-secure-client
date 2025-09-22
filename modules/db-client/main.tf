# Namespace
resource "kubernetes_namespace" "ns" {
  metadata { name = var.namespace }
}

# ServiceAccount annotated for IRSA
resource "kubernetes_service_account" "sa" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.irsa_role_arn
    }
    labels = { app = "db-client" }
  }
  automount_service_account_token = true
}

# SecretProviderClass to fetch the secret JSON
resource "kubectl_manifest" "spc" {
  yaml_body = <<YAML
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: db-client-spc
  namespace: ${var.namespace}
spec:
  provider: aws
  parameters:
    objects: |
      - objectName: "${var.secret_arn}"
        objectType: "secretsmanager"
        jmesPath:
          - path: username
            objectAlias: username
          - path: password
            objectAlias: password
YAML

  depends_on = [kubernetes_namespace.ns, kubernetes_service_account.sa]
}

# Job runs: SELECT now();
# Mounts secret files at /mnt/secrets-store/{username,password}
resource "kubernetes_job" "psql_now" {
  metadata {
    name      = var.job_name
    namespace = var.namespace
    labels    = { app = "db-client" }
  }

  # Don't wait during terraform apply
  wait_for_completion = false

  spec {
    backoff_limit = 0
    ttl_seconds_after_finished = 3600

    template {
      metadata { labels = { app = "db-client" } }
      spec {
        service_account_name = var.service_account_name
        restart_policy       = "Never"
        container {
          name  = "psql"
          image = "postgres:16"

          command = ["/bin/sh", "-c"]
          args = [
            <<-SHELL
              set -euo pipefail
              PGUSER="$(cat /mnt/secrets-store/username)"
              PGPASSWORD="$(cat /mnt/secrets-store/password)"
              export PGUSER PGPASSWORD
              echo "Connecting to ${var.db_endpoint}/${var.db_name} ..."
              psql "host=${var.db_endpoint} dbname=${var.db_name} sslmode=require" -tAc "SELECT now();"
            SHELL
          ]

          volume_mount {
            name       = "secrets-store"
            mount_path = "/mnt/secrets-store"
            read_only  = true
          }

          resources {
            limits   = { cpu = "200m", memory = "256Mi" }
            requests = { cpu = "50m",  memory = "64Mi"  }
          }
        }

        volume {
          name = "secrets-store"
          csi {
            driver   = "secrets-store.csi.k8s.io"
            read_only = true
            volume_attributes = {
              "secretProviderClass" = "db-client-spc"
            }
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.spc]
}
