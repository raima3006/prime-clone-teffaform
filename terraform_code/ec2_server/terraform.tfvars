# DEFINE ALL YOUR VARIABLES HERE

ami           = "ami-053f2979ba3826edf" # Ubuntu 24.04
instance_type = "t2.medium"
key_name      = "key" # Replace with your key-name without .pem extension
volume_size   = 30
region_name   = "ap-south-1"
server_name   = "JENKINS-SERVER"

# Note: 
# a. First create a pem-key manually from the AWS console
# b. Copy it in the same directory as your terraform code
