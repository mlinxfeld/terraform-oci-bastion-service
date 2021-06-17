resource "oci_bastion_bastion" "FoggyKitchenBastionService" {
  bastion_type                 = "STANDARD"
  compartment_id               = oci_identity_compartment.FoggyKitchenCompartment.id
  target_subnet_id             = oci_core_subnet.FoggyKitchenBastionSubnet.id
  client_cidr_block_allow_list = ["0.0.0.0/0"]
  name                         = "FoggyKitchenBastionService"
  max_session_ttl_in_seconds   = 1800
}

resource "oci_bastion_session" "FoggyKitchenSSHViaBastionService" {
  depends_on = [oci_core_instance.FoggyKitchenWebserver]
  count      = var.NumberOfNodes
  bastion_id = oci_bastion_bastion.FoggyKitchenBastionService.id

  key_details {
    public_key_content = tls_private_key.public_private_key_pair.public_key_openssh
  }
  target_resource_details {
    session_type       = "MANAGED_SSH"
    target_resource_id = oci_core_instance.FoggyKitchenWebserver[count.index].id

    #Optional
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = 22
    target_resource_private_ip_address         = oci_core_instance.FoggyKitchenWebserver[count.index].private_ip
  }

  display_name           = "FoggyKitchenSSHViaBastionService"
  key_type               = "PUB"
  session_ttl_in_seconds = 1800
}
