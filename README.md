# de-project
<!-- install following before running the file -->
## Install
```bash
    make requirements
    make dev-setup
```

Add a secret with ID **totesys** to AWS Secrets Manager in the following format, **replacing values**:
```
    '{"host":"HOST","port":"PORT","user":"USER","password":"PASSWORD","database":"DB"}'
```

If only testing locally (not deploying via terraform), export variable **OI_TOTESYS_SECRET_STRING** to provide database credentials in the following format to enable unit tests to run, **replacing values**:
    
```bash
    export OI_TOTESYS_SECRET_STRING='{"host":"HOST","port":"PORT","user":"USER","password":"PASSWORD","database":"DB"}'
```


## Run all tests / checks

```bash
   make run-checks
```

## Terraform

1. Create sandbox if needed
   
2. AWS configure
   
3. cd into terraform folder

If backend bucket for terraform does not already exist follow these steps:
   
- cd into terraform folder and give executable permissions to backend.sh
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
4. extraction_lambda_handler should match the defined handler function e.g. extract_db.extract_db_handler

5.  Run in terraform folder:
 ```bash
   terraform init
   terraform plan
   terraform apply
   ```
