resource "aws_security_group" "gha-tf-ans-demo-control" {
  name        = "gha-tf-ans-demo-control"
  description = "Security Group"

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "gha-tf-ans-demo-targets" {
  name        = "gha-tf-ans-demo-targets"
  description = "Security Group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "control" {
  ami                    = "ami-0aa7d40eeae50c9a9"
  instance_type          = "t2.micro"
  key_name               = "preston"
  vpc_security_group_ids = [aws_security_group.gha-tf-ans-demo-control.id]

  tags = {
    Name = "prestoncontrol"
  }


  provisioner "remote-exec" {
    inline = [
      "echo 'hello world!'",
      "pwd",
      "sudo yum update -y",
      "sudo amazon-linux-extras install ansible2 -y",
      "mkdir -p home/ec2-user/.ssh/", # -p will create nested directories if they don't already exist, allowing us to avoid errors
      "echo '${file(var.ssh_private_key_path)}' > home/ec2-user/.ssh/preston.pem",
      "chmod 600 home/ec2-user/.ssh/preston.pem",
      "echo '[ansible-target]' > home/ec2-user/inventory.ini",
      "echo '${aws_instance.target.private_ip} ansible_ssh_private_key_file=home/ec2-user/.ssh/ansible.pem ansible_ssh_common_args=\"-o StrictHostKeyChecking=no\"' >> home/ec2-user/inventory.ini",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible all -i home/ec2-user/inventory.ini -m ping",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i home/ec2-user/inventory.ini /home/ec2-user/deploy_flask_app.yml"
    ]
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.ssh_private_key_path)
    }
  }
  provisioner "file" {
    source      = "project/project/deploy_flask_app.yml"
    destination = "home/ec2-user/deploy_flask_app.yml"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.ssh_private_key_path)
    }
  }
}

resource "aws_instance" "target" {
  ami                     = "ami-0aa7d40eeae50c9a9"
  instance_type           = "t2.micro"
  key_name               = "preston"
   vpc_security_group_ids = [aws_security_group.gha-tf-ans-demo-targets.id] 
  tags = {
    Name = "target"
  }

}
