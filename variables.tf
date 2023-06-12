# Declare target_group_arn variable
variable "target_group_arn" {
  type    = string
  default = "aws_lb_target_group.target-group.arn"
}

#Declare shell commands for web server
variable "user_data_web" {
  type    = string
  default = "file(web.sh)" 
}

#Declare commands for database
variable "user_data_db" {
  type    = string
  default = "file(db.sh)"
}