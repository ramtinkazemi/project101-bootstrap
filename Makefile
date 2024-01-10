include .env.local
export

.PHONY: check-aws bootstrap

check-aws:
	@echo "Checking AWS credentials..."; \
	AWS_USER=$$(aws sts get-caller-identity --output text --query 'Arn'); \
	if [ -z "$$AWS_USER" ]; then \
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
	@./bin/bootstrap.sh bootstrap-rendered.yaml

