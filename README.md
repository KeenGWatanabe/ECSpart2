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

# step 10 create ECS service (see explanation below)
Spin up VPC first;
```
terraform init
terraform plan
terraform apply -target=module.vpc
```

These steps in the AWS Console (ECS cluster > Services > Create) are for creating an Amazon ECS (Elastic Container Service) **Service** that will run and maintain a specified number of instances (tasks) of your containerized application. Here's a breakdown of what each configuration does:

### **1. Application Type: Service**
   - You're creating an **ECS Service**, which ensures that a specified number of tasks (containers) are always running, even if they fail.

### **2. Family: Choose your task definition name**
   - This refers to the **Task Definition** (a blueprint for your containerized application) that you've previously created. It defines which Docker image to use, CPU/memory limits, environment variables, etc.

### **3. Service name: `rger-flask-service`**
   - A unique name for your ECS service.

### **4. Service Type: Replica**
   - **Replica**: Maintains a fixed number of identical tasks (containers) running.
   - (Alternative: **DAEMON**, which runs one task per EC2 instance in the cluster.)

### **5. Desired Tasks: 1**
   - The number of container instances (tasks) you want running at all times. ECS will ensure this count is maintained.

### **6. Networking**
   - **VPC**: Choose a VPC with **public subnets** (so tasks can pull Docker images and communicate externally).
   - **Subnets**: Select **public subnets** (for internet access).
   - **Security Group**: A new one is created with:
     - **Inbound Rule**: Allows TCP traffic on **port 8080** from CIDR `10.0.0.1/16` (adjust if needed).
   - **Public IP: Turned ON** (Important)
     - Since tasks are in a public subnet, they need a public IP to pull Docker images from the internet (e.g., Docker Hub or ECR).

### **7. Create (Leave all else as default)**
   - Default settings for load balancing, auto-scaling, and deployment configurations are used unless modified.

### **Purpose of These Steps**
- **Deploy a Flask application** as a long-running service in AWS ECS.
- Ensure **high availability** by maintaining at least 1 running task (container).
- Allow **external access** via port `8080` (adjust CIDR if needed for security).
- Use **public subnets** so the task can pull Docker images and be accessible from the internet (if needed).

### **Next Steps After Creation**
- The service will launch a task (container) in the ECS cluster.
- If you need external access, consider adding a **Load Balancer** (ALB/NLB) later.
- Monitor the service in **ECS > Services > `rger-flask-service`**.

Would you like help with any specific part (e.g., Task Definition, Load Balancer setup)?

.
