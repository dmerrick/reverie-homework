#
# Variables Configuration
#

variable "cluster-name" {
  default = "reverie-hw"
  type    = string
}

variable "profile" {
  description = "Name of your profile inside ~/.aws/credentials"
}

variable "region" {
  default = "us-east-1"
  description = "Defines where your app should be deployed"
}

variable "application_environment" {
  description = "Deployment stage e.g. 'staging', 'production', 'test', 'integration'"
}
