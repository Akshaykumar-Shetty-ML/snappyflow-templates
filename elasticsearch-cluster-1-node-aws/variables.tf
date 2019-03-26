/*
###################################################
Copyright 2018, MapleLabs, All Rights Reserved. #
###################################################
                                                 #
   Creating single node elastic search
                                                 #
###################################################
*/
variable "region" {}

variable "access_key" {}

variable "secret_key" {}

variable "session_token" {
  default = ""
}

variable "ssh_user" {}

variable "stackname" {}

variable "vpc_id" {
  default = ""
}

variable "subnet_id" {
  default = ""
}

variable "master_instance_type" {
  default = "t2.large"
}

variable "master_disk_type" {
  default = "standard"
}

variable "master_disk_size" {
  default = 20
}

variable "playbookpath" {
  default = "./ansible"
}

variable "playbookname" {
  default = "playbook.yml"
}

variable "ssh_key_name" {
  default = "shared-SSHkey-fordemo"
}

variable "ssh_key_path" {
  default = "./keys"
}