variable "gitops_repo_url" {
  description = "URL for the repo gitops-platform"
  type        = string
}
variable "target_revision" {
  description = "branch to follow by Argo"
  type        = string
  default     = "main"
}
