variable "tags" {
  description = "Etiquetas de los recursos"
  type        = map(string)
}

variable "details_instances" {
  description = "Parámetros de la instancia"
  type        = map(string)
  default = {
    ami  = "ami-01816d07b1128cd2d"
    type = "t2.micro"
  }
}