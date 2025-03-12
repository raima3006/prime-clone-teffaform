# DEFINE DEFAULT VARIABLES HERE

variable "ami" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "Instance Type"
  type        = string

}

variable "key_name" {
  description = "EC2 Key Pair"
  type        = string
  default     = "key"
}

variable "volume_size" {
  description = "Volume size"
  type        = string
}

variable "region_name" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "server_name" {
  description = "EC2 Server Name"
  type        = string
}
