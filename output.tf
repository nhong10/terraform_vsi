# Print the floating ip address
output "floatingip" {
   value = ibm_is_floating_ip.testacc_floatingip.address
}