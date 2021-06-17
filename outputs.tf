output "FoggyKitchenWebserver_PrivateIP" {
  value = [data.oci_core_vnic.FoggyKitchenWebserver_VNIC1.*.private_ip_address]
}
output "bastion_ssh_metadata" {
  value = oci_bastion_session.FoggyKitchenSSHViaBastionService.*.ssh_metadata
}
