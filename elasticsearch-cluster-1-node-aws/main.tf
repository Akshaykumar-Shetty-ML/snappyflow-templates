/*
###################################################
Copyright 2018, MapleLabs, All Rights Reserved. #
###################################################
                                                 #
   Creating single node elastic search
                                                 #
###################################################
*/
provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  token = "${var.session_token}"
}

data "aws_ami" "ubuntu1604" {
  most_recent = true
  owners = [
    "099720109477"]
  # Canonical

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = [
      "hvm"]
  }
}

data "aws_vpc" "selected_vpc" {
  id = "${var.vpc_id}"
  default = "${var.vpc_id == "" ? true : false}"
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = "${data.aws_vpc.selected_vpc.id}"
}

resource "random_shuffle" "subnets" {
  input = [
    "${data.aws_subnet_ids.subnet_ids.ids}"
  ]
}

data "aws_subnet" "subnet_selected" {
  id = "${var.subnet_id == "" ? random_shuffle.subnets.result.0 : var.subnet_id}"
  vpc_id = "${data.aws_vpc.selected_vpc.id}"
}

resource "aws_security_group" "allow_elasticsearch_traffic" {
  name = "${var.stackname}"
  description = "Allow Elasticsearch traffic"
  vpc_id = "${data.aws_vpc.selected_vpc.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "${data.aws_vpc.selected_vpc.cidr_block}"
    ]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  ingress {
    from_port = 9200
    protocol = "tcp"
    to_port = 9200
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port = 8585
    protocol = "tcp"
    to_port = 8585
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_instance" "master" {
  ami = "${data.aws_ami.ubuntu1604.id}"
  instance_type = "${var.master_instance_type}"
  key_name = "${var.ssh_key_name}"
  associate_public_ip_address = true
  tags {
    Name = "es-master"
    Stack = "${var.stackname}"
  }
  root_block_device {
    volume_type = "gp2"
    volume_size = 10
    delete_on_termination = true
  }
  ebs_block_device {
    device_name = "/dev/sdg"
    volume_type = "${var.master_disk_type}"
    volume_size = "${var.master_disk_size}"
    delete_on_termination = true
  }
  subnet_id = "${data.aws_subnet.subnet_selected.id}"
  vpc_security_group_ids = [
    "${aws_security_group.allow_elasticsearch_traffic.id}"
  ]
  availability_zone = "${data.aws_subnet.subnet_selected.availability_zone}"
}


resource "null_resource" "hosts-master" {
  depends_on = [
    "aws_instance.master"
  ]
  provisioner "local-exec" {
    command = "echo \"master ansible_host=${aws_instance.master.public_ip} ansible_private_host=${aws_instance.master.private_ip}\" >> hosts"
  }
}


