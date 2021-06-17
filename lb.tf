resource "oci_load_balancer" "FoggyKitchenFlexPublicLoadBalancer" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id

  display_name               = "FoggyKitchenFlexPublicLB"
  network_security_group_ids = [oci_core_network_security_group.FoggyKitchenWebSecurityGroup.id]

  subnet_ids = [
    oci_core_subnet.FoggyKitchenLBSubnet.id
  ]

  shape = "flexible"
  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 100
  }
}

resource "oci_load_balancer_backendset" "FoggyKitchenFlexPublicLoadBalancerBackendset" {
  name             = "FoggyKitchenFlexLBBackendset"
  load_balancer_id = oci_load_balancer.FoggyKitchenFlexPublicLoadBalancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}


resource "oci_load_balancer_listener" "FoggyKitchenFlexPublicLoadBalancerListener" {
  load_balancer_id         = oci_load_balancer.FoggyKitchenFlexPublicLoadBalancer.id
  name                     = "FoggyKitchenFlexLBListener"
  default_backend_set_name = oci_load_balancer_backendset.FoggyKitchenFlexPublicLoadBalancerBackendset.name
  port                     = 80
  protocol                 = "HTTP"
}


resource "oci_load_balancer_backend" "FoggyKitchenFlexPublicLoadBalancerBackend" {
  count            = var.NumberOfNodes
  load_balancer_id = oci_load_balancer.FoggyKitchenFlexPublicLoadBalancer.id
  backendset_name  = oci_load_balancer_backendset.FoggyKitchenFlexPublicLoadBalancerBackendset.name
  ip_address       = oci_core_instance.FoggyKitchenWebserver[count.index].private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}



output "FoggyKitchenFlexPublicLoadBalancer_Public_IP" {
  value = [oci_load_balancer.FoggyKitchenFlexPublicLoadBalancer.ip_addresses]
}

