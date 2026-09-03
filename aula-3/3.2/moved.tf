# Migrar state dos nomes antigos (refactored) para os nomes do legacy
moved {
  from = kubernetes_namespace.app
  to   = kubernetes_namespace.ns
}

moved {
  from = kubernetes_service.app
  to   = kubernetes_service.svc
}
