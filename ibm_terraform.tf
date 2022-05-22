# Create a VPC
resource "ibm_is_vpc" "testacc_vpc" {
    name = "vpc-sld"
}

# Create subnet
resource "ibm_is_subnet" "test_subnet" {
    name            = "testsubnet1"
    vpc             = ibm_is_vpc.testacc_vpc.id
    zone            = var.zone
    ipv4_cidr_block = var.IPv4_subnet
}

resource "ibm_is_security_group" "sld_security" {
  name = "example-security-group"
  vpc  = ibm_is_vpc.testacc_vpc.id
}


//security group rule to allow all for inbound
resource "ibm_is_security_group_rule" "sg" {
  group      = ibm_is_security_group.sld_security.id
  direction  = "inbound"
  remote     = "0.0.0.0/0"
  depends_on = [ibm_is_security_group.sld_security]
}

//security group rule to allow ssh
resource "ibm_is_security_group_rule" "sg22" {
  group     = ibm_is_security_group.sld_security.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.sg]
}

//security group rule to run bwb on browser
resource "ibm_is_security_group_rule" "sg_sld" {
  group     = ibm_is_security_group.sld_security.id
  count     = length(var.sg)
  direction = "inbound"
  remote    = var.sg[count.index].ipv4
  tcp {
    port_min = var.sg[count.index].port_min
    port_max = var.sg[count.index].port_max
  }
  depends_on = [ibm_is_security_group_rule.sg22]
}

//security group rule to allow all for outbound
resource "ibm_is_security_group_rule" "sg_outbound" {
  depends_on = [ibm_is_security_group_rule.sg_sld]
  group     = ibm_is_security_group.sld_security.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# Image for Virtual Server Insance
data "ibm_is_image" "image" {
   name = var.image
}

data "ibm_is_ssh_key" "ssh_key" {
    name    = var.ssh_key
}

# Create a virtual server instance
resource "ibm_is_instance" "tf_instance" {
    name    = var.instance_name
    image   = data.ibm_is_image.image.id
    profile = var.instance_profile

    primary_network_interface {
      subnet          = ibm_is_subnet.test_subnet.id
      security_groups = [ibm_is_security_group.sld_security.id]
    }

    vpc       = ibm_is_vpc.testacc_vpc.id
    zone      = var.zone
    keys      = [data.ibm_is_ssh_key.ssh_key.id]
    user_data = "${file(var.user_data)}"
}

# Reserve a floating ip
resource "ibm_is_floating_ip" "testacc_floatingip" {
    name   = "testfip"
    target = ibm_is_instance.tf_instance.primary_network_interface[0].id
}