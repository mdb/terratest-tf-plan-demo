terraform {
  required_version = "1.5.5"

  backend "s3" {
    bucket                      = "terratest-demo"
    key                         = "terraform.tfstate"
    region                      = "us-east-1"
    endpoint                    = "http://localhost.localstack.cloud:4566"
    sts_endpoint                = "http://localhost:4566"
    force_path_style            = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    access_key                  = "fake"
    secret_key                  = "fake"
  }
}
