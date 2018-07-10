resource "azurerm_sql_server" "sql_srv" {
  name                         = "${var.config["sql_srv_name"]}"
  resource_group_name          = "${azurerm_resource_group.res_group.name}"
  location                     = "${azurerm_resource_group.res_group.location}"
  version                      = "12.0"
  administrator_login          = "${var.config["sql_admin"]}"
  administrator_login_password = "${var.config["sql_admin_pwd"]}"
}

resource "azurerm_sql_database" "sql_db" {
  name                = "${var.config["db_name"]}"
  resource_group_name = "${azurerm_resource_group.res_group.name}"
  location            = "${azurerm_resource_group.res_group.location}"
  server_name         = "${azurerm_sql_server.sql_srv.name}"
  edition             = "Standard"
  collation           = "Latin1_General_CI_AI"

  tags {
    environment = "dev"
  }
}

/*
resource "azurerm_sql_firewall_rule" "sql_fw" {
  name                = "sql_fw1"
  resource_group_name = "${azurerm_resource_group.res_group.name}"
  server_name         = "${azurerm_sql_server.sql_srv.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
*/

