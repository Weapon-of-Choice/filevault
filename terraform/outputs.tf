//ecr
output "vault_app_frontend_repo_arn"{
    value = aws_ecr_repository.vault_app_frontend_repo.arn
}

output "vault_app_backend_repo_arn" {
    value = aws_ecr_repository.vault_app_backend_repo.arn
}

//vpc
output "vpc_id" {
    value = module.vpc.vpc_id
} 

output "vpc_private_subnet_ids" {
  value = module.vpc.private_subnets
}