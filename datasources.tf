# Get the latest Oracle Linux image
data "oci_core_images" "InstanceImageOCID" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.Shape


  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

data "oci_core_vnic_attachments" "FoggyKitchenWebserver_VNIC1_attach" {
  count               = var.NumberOfNodes
  availability_domain = var.availablity_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  instance_id         = oci_core_instance.FoggyKitchenWebserver[count.index].id
}

data "oci_core_vnic" "FoggyKitchenWebserver_VNIC1" {
  count   = var.NumberOfNodes
  vnic_id = data.oci_core_vnic_attachments.FoggyKitchenWebserver_VNIC1_attach[count.index].vnic_attachments.0.vnic_id
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "template_file" "key_script" {
  template = file("./scripts/sshkey.tpl")
  vars = {
    ssh_public_key = tls_private_key.public_private_key_pair.public_key_openssh
  }
}

data "template_cloudinit_config" "cloud_init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.key_script.rendered
  }
}
