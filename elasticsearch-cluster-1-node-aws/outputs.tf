/*
###################################################
Copyright 2018, MapleLabs, All Rights Reserved. #
###################################################
                                                 #
   Creating single node elastic search
                                                 #
###################################################
*/
output "master" {
  value = "${aws_instance.master.public_ip}"
}

