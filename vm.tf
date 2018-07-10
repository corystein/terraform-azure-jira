resource "azurerm_public_ip" "vm-pip" {
  name                         = "vm-pip"
  location                     = "${azurerm_resource_group.res_group.location}"
  resource_group_name          = "${azurerm_resource_group.res_group.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "crs-vm1-jira"
}

resource "azurerm_network_interface" "vm-nic" {
  name                = "vm-nic"
  resource_group_name = "${azurerm_resource_group.res_group.name}"
  location            = "${azurerm_resource_group.res_group.location}"

  ip_configuration {
    name = "ipconfig1"

    #private_ip_address_allocation = "static"
    private_ip_address_allocation = "dynamic"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    public_ip_address_id          = "${azurerm_public_ip.vm-pip.id}"

    #load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.jenkins_lb_backend.id}"]

    #load_balancer_inbound_nat_rules_ids     = ["${azurerm_lb_rule.lb_rule.id}"]

    #private_ip_address            = "${var.config["jenkins_master_primary_ip_address"]}"
  }
}

resource "azurerm_virtual_machine" "vm-1" {
  name                = "vm-1"
  resource_group_name = "${azurerm_resource_group.res_group.name}"
  location            = "${azurerm_resource_group.res_group.location}"

  #availability_set_id   = "${azurerm_availability_set.avset.id}"
  network_interface_ids = ["${azurerm_network_interface.vm-nic.id}"]
  vm_size               = "${var.config["vm_size"]}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${var.config["vm_image_publisher"]}"
    offer     = "${var.config["vm_image_offer"]}"
    sku       = "${var.config["vm_image_sku"]}"
    version   = "${var.config["vm_image_version"]}"
  }

  storage_os_disk {
    name              = "${var.config["vm_name"]}-os-disk"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
    disk_size_gb      = "128"
  }

  storage_data_disk {
    name              = "${var.config["vm_name"]}-data-disk"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "512"
  }

  os_profile {
    computer_name  = "${var.config["vm_name"]}"
    admin_username = "${var.config["vm_username"]}"
    admin_password = "${var.config["vm_password"]}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "null_resource" "remote-exec-vm-1" {
  provisioner "file" {
    connection {
      type     = "ssh"
      host     = "${azurerm_public_ip.vm-pip.ip_address}"
      user     = "${var.config["vm_username"]}"
      password = "${var.config["vm_password"]}"
    }

    source      = "./scripts/"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = "${azurerm_public_ip.vm-pip.ip_address}"
      user     = "${var.config["vm_username"]}"
      password = "${var.config["vm_password"]}"
    }

    inline = [
      "echo \"${var.config["vm_password"]}\" | sudo -S -k chmod -R +x /tmp/*.sh",
      "echo \"${var.config["vm_password"]}\" | sudo -S -k sh -c /tmp/installJira.sh",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = "${azurerm_public_ip.vm-pip.ip_address}"
      user     = "${var.config["vm_username"]}"
      password = "${var.config["vm_password"]}"
    }

    inline = [
      "echo \"${var.config["vm_password"]}\" | sudo -S -k bash /tmp/configJiraDb.sh -s \"${azurerm_sql_server.sql_srv.fully_qualified_domain_name}\" -u \"${azurerm_sql_server.sql_srv.administrator_login}\" -p \"${azurerm_sql_server.sql_srv.administrator_login_password}\"",
    ]
  }

  depends_on = ["azurerm_virtual_machine.vm-1", "azurerm_sql_server.sql_srv", "azurerm_sql_database.sql_db"]
}
