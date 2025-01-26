# Create 1 EC2 instance as a Jenkins/Ansible Manage Nodes
resource "aws_instance" "manage_node" {
  ami           = var.ami                  # Replace with the desired AMI ID
  instance_type = var.instance_type_master # Change to the instance type you need

  key_name        = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.ec2_sg.name]
  root_block_device {
    volume_size = var.root_volume_size_master
  }

  tags = {
    Name = "Jenkins-Server"
  }
}

# Create 2 EC2 instances as Jenkins/Ansible agent nodes
resource "aws_instance" "agent_nodes" {
  count         = var.ec2_count
  ami           = var.ami           # Replace with the desired AMI ID
  instance_type = var.instance_type # Change to the instance type you need

  key_name        = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.ec2_sg.name]
  root_block_device {
    volume_size = var.root_volume_size
  }

  tags = local.instance_tags[count.index]
}

# resource "null_resource" "configure_ansible" {
#   provisioner "local-exec" {
#     command = "ansible-playbook -i ${aws_instance.web_server.public_ip}, -u ec2-user --private-key ${aws_key_pair.my_key.key_name}.pem playbook.yml"
#   }

# }

resource "null_resource" "configure_ssh" {
  count = var.ec2_count
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = aws_instance.agent_nodes[count.index].public_ip
  }
  provisioner "file" {
    source      = "~/.ssh/id_rsa.pub"
    destination = "/home/ubuntu/.ssh/id_rsa.pub"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /home/ubuntu/.ssh",
      "sudo cat /home/ubuntu/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys",
      "sudo chmod 600 /home/ubuntu/.ssh/authorized_keys",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh"
    ]
  }
}

resource "null_resource" "dissable_strict_host_key" {
  count = var.ec2_count
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_instance.agent_nodes[count.index].public_ip
    private_key = file("~/.ssh/id_rsa")
  }
  provisioner "remote-exec" {
    inline = [
      "echo 'Host *' >> /home/ubuntu/.ssh/config",
      "echo '  StrictHostKeyChecking no' >> /home/ubuntu/.ssh/config",
      "echo '  UserKnownHostsFile=/dev/null' >> /home/ubuntu/.ssh/config",
      "echo '  LogLevel ERROR' >> /home/ubuntu/.ssh/config", # Suppress the SSH connection warning output
    ]
  }
  depends_on = [aws_instance.agent_nodes]
}