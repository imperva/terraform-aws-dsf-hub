# DSF Hub
[![GitHub tag](https://img.shields.io/github/v/tag/imperva/dsfkit.svg)](https://github.com/imperva/dsfkit/tags)

This Terraform module provisions an all-in-one data security and compliance platform, known as the DSF Hub, on AWS as an EC2 instance.

## Sonar versions
  - 4.10 (recommended)
  - 4.9

## Requirements
* Terraform v1.3.1.
* An AWS account.
* SSH access - key and network path to the DSF Hub instance.
* Access to the tarball containing Sonar binaries. To request access, [click here](https://docs.google.com/forms/d/e/1FAIpQLSdnVaw48FlElP9Po_36LLsZELsanzpVnt8J08nymBqHuX_ddA/viewform).

**NOTE:** In case you are not yet an Imperva customer, [please contact our team](https://www.imperva.com/contact-us/).

## Resources Provisioned
This Terraform module provisions several resources on AWS to create the DSF Hub. These resources include:
* An EC2 instance for running the DSF Hub software.
* An EBS volume for storage.
* A security group to allow the required network access to and from the DSF Hub instance.
* An IAM role with relevant policies.
* An AWS secret containing the secret required for attaching new Agentless Gateways.
* An AWS Elastic Network Interface (ENI).

The EC2 instance and EBS volume provide the computing and storage resources needed to run the DSF Hub software. The security group controls the inbound and outbound traffic to the instance, while the IAM role grants the necessary permissions to access AWS resources. The AWS secret is used in the process of attaching a new Agentless Gateway to the DSF Hub.

## Inputs

The following input variables are **required**:

* `subnet_id`: The ID of the subnet in which to launch the DSF Hub instance
* `ssh_key_pair`: AWS key pair name and path for ssh connectivity
* `web_console_admin_password`: Admin password
* `ingress_communication`: List of allowed ingress CIDR patterns for the Agentless Gateway instance for ssh and internal protocols
* `ebs`: AWS EBS details
* `binaries_location`: S3 DSF installation location
* `sonarw_public_key`: Public key of the sonarw user taken from the primary DSF Hub output. This variable must only be defined for the secondary DSF Hub.
* `sonarw_private_key`: Private key of the sonarw user taken from the primary DSF Hub output. This variable must only be defined for the secondary DSF Hub.

Refer to [variables.tf](variables.tf) for additional variables with default values and additional info

## Outputs

The following [outputs](outputs.tf) are exported:

* `public_ip`: public address
* `private_ip`: private address
* `public_dns`: public dns
* `private_dns`: private dns
* `display_name`: Display name of the instance under DSF portal
* `jsonar_uid`: Id of the instance in DSF portal
* `iam_role`: AWS IAM arn
* `sg_id`: AWS security group id of the instance
* `ssh_user`: SSH user for the instance
* `sonarw_public_key`: The public key (also known as the sonarw public SSH key) should be used when connecting an Agentless Gateway
* `sonarw_private_key`: The private key (also known as the sonarw private SSH key) should be used when connecting secondary hadr DSF Hub
* `sonarw_secret`: AWS secret details. Should be used when deploying a second DSF Hub for HADR

## Usage

To use this module, add the following to your Terraform configuration:

```
provider "aws" {
}

module "globals" {
  source = "imperva/dsf-globals/aws"
}

module "dsf_hub" {
  source                        = "imperva/dsf-hub/aws"
  subnet_id                     = "${aws_subnet.example.id}"

  ssh_key_pair = {
    ssh_private_key_file_path   = "${var.ssh_key_path}"
    ssh_public_key_name         = "${var.ssh_name}"
  }

  ingress_communication = {
    additional_web_console_access_cidr_list = ["${var.web_console_cidr}"] # ["0.0.0.0/0"]
    full_access_cidr_list                   = ["${module.globals.my_ip}/32"] # [terraform-runner-ip-address] to allow ssh
    use_public_ip                           = true
  }

  web_console_admin_password    = random_password.pass.result
  ebs                           = {
    disk_size        = 1000
    provisioned_iops = 0
    throughput       = 125
  }
  binaries_location             =  module.globals.tarball_location
}
```

To see a complete example of how to use this module in a DSF deployment with other modules, check out the [examples](../../../examples/) directory.

We recommend using a specific version of the module (and not the latest).
See available released versions in the main repo README [here](https://github.com/imperva/dsfkit#version-history).

Specify the module's version by adding the version parameter. For example:

```
module "dsf_hub" {
  source  = "imperva/dsf-hub/aws"
  version = "x.y.z"
}
```

## SSH Access
SSH access is required to provision this module. To SSH into the DSF Hub instance, you will need to provide the private key associated with the key pair specified in the key_name input variable. If direct SSH access to the DSF Hub instance is not possible, you can use a bastion host as a proxy.

## Additional Information

For more information about the DSF Hub and its features, refer to the official documentation [here](https://docs.imperva.com/bundle/v4.10-sonar-user-guide/page/81265.htm). 
For additional information about DSF deployment using terraform, refer to the main repo README [here](https://github.com/imperva/dsfkit/tree/1.3.7).