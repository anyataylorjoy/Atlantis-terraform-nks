# VPC > User scenario > Scenario 1. Single Public Subnet
# https://docs.ncloud.com/ko/networking/vpc/vpc_userscenario1.html

provider "ncloud" {
  support_vpc = true
  region      = "KR"
  access_key  = "69D334F510417DAFF728"
  secret_key  = "F1D01F28F1DBCB449198497F1DCEF0C3C0A05204"
}

resource "ncloud_vpc" "vpc" {
  name            = "vpc-flagship"
  ipv4_cidr_block = "10.0.0.0/16"
}

resource "ncloud_subnet" "web_subnet" {
  vpc_no         = "23133"
  subnet         = "10.0.1.0/24"
  zone           = "KR-2"
  network_acl_no = "35053"
  subnet_type    = "PRIVATE"
  name           = "flagship-private1"
  usage_type     = "GEN"
}

resource "ncloud_subnet" "lb_subnet" {
  vpc_no         = "23133"
  subnet         = "10.0.80.0/24"
  zone           = "KR-2"
  network_acl_no = "35053"
  subnet_type    = "PRIVATE"
  name           = "lagship-private-loadb-wooki"
  usage_type     = "LOADB"
}


data "ncloud_nks_versions" "version" {
  filter {
    name = "value"
    values = [var.nks_version]
    regex = true
  }
}
resource "ncloud_login_key" "loginkey" {
  key_name = "vpc-flagship"
}

resource "ncloud_nks_cluster" "cluster" {
  cluster_type                = "SVR.VNKS.STAND.C004.M016.NET.SSD.B050.G002"
  k8s_version                 = "1.23.9-nks.1"
  login_key_name              = "vpc-flagship"
  name                        = "datalake-wooki"
  lb_private_subnet_no        = "65418"
  kube_network_plugin         = "cilium"
  subnet_no_list              = [ "48730" ]
  vpc_no                      = "23133"
  zone                        = "KR-2"
  log {
    audit = true
  }
}
resource "ncloud_nks_node_pool" "node_pool" {
  cluster_uuid = ncloud_nks_cluster.cluster.uuid
  node_pool_name = "datalake-wk"
  node_count     = 2
  product_code   = "SVR.VSVR.STAND.C016.M064.NET.SSD.B050.G002"
  subnet_no      = "48730"
  autoscale {
    enabled = true
    min = 1
    max = 2
  }
}
