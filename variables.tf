variable "api_key" {
  type = string
  description = "IBM api key (API_KEY)."
}

variable "region" {
  type = string
  default     = "us-south"
}

variable "zone" {
  type = string
  default     = "us-south-1"
}

variable "IPv4_subnet" {
  type = string
  default     = "10.240.0.0/24"
}

variable "sg" {
  type = list(object({
      port_max = number
      port_min = number
      ipv4 = string
  }))
  
  default = [
      {
          port_max = 6080,
          port_min = 6080,
          ipv4 = "0.0.0.0/0"
          }
      ]
}

variable "ssh_key" {
  type = string
  description = "IBM SSH key."
}

variable "image" {
  type = string
  description = "IBM image."
}

variable "instance_name" {
  type = string
  description = "IBM instance name."
}

variable "instance_profile" {
  type = string
  description = "IBM instance profile."
}

variable "user_data" {
  type = string  
  default = "user_data.sh"
}