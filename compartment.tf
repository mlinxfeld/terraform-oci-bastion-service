resource "oci_identity_compartment" "FoggyKitchenCompartment" {
  name = "FoggyKitchenCompartment"
  description = "FoggyKitchen Compartment"
  compartment_id = var.compartment_ocid
}

