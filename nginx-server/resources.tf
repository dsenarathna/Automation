# Define SSH key pair for our instances
resource "aws_key_pair" "nginx_key" {
  key_name = "id_rsa"
  public_key = "${file("${var.key_path}")}"
}

# Define webserver inside the public subnet
resource "aws_instance" "nginx_wb" {
   ami  = "${var.ami}"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.nginx_key.id}"
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sgweb.id}"]
   associate_public_ip_address = true
   source_dest_check = false
   user_data = "${file("userdata-nginx.sh")}"

  tags = {
    Name = "nginx-webserver"
  }
}

