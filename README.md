![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![Pandas](https://img.shields.io/badge/pandas-%23150458.svg?style=for-the-badge&logo=pandas&logoColor=white)
![Postgres](https://img.shields.io/badge/postgres-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![Build Status](https://img.shields.io/github/actions/workflow/status/orioninsight/de-project/deploy.yml?style=for-the-badge)
![Code Size](https://img.shields.io/github/languages/code-size/orioninsight/de-project?style=for-the-badge)
![Contributors](https://img.shields.io/github/contributors/orioninsight/de-project?style=for-the-badge)
# ETL Project for Totesys

This project is an ETL (Extract, Transform, Load) pipeline designed for Totesys. The goal of the pipeline is to take data from a database and convert it into a format suitable for analysis in a data warehouse. The pipeline uses AWS Lambda and S3 to perform the ETL tasks.

## Architecture

The ETL pipeline consists of three Lambda functions, which are triggered in sequence:

Extract - This Lambda function retrieves the data from the Totesys database and puts it into an S3 bucket. It is triggered on a timer, which is set to run at regular intervals.

Transform - This Lambda function takes the data from the S3 bucket, transforms it into a star schema, and converts it to the Parquet format. It uses pandas to perform the transformation. This function is triggered by the completion of the Extract Lambda function.

Load - This Lambda function takes the Parquet files produced by the Transform function and loads them into a data warehouse. It is triggered by the completion of the Transform function.

The pipeline is designed to be fault-tolerant, with error handling built into each Lambda function.


![App Screenshot](https://github.com/orioninsight/de-project/blob/main/architecture_diagrams/png/architecture_diagram.png)

The pipeline was monitored via cloudwatch metrics and an SNS topic triggered on alarm.

## Testing

This project was developed using robust TDD, using a mixture of mocked and temporary AWS resources with pytest and moto3. Coverage was used to provide an insight into test coverage.

Flake8 was used to ensure pep8 compliance while bandit and safety employed to improve the security of our code.

## CI/CD

This project uses Continuous Integration and Continuous Deployment (CI/CD) through GitHub Actions to automate the build, test, and deployment process.

We employ infrastructure as code to enable agile deployment using terraform.

## Conclusion

This ETL pipeline provides a reliable way to extract data from the Totesys database, transform it into a format suitable for analysis, and load it into a data warehouse. The use of Lambda, S3, and Pandas makes the pipeline scalable and flexible, while the fault-tolerant design ensures that errors are handled gracefully. The CI/CD process using GitHub Actions makes it easy to maintain and deploy the pipeline with confidence.

## Get started

<!-- install following before running the file -->
## Install
```bash
    make requirements
    make dev-setup
    make lambda-deployment-packages
````

## Environmental variables / secret manager 


Add secrets with ID **OI_TOTESYS_DB_INFO** and **OI_TOTESYS_DW_INFO** to AWS Secrets Manager in the following format, **replacing values**:
```
    {"host":"HOST","port":"PORT","user":"USER","password":"PASSWORD","database":"DB"}
```

If only testing locally (not deploying via terraform), export variables **OI_TOTESYS_DB_INFO** and **OI_TOTESYS_DW_INFO** to provide database credentials in the following format to enable unit tests to run, **replacing values**:
```bash
    export OI_TOTESYS_DB_INFO='{"host":"HOST","port":"PORT","user":"USER","password":"PASSWORD","database":"DB"}'
    export OI_TOTESYS_DW_INFO='{"host":"HOST","port":"PORT","user":"USER","password":"PASSWORD","database":"DB"}'
```

Configure AWS credentials using AWS CLI

## Run all tests / checks
```bash
   make run-checks
```

## Terraform

1. Create sandbox if needed
2. Ensure AWS credentials are sufficient
3. cd into terraform folder

If backend bucket for terraform does not already exist follow these steps:

- give executable permissions to backend.sh

  ```bash
  chmod u+x backend.sh
  ```

- Run backend.sh and note created bucket from output.

  ```bash
  ./backend.sh
  ```

- In backend.tf change bucket to equal the name of your bucket created by backend.sh e.g.
  ```
  terraform {
  backend "s3" {
  bucket = "nc-terraform-state-1679486354"
  key    = "tote-application/terraform.tfstate"
  region = "us-east-1"
    }
  }
  ```

4. Lambda handler variables can be changed in vars.tf if there is a need during development

5. Run in terraform folder:

```bash
  terraform init
  terraform plan
  terraform apply
```

**Note** For any lambda source code changes to be reflected with terraform the following command should be run from the root directory of the project:

```bash
   make lambda-deployment-packages
```

This happens automatically as part of the github actions deployment and is only necessary when deploying via terraform on a local machine.

## Outcome 

Totesys DB 
![totesysdb][(https://github.com/orioninsight/de-project/blob/main/architecture_diagrams/png/architecture_diagram.png](https://github.com/orioninsight/de-project/blob/main/schema/DB.png)

Remodelled into the starschema and loaded into the data warehouse 
![datawarehouse][(https://github.com/orioninsight/de-project/blob/main/schema/Sales.png)

