# Master node
variable "instance_type_master" {
  description = "The type of EC2 instance to launch"
  type        = string
  default     = "t2.medium" # Default instance type
}
variable "root_volume_size_master" {
  description = "The size of the root volume in GB"
  type        = number
  default     = 16 # Default size of the root volume
}
# Ansible nodes
variable "ec2_count" {
  description = "Number of ansible nodes"
  type        = number
  default     = 2
}
variable "root_volume_size" {
  description = "The size of the root volume in GB"
  type        = number
  default     = 8 # Default size of the root volume
}
variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
  default     = "t2.micro" # Default instance type
}
variable "ami" {
  description = "The AMI to use for the EC2 instance"
  type        = string
  default     = "ami-04b4f1a9cf54c11d0" # Default AMI
}