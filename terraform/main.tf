# As resources get written, they go into these files, one per concern:
#
#   network.tf - VPC, public subnets, security group (TCP 25565)
#   efs.tf     - EFS file system + access point for the world data
#   ecs.tf     - ECS cluster, task definition (minecraft + watchdog), service (desired_count = 0)
#   dns.tf     - Route 53 A record, query logging -> CloudWatch Logs (us-east-1)
#   lambda.tf  - Launcher Lambda + log subscription filter that triggers it
#   iam.tf     - Roles/policies for the task, the watchdog, and the Lambda
