variable "subscription_id" {
  type        = string
  description = "ID de suscripción de Azure que ejecutará el proyecto"
}

variable "location" {
  type        = string
  description = "Región Azure. Ejemplo: brazilsouth o eastus"
  default     = "brazilsouth"
}

variable "project" {
  type        = string
  description = "Prefijo de nombres del proyecto"
  default     = "pm04todo"
}

variable "environment" {
  type        = string
  description = "Ambiente de ejecución"
  default     = "dev"
}

variable "admin_username" {
  type        = string
  description = "Usuario SSH Linux"
  default     = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "CONTENIDO de tu clave SSH pública (no enviar nunca la clave privada)"
}

variable "admin_cidr" {
  type        = string
  description = "Tu IP pública de administración terminada en /32; jamás 0.0.0.0/0"

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0)) && var.admin_cidr != "0.0.0.0/0"
    error_message = "admin_cidr debe ser un CIDR válido y no puede ser 0.0.0.0/0."
  }
}

variable "app_vm_size" {
  type        = string
  description = "Tamaño de la VM de aplicación (confirmar disponibilidad y costo)"
  default     = "Standard_B2s"
}

variable "db_vm_size" {
  type        = string
  description = "Tamaño de la VM MongoDB (confirmar disponibilidad y costo)"
  default     = "Standard_B2s"
}

variable "mongo_disk_gb" {
  type        = number
  description = "Tamaño de disco independiente destinado a datos MongoDB"
  default     = 32
}

# Controla los recursos NAT y su IP publica asociados a la subred privada de DB.
variable "enable_nat_gateway" {
  type        = bool
  description = "Si true, crea NAT Gateway para salida a internet de la VM MongoDB. Si false, elimina NAT e IP publica sin tocar las VMs ni discos."
  default     = true
}
