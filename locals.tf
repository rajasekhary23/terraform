# Define dynamic tags in locals
locals {
  instance_tags = [
    for i in range(var.ec2_count) : {
      Name = "AnsibleNode_${i + 1}"
      Role = "AnsibleNode"
    }
  ]
}