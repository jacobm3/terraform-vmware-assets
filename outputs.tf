output "default_ip_address" {
  value = module.vm.default_ip_address
}

output "site_url" {
  value = "http://${module.vm.default_ip_address}"
}
