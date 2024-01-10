include .env.local
export

.PHONY: check-aws bootstrap

check-aws:
	@echo "Checking AWS credentials..."
	@echo AWS_REGION=$(AWS_REGION)
	@AWS_USER=$$(aws sts get-caller-identity --region $$AWS_REGION --output text --query 'Arn'); \
	if [ -z "$$AWS_USER" ]; then \
		echo "Failed to retrieve AWS identity."; \
		exit 1; \
	else \
		echo "AWS User: $$AWS_USER"; \
	fi

bootstrap-acc: check-aws
	@echo "Bootstrapping AWS Account for Terraform and Github OIDC..."
	@echo GITHUB_BOOTSTRAP_REPO=$(GITHUB_BOOTSTRAP_REPO)
	@echo GITHUB_BLUEPRINTS_REPO=$(GITHUB_BLUEPRINTS_REPO)
	@echo GITHUB_INFRA_REPO=$(GITHUB_INFRA_REPO)
	@./bin/render.sh bootstrap-acc.yaml bootstrap-acc.vars > bootstrap-acc-rendered.yaml
	@CFN_STACK_NAME=bootstrap-account ./bin/deploy-cfn-stack.sh bootstrap-acc-rendered.yaml

bootstrap-app: check-aws
	@while read -r line; do \
		APP=$${line%@*}; \
		REPO=$${line#*@}; \
		echo "Bootstrapping app: $$APP@$$REPO"; \
		{ echo "app=$$APP"; echo "repo=$$REPO"; } > temp.vars; \
		./bin/render.sh bootstrap-app.yaml temp.vars > bootstrap-app-rendered.yaml; \
		CFN_STACK_NAME=bootstrap-$$APP ./bin/deploy-cfn-stack.sh bootstrap-app-rendered.yaml; \
	done < config/apps

bootstrap-com: check-aws
	@while read COMPONENT; do \
		echo "Bootstrapping component: $$COMPONENT" ;\
		echo component="$$COMPONENT" > temp.vars ;\
		./bin/render.sh bootstrap-com.yaml temp.vars > bootstrap-com-rendered.yaml; \
		CFN_STACK_NAME=bootstrap-$$COMPONENT ./bin/deploy-cfn-stack.sh bootstrap-com-rendered.yaml; \
	done < config/components


bootstrap-all: bootstrap-acc bootstrap-app bootstrap-com