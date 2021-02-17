# Fairwinds Assessment
Automated deployment of barebones Django container.
## Requirements

- Ansible 2.7
- Terraform 0.13
- AWS key-pair

## Configuration
The following Terraform variables can be set in `user-info.auto.tfvars` or passed in as overrides via `-var`

- `key_pair_name` : Name of the AWS key-pair for admin ssh connection to the host
- `key_pair_path` : Local path to the AWS key-pair private key
- `admin_whitelist` : Whitelisted cidr blocks for admin ssh access 
  - default `["0.0.0.0/0]`)

## Deployment
The deployment is managed via Terraform and configured by Ansible. Simply run `terraform apply` and validate the deployment configuration before proceding. If you would like to pass in configuration variables on the command line, you can do so using the `-var` flag

Example:
```sh
terraform apply -var="key_pair_name=user-key" -var="key_pair_path=~/.ssh/user-key" -var
```

## Updating the Container
The `dockerfile` to build a new django container is under `app/`, which builds the django application in `app/mysite`. This image should be tagged as `viggynash/viggy-fw-assessment` (currently hardcoded) and pushed to Docker Hub.

# Design Reasoning

## Terraform
Terraform is a solid tool for idempotent infrastructure deployment and management, especially in a straightforwards case such as this. While Terraform has (or perhaps had, I haven't had time to explore the changes in 0.13) limitations when it comes to complex logic and the occasional bug, its still a powerful and straighforwards tool.

## Ansible
While Terraform *can* perform the required configuration management tasks to deploy a docker container, its a poor option, and should be relegated to infrastructure management only. Ansible is much better at declaratively configuring deployed hosts. Terraform can easily orchestrate Ansible with a `local-exec` provisioner set to run only once the host infrastructure is completed.