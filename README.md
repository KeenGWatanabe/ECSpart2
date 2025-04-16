Follow steps 1 - 4 from this Doc sheet

# 3.5 Container Orchestration w ECS2
https://docs.google.com/document/d/1HkjQakCw2Db82e5dPbWzfqm_BnWK0xHMiWXixuojW4k/edit?tab=t.0

# step 5 - 8 
cd into /terraform folder
```
terraform init
terraform plan
terraform apply -target=module.ecs
```
# step 9 create Task Definition
https://docs.google.com/document/d/1HkjQakCw2Db82e5dPbWzfqm_BnWK0xHMiWXixuojW4k/edit?tab=t.0

# step 10 create ECS service
```
terraform init
terraform plan
terraform apply -target=module.vpc
```