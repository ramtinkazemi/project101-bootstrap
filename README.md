# Terraform Baseline Infrastructure on AWS

This project sets up a foundational infrastructure for Terraform state management in AWS. It includes a CloudFormation template (`bootstrap.yaml`) for resource creation for automating the deployment process.

## Components

- **bootstrap.yaml**: A CloudFormation template to create an S3 bucket for Terraform's remote state, a DynamoDB table for state locking, and three OIDC IAM roles for integrarting AWS and Github. 

- **bootstrap.vars**: Parameters used to render bootstrap.yaml

## Prerequisites

- AWS CLI: Ensure that the AWS Command Line Interface is installed and configured with the necessary permissions.
- AWS Account: You need an AWS account with permissions to create IAM roles, S3 buckets, and DynamoDB tables.
- AWS Region: The scripts and templates are configured for the `ap-southeast-2` (Sydney) region.
- (Optional) Vagrant: (v>=2.0)
- (Optional) Virtualbox: (v>=5.0)
## Usage

### Deploying terraform CloudFromation Stack

This CloudFormation template is designed to establish essential infrastructure components for managing Terraform states and integrating with GitHub Actions in AWS. Key elements include:

- GitHub OIDC Provider: Sets up an IAM OIDC provider for GitHub Actions.
- S3 Bucket & DynamoDB Table: Creates resources for storing Terraform states and handling state locking.
- IAM Roles: Establishes roles for GitHub Actions in different contexts (Blueprints, Infra, App) with appropriate policies and permissions.
- Lambda Function & Role: Deploys a Lambda function with an execution role to perform initial bootstrap tasks.
- SSM Parameters: Stores important ARNs and resource names as SSM parameters for easy retrieval.
- Outputs: Provides ARNs for created IAM roles and names of S3 bucket and DynamoDB table.

1. Visit **.env** and make necessary adjustments.
2. Visit **.bootstrap.var** and make necessary adjustments.
3. Make sure your terminal session has AWS credentials set. Use STS termprary credentials provide by AWS SSO for this purpose if can. You may use the following command to check your AWS identity:
   ```bash
   make aws-check
   ```
3. (Optional) Spin up and ssh into the vagrant box:
   ```bash
    vagrant up
    vagrant ssh
   ```
4. Execute the script:
   ```bash
   make bootstrap
   ```

# Troubleshooting
In cases where the Cloudformation stack (bootstrap) fails, use the follwoing command to get insights.
   ```bash
    aws cloudformation describe-stack-events --stack-name bootstrap --region ap-southeast-2 --query 'StackEvents[0].ResourceStatusReason' --output text
   ```

In this case, the stack needs to be deleted manually before trying again.
