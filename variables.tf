variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "friendly_name" {
  type        = string
  description = "Friendly name to identify all resources"
  default     = "imperva-dsf-hub"
  validation {
    condition     = length(var.friendly_name) >= 3
    error_message = "Must be at least 3 characters long"
  }
  validation {
    condition     = can(regex("^\\p{L}.*", var.friendly_name))
    error_message = "Must start with a letter"
  }
}

variable "subnet_id" {
  type        = string
  description = "Subnet id for the DSF hub instance"
  validation {
    condition     = length(var.subnet_id) >= 15 && substr(var.subnet_id, 0, 7) == "subnet-"
    error_message = "Subnet id is invalid. Must be subnet-********"
  }
}

variable "instance_profile_name" {
  type        = string
  default     = null
  description = "Instance profile to assign to the instance. Keep empty if you wish to create a new IAM role and profile"
}

variable "security_group_ids" {
  type        = list(string)
  description = "AWS security group Ids to attach to the instance. If provided, no security groups are created and all allowed_*_cidrs variables are ignored."
  validation {
    condition     = alltrue([for item in var.security_group_ids : substr(item, 0, 3) == "sg-"])
    error_message = "One or more of the security group Ids list is invalid. Each item should be in the format of 'sg-xx..xxx'"
  }
  default = []
}

variable "allowed_agentless_gw_cidrs" {
  type        = list(string)
  description = "List of ingress CIDR patterns allowing DSF Agentless Gateways to access the DSF hub instance"
  validation {
    condition     = alltrue([for item in var.allowed_agentless_gw_cidrs : can(cidrnetmask(item))])
    error_message = "Each item of this list must be in a valid CIDR block format. For example: [\"10.106.108.0/25\"]"
  }
  default = []
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "List of ingress CIDR patterns allowing ssh access"
  validation {
    condition     = alltrue([for item in var.allowed_ssh_cidrs : can(cidrnetmask(item))])
    error_message = "Each item of this list must be in a valid CIDR block format. For example: [\"10.106.108.0/25\"]"
  }
  default = []
}

variable "allowed_web_console_and_api_cidrs" {
  type        = list(string)
  description = "List of ingress CIDR patterns allowing web console access"
  validation {
    condition     = alltrue([for item in var.allowed_web_console_and_api_cidrs : can(cidrnetmask(item))])
    error_message = "Each item of this list must be in a valid CIDR block format. For example: [\"10.106.108.0/25\"]"
  }
  default = []
}

variable "allowed_hub_cidrs" {
  type        = list(string)
  description = "List of ingress CIDR patterns allowing other hubs access (hadr & health)"
  validation {
    condition     = alltrue([for item in var.allowed_hub_cidrs : can(cidrnetmask(item))])
    error_message = "Each item of this list must be in a valid CIDR block format. For example: [\"10.106.108.0/25\"]"
  }
  default = []
}

variable "allowed_dra_admin_cidrs" {
  type        = list(string)
  description = "List of ingress CIDR patterns allowing access to DRA admin instances"
  validation {
    condition     = alltrue([for item in var.allowed_dra_admin_cidrs : can(cidrnetmask(item))])
    error_message = "Each item of this list must be in a valid CIDR block format. For example: [\"10.106.108.0/25\"]"
  }
  default = []
}

variable "allowed_all_cidrs" {
  type        = list(string)
  description = "List of ingress CIDR patterns allowing access to all relevant protocols (E.g vpc cidr range)"
  validation {
    condition     = alltrue([for item in var.allowed_all_cidrs : can(cidrnetmask(item))])
    error_message = "Each item of this list must be in a valid CIDR block format. For example: [\"10.106.108.0/25\"]"
  }
  default = []
}

variable "instance_type" { # https://docs.imperva.com/bundle/z-kb-articles-km/page/a6defd0e.html
  type        = string
  default     = "r6i.2xlarge" # 8 cores & 64GB ram
  description = "EC2 instance type for the DSF hub"
}

