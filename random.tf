resource "random_string" "name_suffix" {
  length  = 16
  special = false
  upper   = false
}
