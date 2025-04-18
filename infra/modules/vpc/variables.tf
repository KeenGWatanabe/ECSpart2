variable "region" {
  type = string
}

variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}