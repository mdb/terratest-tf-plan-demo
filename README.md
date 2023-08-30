# terratest-tf-plan-demo

A reference example illustrating how [terratest](https://terratest.gruntwork.io/)
can be used to programmatically analyze Terraform plan output in a CI/CD pipeline.

## Why?

Tools like [OPA](https://mikeball.info/blog/terraform-plan-validation-with-open-policy-agent/)
can automate Terraform plan analysis via policy-as-code. Such tools seek to replace -- or at least offset --
the toil associated with manual plan analysis. But what if you'd prefer to write Go?

Traditionally, [terratest](https://terratest.gruntwork.io/) is leveraged as a tool
for authoring Terraform end-to-end tests that make post-`terraform apply`
assertions on the correctness of the resulting infrastructure.

However, `terratest` can also be used to programmatically analyze Terraform
plan output, effectively offering a Go-based alternative to tools like OPA and
similar policy-as-code tools.

This may be especially compelling when the tests need to dynamic evaluate data
returned by cloud provider APIs, for example. In such instances, Go-based `terratest`
tests can leverage technologies such as the [AWS SDK for Go](https://docs.aws.amazon.com/sdk-for-go/),
or even one of `terratest`'s built-in modules, such as its [aws module](https://pkg.go.dev/github.com/gruntwork-io/terratest@v0.43.13/modules/aws).
`terratest`-based Terraform plan analysis may also be especially compelling when
`terratest` is already used as an end-to-end testing tool.

Example use cases:

* fail pull request CI if a Teraform change introduces a destructive action
  against a production-critical resource
* verify the correctness of the planned DNS record modifications during a Terraform-orchestrated
  DNS-based blue/green deployment
* ensure an ECR repository marked for destruction does not home OCI images used
  by active ECR task definitions

## GitHub Actions

`terratest-tf-plan-demo` offers an example of how `terratest` could be
integrated with a CI/CD pipeline. Its `test` directory homes a single `terratest`
test that fails if the Terraform plan it analyzes indicates any destructive
actions.

The `main` branch [CI/CD pipeline](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774) is composed of three passing jobs:

1. :white_check_mark: [terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774/job/16284431393) - plans the configuration.
1. :white_check_mark: [test-terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774/job/16284476716) - runs the `terratest` tests homed in `test/*_test.go` against the plan produced by the preceding job.
1. :white_check_mark: [terraform-apply](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774/job/16284486218) - gated by `test-terraform-plan`'s succcess, as well the configuration specifying this job only run on the `main` branch.

[PR 2](https://github.com/mdb/terratest-tf-plan-demo/pull/2) introduces a change that passes [GitHub Actions CI](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6006175711), as its resulting Terraform plan includes no destructive actions. Again, all three jobs pass:

1. :white_check_mark: [terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6006175711/job/16290249080?pr=2) - plans the configuration.
1. :white_check_mark: [test-terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6006175711/job/16290272192?pr=2) - runs the `terratest` tests homed in `test/*_test.go` against the plan produced by the preceding job.
1. :raised_hand: [terraform-apply](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6006175711/job/16290276703?pr=2) - gated by `test-terraform-plan`'s succcess, as well the configuration specifying this job only run on the `main` branch (the workflow is running against a non-`main` branch so this job doesn't run).

By contrast, [PR 1](https://github.com/mdb/terratest-tf-plan-demo/pull/1) introduces a change whose Terraform plan indicates a destructive action. A such, its [GitHub Actions CI](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6006174371) fails its `test-terraform-plan` job:

1. :white_check_mark: [terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6006174371/job/16290245262?pr=1) - plans the configuration successfully.
1. :x: [test-terraform-plan](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6006174371/job/16290271949?pr=1) - runs the `terratest` tests homed in `test/*_test.go` against the plan produced by the preceding job. The tests fail in this case, because the plan introduces a destructive action.
1. :raised_hand: [terraform-apply](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6006174371/job/16290277863?pr=1) - gated by `test-terraform-plan`'s succcess, as well the configuration specifying this job only run on the `main` branch.

## Run `terratest-tf-plan-demo` locally

`terratest-tf-plan-demo` assumes you've installed [tfenv](https://github.com/tfutils/tfenv) and [Go](https://go.dev/).

`terratest-tf-plan-demo` also assumes [Docker](https://www.docker.com/) is installed and running.

### Run `terratest-tf-plan-demo`

Clone `terratest-tf-plan-demo`:

```
git clone git@github.com:mdb/terratest-tf-plan-demo.git \
  && cd terratest-tf-plan-demo
```

Run `localstack` to simulate AWS APIs locally:

```
make up
```

Create a `localstack` `terratest-demo` S3 bucket and pre-populate the bucket
with a `s3://terratest-demo/terraform.tfstate` object used as the the Terraform
remote state for the demo's root module project.

```
make bootstrap
```

Run `terraform plan` and save the plan to `plan.out`:

```
make plan
```

Use `terraform show` to save the `plan.out` to `plan.json`:

```
make show
```

Run the `terratest` tests against the `plan.json` file. Note the tests pass:

```
make test
```

Introduce a change to the Terraform configuration by renaming `null.foo` to be
`null.foo_new_name`:

```
sed -i "" "s/foo/foo_new_name/g" main.tf
```

After the change, `main.tf` should look like this:

```hcl
resource "null_resource" "foo_new_name" {}
resource "null_resource" "bar" {}
resource "null_resource" "baz" {}
```

Run `terraform plan` and save the plan to `plan.out`:

```
make plan
```

Use `terraform show` to save the `plan.out` to `plan.json`:

```
make show
```

Run the `terratest` tests against the `plan.json` file. Note this time the tests
fail, as the plan indicates a destructive action:

```
make test
```

Undo the changes to `main.tf`:

```
git checkout .
```

Introduce another change to the Terraform configuration:

```
echo "resource \"null_resource\" \"foo_new\" {}" >> main.tf
```

Now, `main.tf` should look like:

```hcl
resource "null_resource" "foo" {}
resource "null_resource" "bar" {}
resource "null_resource" "baz" {}
resource "null_resource" "foo_new" {}
```

Run `terraform plan` and save the plan to `plan.out`:

```
make plan
```

Use `terraform show` to save the `plan.out` to `plan.json`:

```
make show
```

Run the `terratest` tests against the `plan.json` file. Note this time the tests
pass, as the plan no longer indicates a destructive action:

```
make test
```

Tear down `localstack` mock AWS environment:

```
make down
```
