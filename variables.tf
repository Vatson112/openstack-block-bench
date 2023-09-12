variable "network_id" {
    description = "The network to be used."
    default  = ""
    type = string
}

variable "instance_name" {
    description = "The Instance Name to be used."
    default  = "perf-test"
    type = string
}

variable "image_id" {
    description = "The image ID to be used."
    default  = ""
    type = string
}

variable "flavor_id" {
    description = "The flavor id to be used."
    default  = ""
    type = string
}

variable "instance_num" {
    description = "The Number of instances to be created."
    default  = 1
    type = number
}

variable "volume_size" {
    description = "The size of volume used to instantiate the instance"
    default = 1
    type = number
}

variable "security_groups" {
    description = "List of security group"
    type = list
    default = ["default"]
}

variable "root_pass" {
  description = "Root password for VMs"
  sensitive = true
  type = string
  default = "root"
}

variable "test_type" {
  type = string
  validation {
    condition     = contains(["aging", "wsat", "rw", "steady"], var.test_type)
    error_message = "Must be on of [aging, wsat, rw, steady]"
  }
}

variable "custom_repos_type" {
  type = string
  default = "yum"
  validation {
    condition = var.custom_repos_type == "yum"
    error_message = "Only yum supported"
  }

}
variable "custom_repos" {
  type = list(object({
    name = string
    url = string
    enabled = bool
    gpgcheck = bool
  }))
}

variable "fio_output_format" {
  type = string
  default = "json"
  validation {
    condition     = contains(["normal", "terse", "json", "json+"], var.fio_output_format)
    error_message = "Must be on of [normal, terse, json, json+]"
  }
}

variable "results_dir" {
  type = string
  default = "results"
}