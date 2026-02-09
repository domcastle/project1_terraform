output "ai_worker_status" {
  value = var.enable_ai_worker ? "AI Worker Enabled" : "AI Worker Disabled (Spot Quota Limit)"
}
