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
	@echo "\033[1;31mProceed? [y|N] \033[0m" | tr -d '\n'; \
	read PROCEED; \
	case "$$PROCEED" in \
		[Yy]* ) ;; \
		* ) echo "Exiting..."; exit 1;; \
	esac
	@./bin/render.sh bootstrap-acc.yaml bootstrap-acc.vars > bootstrap-acc-rendered.yaml
	@CFN_STACK_NAME=bootstrap-account ./bin/deploy-cfn-stack.sh bootstrap-acc-rendered.yaml

bootstrap-app: check-aws
	@echo "Bootstrapping App for Terraform and Github OIDC..."
	@echo STACK=$(STACK)
	@echo APP=$(APP)
	@echo ENV=$(ENV)
	@echo GITHUB_APP_REPO=$(GITHUB_APP_REPO)
	@echo "\033[1;31mProceed? [y|N] \033[0m" | tr -d '\n'; \
	read PROCEED; \
	case "$$PROCEED" in \
		[Yy]* ) ;; \
		* ) echo "Exiting..."; exit 1;; \
	esac
	@./bin/render.sh bootstrap-app.yaml bootstrap-app.vars > bootstrap-app-rendered.yaml
	@CFN_STACK_NAME=bootstrap-$(STACK)-$(APP)-${ENV} ./bin/deploy-cfn-stack.sh bootstrap-app-rendered.yaml