variable "ebs" {
  type = object({
    disk_size        = number
    provisioned_iops = number
    throughput       = number
  })
  description = "Compute instance volume attributes"
}

variable "ingress_communication_via_proxy" {
  type = object({
    proxy_address              = string
    proxy_private_ssh_key_path = string
    proxy_ssh_user             = string
  })
  description = "Proxy address used for ssh for private hub, Proxy ssh key file path and Proxy ssh user. Keep empty if no proxy is in use"
  default     = null
}

variable "attach_persistent_public_ip" {
  type        = bool
  default     = false
  description = "Create public elastic IP for the instance"
}

variable "use_public_ip" {
  type        = bool
  default     = false
  description = "Whether to use the DSF instance's public or private IP to check the instance's health"
}

variable "binaries_location" {
  type = object({
    s3_bucket = string
    s3_region = string
    s3_key    = string
  })
  description = "S3 DSF installation location. If tarball_url not set, binaries_location is used. For example, { s3_bucket = 'my-bucket', s3_region = 'us-west-2', s3_key = 'installation-files/my-file'}. This means that the path to the installation file is s3://my-bucket/installation-files/my-file"
  default = {
    s3_bucket = ""
    s3_region = ""
    s3_key    = ""
  }
}

variable "tarball_url" {
  type        = string
  default     = ""
  description = "HTTPS DSF installation location. If not set, binaries_location is used"
}

variable "hadr_dr_node" {
  type        = bool
  default     = false
  description = "Is this node an HADR DR one"
}

variable "main_node_sonarw_public_key" {
  type        = string
  description = "Public key of the sonarw user taken from the main Hub output. This variable must only be defined for the DR Hub."
  default     = null
}

variable "main_node_sonarw_private_key" {
  type        = string
  description = "Private key of the sonarw user taken from the main Hub output. This variable must only be defined for the DR Hub."
  default     = null
}

variable "password" {
  type        = string
  sensitive   = true
  description = "Initial password for all users"
  validation {
    condition     = var.password == null || try(length(var.password) >= 7, false)
    error_message = "Must be at least 7 characters. Used only if 'password_secret_name' is not set."
  }
}

variable "password_secret_name" {
  type        = string
  default     = null
  description = "Secret name in AWS secrets manager which holds the password. If not set, 'password' is used."
}

variable "ssh_key_pair" {
  type = object({
    ssh_public_key_name       = string
    ssh_private_key_file_path = string
  })
  description = "SSH materials to access machine"

  nullable = false
}

variable "ami" {
  type = object({
    id               = string
    name             = string
    username         = string
    owner_account_id = string
  })
  description = <<EOF
This variable is used for selecting an AWS machine image based on various filters. It is an object type variable that includes the following fields: id, name, username, and owner_account_id.
If set to null, the recommended image will be used.
The "id" and "name" fields are used to filter the machine image by ID or name, respectively. To select all available images for a given filter, set the relevant field to "*". The "username" field is mandatory and used to specify the AMI username.
The "owner_account_id" field is used to filter images based on the account ID of the owner. If this field is set to null, the current account ID will be used. The latest image that matches the specified filter will be chosen.
EOF
  default     = null

  validation {
    condition     = var.ami == null || try(var.ami.id != null || var.ami.name != null, false)
    error_message = "ami id or name mustn't be null"
  }

  validation {
    condition     = var.ami == null || try(var.ami.username != null, false)
    error_message = "ami username mustn't be null"
  }
}

variable "additional_install_parameters" {
  default     = ""
  description = "Additional params for installation tarball. More info in https://docs.imperva.com/bundle/v4.10-sonar-installation-and-setup-guide/page/80035.htm"
}

variable "skip_instance_health_verification" {
  default     = false
  description = "This variable allows the user to skip the verification step that checks the health of the EC2 instance after it is launched. Set this variable to true to skip the verification, or false to perform the verification. By default, the verification is performed. Skipping is not recommended."
}

