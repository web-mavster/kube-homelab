variable "servers" {
  description = "machines which will run the control plane"
  type = list(object({
    host = string
    user = string
    private_key = string
    ip_static = string
  }))
  default = []
}

variable "commands" {
  description = "commands to run"
  type = list(string)
  default = []
}

variable "is_destroy" {
  description = "destroy or create"
  type = bool
  default = false
}

variable "file_data" {
  description = "file data"
  type = object({
    content = string
    destination = string
    permissions = string
  })
  default = null
  nullable = true
}