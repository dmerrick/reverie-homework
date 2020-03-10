#
# Provider Configuration
#

provider "aws" {
  profile = var.profile
  region  = var.region
  version = ">= 2.38.0"
}

# Using these data sources allows the configuration to be
# generic for any region.
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

# This is used to determine the IP of the computer running
# terraform, in order to open EC2 Security Group access to
# the Kubernetes cluster.
# See workstation-external-ip.tf for additional information.
provider "http" {}
