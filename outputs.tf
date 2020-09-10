
output DB_HOSTNAME {
  value = azurerm_sql_server.default.fully_qualified_domain_name
}
output DB_NAME {
  value = azurerm_sql_database.default.name
}
output DB_USER {
  value = var.DB_USERNAME
}
output DB_PASSWORD {
  value = random_password.db_password.result
}