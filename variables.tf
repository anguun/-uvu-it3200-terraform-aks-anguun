variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "student_name" {
  description = "Student identifier for resource names (lowercase letters and numbers only, e.g. anguun)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.student_name))
    error_message = "student_name must be lowercase letters and numbers only (ACR names allow no hyphens)."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "westus2"
}

variable "node_vm_size" {
  description = "AKS node VM size. Use a small size; change it if your subscription restricts this one."
  type        = string
  default     = "Standard_B2s"
}

variable "node_count" {
  description = "Number of AKS nodes."
  type        = number
  default     = 1
}

variable "app_namespace" {
  description = "Kubernetes namespace the test app is deployed into."
  type        = string
  default     = "demo-app"
}

variable "create_service_principal" {
  description = "Create the Entra application + service principal and its role assignments. Requires permission to register Entra apps."
  type        = bool
  default     = false
}
