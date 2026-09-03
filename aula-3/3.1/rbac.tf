# --- RBAC: ServiceAccount + Role + RoleBinding ---
# Este arquivo é gerado na segunda iteração com IA (passo 5 do roteiro)

resource "kubernetes_service_account" "order_api" {
  metadata {
    name      = "${var.app_name}-sa"
    namespace = kubernetes_namespace.production.metadata[0].name
  }
}

resource "kubernetes_role" "order_api" {
  metadata {
    name      = "${var.app_name}-role"
    namespace = kubernetes_namespace.production.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "secrets"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "order_api" {
  metadata {
    name      = "${var.app_name}-rolebinding"
    namespace = kubernetes_namespace.production.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.order_api.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.order_api.metadata[0].name
    namespace = kubernetes_namespace.production.metadata[0].name
  }
}
