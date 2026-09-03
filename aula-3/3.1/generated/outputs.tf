output "namespace" {
  value = kubernetes_namespace.app.metadata[0].name
}

output "deployment_name" {
  value = kubernetes_deployment.app.metadata[0].name
}

output "service_endpoint" {
  value = "${kubernetes_service.app.metadata[0].name}.${kubernetes_namespace.app.metadata[0].name}.svc.cluster.local"
}
