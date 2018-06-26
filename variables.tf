variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}

variable "tenant_id" {}

variable "config" {
  type = "map"

  default {
    # Resource Group settings
    "resource_group" = "TEST-RSG-JIC-001"
    "location"       = "East US"

    # Network Security Group settings
    "security_group_name" = "TEST-NSG-JIC-001"

    # Network settings
    "vnet_name"            = "TEST-VNT-JIC-001"
    "vnet_address_range"   = "10.0.0.0/24"
    "subnet_name"          = "TEST-SNT-JIC-001"
    "subnet_address_range" = "10.0.0.0/28"

    /*
    "network_public_ipaddress_type" = "static"

    # Storage Account settings
    "storage_account_name" = "teststgactjen001"
    "container_name"       = "vhds"
    "share_name"           = "hashare"

    # Load Balancer settings
    "lb_pip_name"    = "jenkins-lb-pip"
    "lb_ip_dns_name" = ""

    # Availablity Set settings
    "avail_set_name" = "jenkins_avail_set"
    */

    # Virtual Machine settings
    "vm_name" = "TESTJICVM001"
    #"jenkins_master_secondary_vmname"     = "TESTJENMSTVM002"
    "vm_size"            = "Standard_DS1_v2"
    "vm_image_publisher" = "OpenLogic"
    "vm_image_offer"     = "CentOS"
    "vm_image_sku"       = "7.3"
    "vm_image_version"   = "latest"
    /*
            "availability_set_name"               = "jenkinsAvailabilitySet"
            "jenkins_master_primary_ip_address"   = "10.199.10.18"
            "jenkins_master_secondary_ip_address" = "10.199.10.19"
            "jenkins_master_primrary_nic"         = "jenkins_master_primary_nic"
            "jenkins_master_secondary_nic"        = "jenkins_master_secondary_nic"
            "os_name"                             = "centosJenkins01"
            */
    "vm_username" = "os_admin"
    "vm_password" = "P@ssword12345"
  }
}
