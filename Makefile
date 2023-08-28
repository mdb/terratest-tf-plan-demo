PLAN_FILE=plan.out

tfenv:
	TFENV_ARCH=amd64 tfenv install v$(shell cat .terraform-version)
.PHONY: tfenv

up: tfenv
	docker-compose up \
		--detach \
		--build

down:
	docker-compose down \
		--remove-orphans
.PHONY: down

bootstrap: clean
	# create terratest-demo S3 TF state bucket in localstack
	cd bootstrap \
		&& terraform init \
		&& terraform plan \
		&& terraform apply \
			-auto-approve
.PHONY: bootstrap

init:
	terraform init
.PHONY: init

plan: init
	terraform plan \
		-out=$(PLAN_FILE)
.PHONY: plan

apply: init
	terraform apply \
		-auto-approve \
		"$(PLAN_FILE)"
.PHONY: apply

show:
	terraform show \
		-json "$(PLAN_FILE)" > plan.json
.PHONY: apply

test:
	cd test \
		&& go test -v
.PHONY: test

state:
	curl http://s3.localhost.localstack.cloud:4566/terratest-demo/terraform.tfstate
.PHONY: state

clean:
	rm -rf bootstrap/.terraform || true
	rm bootstrap/terraform.tfstate* || true
	rm -rf .terraform || true