variable "terraform_script_path_folder" {
  type        = string
  description = "Terraform script path folder to create terraform temporary script files on the DSF hub instance. Use '.' to represent the instance home directory"
  default     = null
  validation {
    condition     = var.terraform_script_path_folder != ""
    error_message = "Terraform script path folder cannot be an empty string"
  }
}

variable "sonarw_private_key_secret_name" {
  type        = string
  default     = null
  description = "Secret name in AWS secrets manager which holds the DSF Hub sonarw user SSH private key - used for remote Agentless Gateway federation, HADR, etc."
}

variable "sonarw_public_key_content" {
  type        = string
  default     = null
  description = "The DSF Hub sonarw user SSH public key - used for remote Agentless Gateway federation, HADR, etc."
}

variable "generate_access_tokens" {
  type        = bool
  default     = false
  description = "Automatically generate access tokens for connecting to USC / connect DAM to the DSF Hub"
}

variable "mx_details" {
  description = "List of the DSF MX to onboard to USC"
  type = list(object({
    name     = string
    address  = string
    username = string
    password = string
  }))
  validation {
    condition = alltrue([
      for mx in var.mx_details : try(mx.name != null && mx.address != null, false)
    ])
    error_message = "Each MX must specify name and address"
  }
  validation {
    condition = alltrue([
      for mx in var.mx_details : try(mx.username != null && mx.password != null, false)
    ])
    error_message = "Each MX must specify username and password"
  }
  default = []
}

variable "dra_details" {
  description = "List of the DSF DRA to onboard to Sonar Hub"
  type = object({
    name              = string
    address           = string
    password          = string
    archiver_username = string
    archiver_password = string
  })
  validation {
    condition     = (var.dra_details == null || (can(var.dra_details.name) && can(var.dra_details.address)))
    error_message = "Each DRA Admin must specify name and address"
  }
  validation {
    condition     = (var.dra_details == null || (can(var.dra_details.archiver_username) && can(var.dra_details.archiver_password) && can(var.dra_details.password)))
    error_message = "Each DRA Admin must specify archiver_username, archiver_password and password"
  }
  default = null
}

variable "cm_details" {
  sensitive   = true
  description = "DSF CipherTrust Manager to onboard with the Sonar Hub. Supported in Sonar Hub version 4.18 and above. If null, no CipherTrust Manager will be onboarded."
  type = object({
    name                    = string
    is_load_balancer        = bool
    hostname                = string
    port                    = string
    ddc_enabled             = string
    ddc_connection_hostname = string
    ddc_connection_port     = string
    registration_method     = string
    username                = string
    password                = string
    registration_token      = string
  })
  validation {
    condition     = (var.cm_details == null || (can(var.cm_details.name) && can(var.cm_details.hostname)))
    error_message = "CipherTrust Manager must specify name and hostname"
  }
  validation {
    condition     = (var.cm_details == null || try(var.cm_details.registration_method == "password" || var.cm_details.registration_method == "token", false))
    error_message = "CipherTrust Manager registration_method must be either 'password' or 'token'"
  }
  validation {
    condition     = (var.cm_details == null || try(var.cm_details.registration_method != "password" || (var.cm_details.registration_method == "password" && can(var.cm_details.username) && can(var.cm_details.password)), false))
    error_message = "CipherTrust Manager must specify username and password for 'password' registration method"
  }
  validation {
    condition     = (var.cm_details == null || try(var.cm_details.registration_method != "token" || (var.cm_details.registration_method == "token" && can(var.cm_details.registration_token)), false))
    error_message = "CipherTrust Manager must specify registration_token for 'token' registration method"
  }
  default = null
}

variable "volume_attachment_device_name" {
  type        = string
  default     = null
  description = "The device name to expose to the instance for the ebs volume. Keep null if you have no preference"
}

variable "base_directory" {
  type        = string
  default     = "/imperva"
  description = "The base directory where all Sonar related directories will be installed"
}

variable "cloud_init_timeout" {
  type        = number
  default     = 900
  description = "Max time to wait for the machine to start"
}

variable "send_usage_statistics" {
  type        = bool
  default     = true
  description = "Set to true to send usage statistics."
}
