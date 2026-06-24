variable "ami_id" {
  type = string
}

variable "key_pair_name" {
  type = string
}

variable "application_sg_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}