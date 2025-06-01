variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  default     = "terraform-jenkins"
  description = "Name of your existing EC2 key pair"
}

variable "public_key_path" {
  default     = "/Users/gopalkhanal/.ssh/id_rsa.pub"
  description = "Path to your public SSH key"
}
