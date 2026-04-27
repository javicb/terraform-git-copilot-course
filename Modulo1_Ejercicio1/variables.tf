variable "resource_group_name"{
    description = "Nombre del grupo de recursos"
    type        = string
    default     = "rg-tfcurso-alumno05"
}

variable "admin_username" {
    description = "Nombre del usuario administrador de la VM"
    type        = string
    default     = "adminuser"
}

variable "admin_password" {
    description = "Contraseña del usuario administrador de la VM"
    type        = string
}

variable "location" {
    description = "Ubicación del recurso"
    type        = string
}

