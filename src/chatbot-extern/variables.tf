# General Tags AWS
variable "tags" {
  description = "Etiquetas de los recursos"
  type        = map(string)
}

# Instance
variable "details_instances" {
  description = "Parámetros de la instancia"
  type        = map(string)
  default = {
    ami  = "ami-01816d07b1128cd2d"
    type = "t2.micro"
  }
}


# Network
variable "vpc_main_cidr" {
  description = "Dirección ip de la vpc"
  type        = string
}

variable "subnets_main_cidr" {
  description = "Direcciones ips de la vpc para las subnets"
  type        = list(string)
}

# DynamoDB
variable "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB"
  type        = string
  default     = "documents"
}

variable "dynamodb_hash_key" {
  description = "Clave primaria hash de la tabla"
  type        = string
  default     = "id"
}