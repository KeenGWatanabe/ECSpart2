Step6to8
This Terraform configuration will:

1. Create an IAM role named `rger-ecs-xray-taskrole` with the `AWSXRayDaemonWriteAccess` policy attached
2. Create an IAM role named `rger-ecs-xray-taskexecutionrole` with three policies attached:
   - `AmazonSSMReadOnlyAccess` (for accessing Parameter Store)
   - `SecretsManagerReadWrite` (for accessing Secrets Manager)
   - `AmazonECSTaskExecutionRolePolicy` (standard ECS execution policy)
3. Create an ECS Fargate cluster named `rger-flask-xray-cluster` with container insights enabled

To use this configuration:

1. Save it to a file (e.g., `ecs-setup.tf`)
2. Run `terraform init` to initialize the provider
3. Run `terraform plan` to see what will be created
4. Run `terraform apply` to create the resources

The outputs will show you the ARNs of the created roles and the cluster name, which you can use when defining your ECS task definitions later.