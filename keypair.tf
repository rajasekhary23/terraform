# Create a key pair for SSH access
resource "aws_key_pair" "my_key" {
  key_name   = "my-key-pair"
  public_key = file("~/.ssh/id_rsa.pub") # Replace with your public key path
}

# resource "aws_key_pair" "my_key" {
#   key_name   = "my-key-pair"
#   public_key = file("~/.ssh/id_rsa.pub") # Replace with your public key path
# }