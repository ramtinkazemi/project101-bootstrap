#!/bin/bash
# set -e -o pipefail

function print_usage(){
    echo -e "USAGE: ${0##*/} <template-file>"
}

case $# in
    1)
      template=$1
      ;;
    *)
      echo "ERROR: Inavlid number of arguments."
      print_usage
      exit 1
      ;;      
esac


# Check if AWS CLI is installed
if ! [ -x "$(command -v aws)" ]; then
  echo 'Error: AWS CLI is not installed.' >&2
  exit 1
fi

# Function to deploy or update CloudFormation stack
deploy_stack() {
    aws cloudformation deploy \
        --template-file $template \
        --stack-name ${CFN_STACK_NAME} \
        --region ${AWS_REGION} \
        --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
        --no-fail-on-empty-changeset
}

# Check if the stack exists
echo "Checking if the stack exists..."
STACK_EXISTS=$(aws cloudformation describe-stacks \
    --stack-name ${CFN_STACK_NAME} \
    --region ${AWS_REGION} \
    --query 'Stacks[0].StackId' \
    --output text \
    2>/dev/null)

if [ -z "${STACK_EXISTS}" ]; then
    echo "Stack does not exist. Creating a new stack..."
    deploy_stack
else
    echo "Stack exists. Updating the stack..."
    deploy_stack
fi

# Check if the stack deployment was successful
if [ $? -eq 0 ]; then
    echo "Stack deployment successful."
    echo "Retrieving output..."
    # Retrieve and display stack outputs
    aws cloudformation describe-stacks \
        --stack-name ${CFN_STACK_NAME} \
        --region ${AWS_REGION} \
        --query 'Stacks[0].Outputs' \
        --output table
else
    echo "Stack deployment failed."
    aws cloudformation describe-stack-events --stack-name bootstrap --region ${AWS_REGION} --query 'StackEvents[0].ResourceStatusReason' --output text
    exit 1
fi
