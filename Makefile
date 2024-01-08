.PHONY: check-aws bootstrap

# Export TG_CONFIG_PATH so it's available to the shell commands
export TG_CONFIG_PATH

all: check-aws init validate plan apply destroy

check-aws:
	@echo "Checking AWS credentials..."
	@AWS_IDENTITY=$$(aws sts get-caller-identity --output text --query 'Account'); \
	AWS_USER=$$(aws sts get-caller-identity --output text --query 'Arn'); \
	if [ -z "$$AWS_IDENTITY" ]; then \
		echo "Failed to retrieve AWS identity."; \
		exit 1; \
	else \
		echo "AWS User: $$AWS_USER"; \
	fi

bootstrap: check-aws
	@echo "Bootstrapping AWS Account for Terraform..."
	@echo "\033[1;31mProceed? [y|N] \033[0m" | tr -d '\n'; \
	read PROCEED; \
	case "$$PROCEED" in \
		[Yy]* ) ;; \
		* ) echo "Exiting..."; exit 1;; \
	esac
	@./bin/render.sh bootstrap.yaml bootstrap.vars > bootstrap-rendered.yaml
	@./bin/bootstrap.sh

