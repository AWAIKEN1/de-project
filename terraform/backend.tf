terraform {
    backend "s3" {
        bucket = "nc-terraform-state-1679483529"
        key = "tote-application/terraform.tfstate"
        region = "us-east-1"
    }
}