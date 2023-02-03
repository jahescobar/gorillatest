module "ec2" {
    source = "./modules/ec2"
    rootvolsize = "10"
    #ec2servers = 
    #instancetype =
    #rootvolrootvoltype =
    #addpubaddpubip =
    vpcid = module.network.vpc
    subnetc = module.network.subnetc
    subnetd = module.network.subnetd
    environment = var.environment 
}


module "loadbalancer" {
    source = "./modules/loadbalancer"
    dnsname = "herran.us"
    hostname = "insidelb"
    vpcid = module.network.vpc
    subneta = module.network.subneta
    subnetb = module.network.subnetb 
    environment = var.environment
    serversid = module.ec2.serversid
    ec2servers = module.ec2.servers
}

module "network" {
    source = "./modules/network"
    #cidr_vpc =
    #cidr_subnet1 = 
    #cidr_subnet2 =
    #cidr_subnet3 = 
    #cidr_subnet4 =
    ec2sgid = module.ec2.ec2sgid
    environment = var.environment
}