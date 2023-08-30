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

## A GitHub Actions-based demo

The `main` branch [CI/CD pipeline](https://github.com/mdb/terratest-tf-plan-demo/actions/runs/6004252774) is composed of three jobs, each of which succeeds:

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

### Clone `tfmigrate-demo`

```
git clone git@github.com:mdb/terratest-tf-plan-demo.git \
  && cd terratest-tf-plan-demo
```

### Bootstrap `localstack` environment

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
