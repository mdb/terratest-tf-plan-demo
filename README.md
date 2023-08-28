# terratest-demo

A demo illustrating how [terratest](https://terratest.gruntwork.io/) can be used to programmatically analyze
Terraform plan output and gate `apply` in a CI/CD pipeline accordingly.

## More detailed problem statement

Tools like [OPA](https://mikeball.info/blog/terraform-plan-validation-with-open-policy-agent/)
can automate Terraform plan analysis. But what if your teamprefers to write Go?

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

The GitHub Actions runs representing `main`'s [CI/CD pipeline](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774) show successful...

1. :white_check_mark: [terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774/job/16284431393)
1. :white_check_mark: [test-terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774/job/16284476716) gated by `terraform-plan`'s success.
1. :white_check_mark: [terraform-apply](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774/job/16284486218) gated by `test-terraform-plan`'s succcess, as well the requirement that the branch is `main`.

The GitHub Actions runs representing [PR TODO's CI/CD pipeline](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774) shows similarly successful...

1. :white_check_mark: [terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774/job/16284431393)
1. :white_check_mark: [test-terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774/job/16284476716) gated by `terraform-plan`'s success.
1. :raised_hand: [terraform-apply](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774/job/16284486218) gated by `test-terraform-plan`'s succcess, as well the requirement that the branch is `main`.

By contrast, PR TODO introduces a change that yields a destructive Terraform actions. A such, the GitHub Actions runs representing [PR TODO's CI/CD pipeline](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774) shows...

1. :white_check_mark: [terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774/job/16284431393)
1. :x: [test-terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774/job/16284476716) gated by `terraform-plan`'s success.
1. :raised_hand: [terraform-apply](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774/job/16284486218) gated by `test-terraform-plan`'s succcess, as well the requirement that the branch is `main`.

## Run the code locally

Alternatively, you can run the demo locally.

### Install dependencies

The demo assumes you've installed [tfenv](https://github.com/tfutils/tfenv) and [Go](https://go.dev/).

The demo also assumes [Docker](https://www.docker.com/) is installed and running.
