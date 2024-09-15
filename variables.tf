variable "location" {
  description = "The Azure Region in which all resources should be created."
  default     = "East US"
}

variable "environment" {
  description = "Environment tag for resources."
  default     = "dev"
}
