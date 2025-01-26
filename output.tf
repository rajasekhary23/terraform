# output instance public IP
output "instance_public_ip" {
value = {
    manage_node = aws_instance.manage_node.public_ip
    agent_nodes = aws_instance.agent_nodes[*].public_ip
}
}