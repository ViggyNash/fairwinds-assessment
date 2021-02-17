variable "key_pair_name" {
  type = string
  default = ""
}

variable "key_pair_path" {
  type = string
  default = ""
}

variable "admin_whitelist" {
  type = list(string)
  default = [ "0.0.0.0/0" ]
}