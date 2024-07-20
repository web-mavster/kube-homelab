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
