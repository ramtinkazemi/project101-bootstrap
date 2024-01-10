# Terraform Baseline Infrastructure on AWS

This project sets up a foundational infrastructure for Terraform state management in AWS. It includes a CloudFormation template (`bootstrap.yaml`) for resource creation for automating the deployment process.

## Components

- **bootstrap-acc.yaml**: A CloudFormation template to OIDC IAM roles for integrarting AWS and Github for bootstrap, blueprints and infra repos.

- **bootstrap-acc.vars**: Parameters used to render bootstrap-acc.yaml

- **bootstrap-app.yaml**: A CloudFormation template to create an S3 bucket for Terraform's remote state, a DynamoDB table for state locking, and three OIDC IAM role for integrarting AWS and Github fro app repo. 

- **bootstrap-app.vars**: Parameters used to render bootstrap-app.yaml


## Prerequisites

- AWS CLI: Ensure that the AWS Command Line Interface is installed and configured with the necessary permissions.
- AWS Account: You need an AWS account with permissions to create IAM roles, S3 buckets, and DynamoDB tables.
- AWS Region: The scripts and templates are configured for the `ap-southeast-2` (Sydney) region.
- (Optional) Vagrant: (v>=2.0)
- (Optional) Virtualbox: (v>=5.0)
## Usage

## Bootstrapping

CloudFormation templates are designed to establish essential infrastructure components for managing Terraform states and integrating with GitHub Actions in AWS. Key elements include:

- GitHub OIDC Provider: Sets up an IAM OIDC provider for GitHub Actions.
- IAM Roles: Establishes roles for GitHub Actions in different contexts (Blueprints, Infra, App) with appropriate policies and permissions.
- Lambda Function & Role: Deploys a Lambda function with an execution role to perform initial bootstrap tasks.
- SSM Parameters: Stores important ARNs and resource names as SSM parameters for easy retrieval.
- S3 Bucket & DynamoDB Table: Creates resources for storing Terraform states and handling state locking.
- Outputs: Provides ARNs for created IAM roles and names of S3 bucket and DynamoDB table.

### Bootstrapping AWS Account

1. Make sure your terminal session has AWS credentials set. Use STS termprary credentials provide by AWS SSO for this purpose if can. You may use the following command to check your AWS identity:
   ```bash
   make aws-check
   ```
2. Visit **.env.local** and make necessary adjustments.
3. Visit **.bootstrap-acc.var** and make necessary adjustments.
4. (Optional) Spin up and ssh into the vagrant box:
   ```bash
    vagrant up
    vagrant ssh
   ```
5. Execute the script:
   ```bash
   make bootstrap-acc
   ```
### Bootstrapping Applications
This can be done either via the provided Github Workflow or manullay as follows:

1. Make sure your terminal session has AWS credentials set. Use STS termprary credentials provide by AWS SSO for this purpose if can. You may use the following command to check your AWS identity:
   ```bash
   make aws-check
   ```
2. Add the app to **config/apps**.
3. (Optional) Spin up and ssh into the vagrant box:
   ```bash
    vagrant up
    vagrant ssh
   ```
4. Execute the script:
   ```bash
   make bootstrap-app
   ```

### Bootstrapping Components (Terraform Blueprint Instances)
This can be done either via the provided Github Workflow or manullay as follows:

1. Make sure your terminal session has AWS credentials set. Use STS termprary credentials provide by AWS SSO for this purpose if can. You may use the following command to check your AWS identity:
   ```bash
   make aws-check
   ```
2. Add the component to **config/components**.
3. (Optional) Spin up and ssh into the vagrant box:
   ```bash
    vagrant up
    vagrant ssh
   ```
4. Execute the script:
   ```bash
   make bootstrap-com
   ```

# Troubleshooting
In cases where the Cloudformation stack (bootstrap) fails, use the follwoing command to get insights.
   ```bash
    aws cloudformation describe-stack-events --stack-name $cfn_stack_name --region ap-southeast-2 --query 'StackEvents[0].ResourceStatusReason' --output text
   ```
where **cfn_stack_name** is **bootstrap-account** or **bootdstrap-<stack>-<app|com><env>** for account and app respectively.

In this case, the stack needs to be deleted manually before trying again.
