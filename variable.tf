variable "PUBLIC_KEY_PATH" {
    description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
    default = "~/.ssh/eng110_cicd_sam.pub"
}