variable "location" {
    description = "The Azure region where the resources will be created."
    type        = string
    default     = "North Europe"
}

variable "resource_group_name"{
    description = "Resource group name where the resources will be created."
    type        = string
    default     = "rg-tfcurso-alumno05"
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

variable "vnet_cidr" {
    description = "The CIDR block for the virtual network."
    type        = string
    default     = "10.20.0.0/16"
    validation {
        condition = can(cidrnetmask(var.vnet_cidr))
        error_message = "El campo vnet_cidr debe ser un bloque CIDR válido"
    }
}

variable "subnets" {
    description = "A map of subnet names to their CIDR blocks."
    type        = map(object({
        cidr              = string
        allow_http        = bool
        allow_private_app = bool
    }))
    default     = {
        "web" = {
            cidr = "10.20.1.0/24", 
            allow_http = true, 
            allow_private_app = false 
        }, 
        "app" = { 
            cidr = "10.20.2.0/24", 
            allow_http = false, 
            allow_private_app = true 
        },
        "db" = { 
            cidr = "10.20.3.0/24", 
            allow_http = false, 
            allow_private_app = false 
        }
    }
    
    validation {
        condition = alltrue([for subnet in var.subnets : can(cidrnetmask(subnet.cidr))])
        error_message = "Todos los CIDR de las subnets deben ser válidos"
    }
}

variable "create_diagnostics_storage" {
    description = "Whether to create a storage account for diagnostics."
    type = bool
    default = false
}

variable "allowed_admin_cidr" {
    description = "A list of CIDR blocks that are allowed to access the admin interface."
    type = string
    default = "0.0.0.0/0"

    validation {
        condition = can(cidrnetmask(var.allowed_admin_cidr))
        error_message = "El campo allowed_admin_cidr debe ser un bloque CIDR válido"
    }
}