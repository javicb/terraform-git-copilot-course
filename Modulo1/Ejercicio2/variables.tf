variable "location" {
    description = "The Azure region where the resources will be created."
    type        = string
    default     = "North Europe"
}

variable "environment" {
    description = "The environment where the resources will be deployed."
    type        = string
    default     = "dev"
    validation {
      condition = contains(["dev", "acc", "pro"], var.environment)
      error_message = "El entorno debe ser 'dev', 'acc' o 'pro'"
    }
}

variable "project_name" {
    description = "The name of the project."
    type        = string
    validation {
      condition = can(regex("^[a-zA-Z0-9-]+$", var.project_name))
      error_message = "El nombre del pryecto solo puede contener letras, números y guiones medios."
    }
}

variable "network_config" {
  description = "The network configuration for the project."
  type = object({
    vnet_cidr = string
    public_subnets = list(string)
    enable_nat_gateway = bool
  })

  validation {
    condition = can(cidrnetmask(var.network_config.vnet_cidr))
    error_message = "El campo vnet_cidr en network_config debe ser un bloque CIDR válido"
  }

  validation {
    condition = length(var.network_config.public_subnets) > 0
    error_message = "El campo public_subnets en network_config debe contener al menos una subnet."
  }
}

variable "vm_size" {
  description = "The size of the virtual machines for each environment."
  type        = map(string)
  default     = {
    dev = "Standard_B1s"
    acc = "Standard_B2s"
    pro = "Standard_D2s_v3"
  }
}

variable "admin_username" {
    description = "The administrator username for the VM"
    type        = string
    default     = "adminuser"
}

variable "admin_password" {
    description = "The administrator password for the VM"
    type        = string
}

variable "resource_group_name"{
    description = "Resource group name where the resources will be created."
    type        = string
    default     = "rg-tfcurso-alumno05"
}