output "namespace" {
  description = "Namespace criado"
  value       = kubernetes_namespace.production.metadata[0].name
}

output "deployment_name" {
  description = "Nome do deployment"
  value       = kubernetes_deployment.order_api.metadata[0].name
}

output "service_endpoint" {
  description = "Endpoint interno do serviço"
  value       = "${kubernetes_service.order_api.metadata[0].name}.${kubernetes_namespace.production.metadata[0].name}.svc.cluster.local"
}
