# terratest-tf-plan-demo

A demo illustrating how [terratest](https://terratest.gruntwork.io/) can be used to programmatically analyze
Terraform plan output and gate `apply` in a CI/CD pipeline accordingly.

## More detailed problem statement

Tools like [OPA](https://mikeball.info/blog/terraform-plan-validation-with-open-policy-agent/)
can automate Terraform plan analysis. But what if your team prefers to write Go?

Traditionally, [terratest](https://terratest.gruntwork.io/) is leveraged a Terraform
end-to-end test framework of sorts, enabling engineers to make post-`terraform apply`
assertions on infrastructure, verifying the functionality of underlying Terraform modules.

However, `terratest` can also be used to programmatically analyze Terraform
plans, effectively offering a Go-based alternative to OPA and similar
policy-as-code tools.

`terratest-tf-plan-demo` demos such `terratest`-based Terraform plan testing.

## Overview

* `docker-compose.yaml` creates a local
  [localstack](https://localstack.cloud/)-based mock AWS environment.
* `bootstrap` is a minimal Terraform project that creates a [localstack](https://localstack.cloud/)
  `terratest-demo` S3 bucket, and seeds the bucket with a
  `s3://terratest-demo/terraform.tfstate` Terraform state.
* The repo's root directory homes a Terraform project using
  `s3://terratest-demo/terraform.tfstate` as its remote state backend. The
  project manages 3 resources:
    * `resource.null_resource.foo`
    * `resource.null_resource.bar`
    * `resource.null_resource.baz`
* `test` homes a simple `terratest` test that fails if a Terraform plan
  indicates any destructive actions against any of the resources managed by the
  root directory Terraform project.
* The `Makefile` homes convenience utilities for creating and interacting with the demo
  resources.

## See the demo in GitHub Actions

The [CI/CD pipeline](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774) running against the `main` branch is composed of three jobs, each of which succeeds:

1. :white_check_mark: [terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774/job/16284431393)
1. :white_check_mark: [test-terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774/job/16284476716) gated by `terraform-plan`'s success.
1. :white_check_mark: [terraform-apply](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774/job/16284486218) gated by `test-terraform-plan`'s succcess, as well the configuration specifying this job only run on the `main` branch.

[PR 2](https://github.com/mdb/terratest-tf-plan-demo/pull/2) introduces a change that passes [GitHub Actions CI](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6006175711), as its resulting Terraform plan includes no destructive actions...

1. :white_check_mark: [terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6006175711/job/16290249080?pr=2)
1. :white_check_mark: [test-terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6006175711/job/16290272192?pr=2) gated by `terraform-plan`'s success.
1. :raised_hand: [terraform-apply](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6006175711/job/16290276703?pr=2) gated by `test-terraform-plan`'s succcess,  as well the configuration specifying this job only run on the `main` branch.

By contrast, [PR 1](https://github.com/mdb/terratest-tf-plan-demo/pull/1) introduces a change whose Terraform plan indicates a destructive action. A such, its [GitHub Actions CI](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6006174371) fails...

1. :white_check_mark: [terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6006174371/job/16290245262?pr=1)
1. :x: [test-terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6006174371/job/16290271949?pr=1) gated by `terraform-plan`'s success.
1. :raised_hand: [terraform-apply](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6006174371/job/16290277863?pr=1) gated by `test-terraform-plan`'s succcess, as well the configuration specifying this job only run on the `main` branch.

## Run the code locally

Alternatively, you can run the demo locally.

### Install dependencies

The demo assumes you've installed [tfenv](https://github.com/tfutils/tfenv) and [Go](https://go.dev/).

The demo also assumes [Docker](https://www.docker.com/) is installed and running.
