module "instance"{
    source = "./modules/compute/virtualMachines"
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.instance.instance_public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.instance.instance_id
}