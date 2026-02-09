output "rosa_api_url" {
  value = rhcs_cluster_rosa_hcp.rosa.api_url
}

output "rosa_console_url" {
  value = rhcs_cluster_rosa_hcp.rosa.console_url
}

output "ai_worker_status" {
  value = var.enable_ai_worker ? "AI Worker Enabled" : "AI Worker Disabled (Spot Quota Limit)"
}

output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}