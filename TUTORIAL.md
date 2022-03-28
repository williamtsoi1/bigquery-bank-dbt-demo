# Instructions

## Introduction

This repo shows an end-to-end example on how to use dbt to model a number of BigQuery datasets. A high level overview of the solution is provided on the <walkthrough-editor-open-file filePath="README.md">README.md</walkthrough-editor-open-file> file.

Follow the steps in this guide to deploy your own BigQuery data model using dbt!

Click the **Start** button to move to the next step.

## Install Terraform v1.1.7

From Cloud Shell, execute the following to install 1.1.7 of Terraform:

```bash
export TERRAFORM_VERSION="1.1.7"
curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    sudo unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip
```

Verify that this is installed correctly by executing:

```bash
terraform -v
```

## Install dbt

From Cloud Shell, execute the following to install dbt:

```bash
pip3 uninstall dbt-core
pip3 install --user --upgrade dbt-bigquery
```

Verify that this is installed correctly by executing:

```bash
dbt --version
```

## Set the `PROJECT_ROOT` environment variable

Execute the following to set an environment variable that will be used throughout the rest of these instructions

```bash
export PROJECT_ROOT=$(pwd)
```

## Create a `terraform.tfvars` file in the terraform directory

Open the <walkthrough-editor-open-file filePath="terraform/terraform.tfvars.renameMe">terraform.tfvars.renameMe</walkthrough-editor-open-file> file.

The file should be in this format, the fields to fill in are quite self-explanatory:

```
project_prefix = "bigquery-dbt-bank"
billing_account_id = ""
bigquery_location = "US"
```

When you have finished editing this file, save a copy of this file as `terraform.tfvars` within the terraform directory.

```bash
cp $PROJECT_ROOT/terraform/terraform.tfvars.renameMe $PROJECT_ROOT/terraform/terraform.tfvars
```

## Terraform

Create a new GCP project, enable the BigQuery API, and then create a dataset named `raw`

```bash
cd $PROJECT_ROOT/terraform
terraform init
terraform apply --auto-approve
```

Note that the project created will have a project id whose prefix is `project_prefix` as defined in `terraform.tfvars`, and a random suffix. The project id will be shown to you after you run `terraform apply`.

Take note of the project id that was created. You will need this in the next step.

```bash
cd $PROJECT_ROOT/terraform
terraform output project_id
```

## dbt (setup profile)

Create a new file in <walkthrough-editor-open-file filePath="~/.dbt/profiles.yml">~/.dbt/profiles.yml</walkthrough-editor-open-file> if it doesn't exist already. Add the following code block to configure this project's connection to BigQuery:

```yaml
bigquery_bank:
  outputs:
    dev:
      dataset: bigquery_bank
      fixed_retries: 1
      location: <bigquery_location>
      method: oauth
      priority: batch
      project: <project_id>
      threads: 8
      timeout_seconds: 300
      type: bigquery
  target: dev
```

Be sure to change the `project` and the `location` to correspond to the project id created by terraform (including the randomized suffix) and the location of the BigQuery dataset as configured in `terraform.tfvars`.

## dbt (install dependencies)

Install dbt dependencies, as indicated in the <walkthrough-editor-open-file filePath="dbt/packages.yml">dbt/packages.yml</walkthrough-editor-open-file> file.

```bash
cd $PROJECT_ROOT/dbt
dbt clean
dbt deps
```

## dbt (load external tables)

Execute the following:

```bash
cd $PROJECT_ROOT/dbt
dbt run-operation stage_external_sources
```

This takes the GCS files listed in <walkthrough-editor-open-file filePath="dbt/models/raw/external_tables.yml">dbt/models/raw/external_tables.yml</walkthrough-editor-open-file>, and creates corresponding external tables in BigQuery within the `raw` dataset.

For this tutorial, the data will come from a public Google Cloud Storage bucket `gs://williamtsoi-bigquery-bank-demo/`. In your use case you may use data that has been Extract-Loaded by your platform of choice.

## dbt - generate base staging schema

Execute the following:

```bash
cd $PROJECT_ROOT/dbt
dbt compile
```

This will execute the jinja macros from the `dbt/analyses` directory, such as <walkthrough-editor-open-file filePath="dbt/analyses/stg_card_transactions.sql">dbt/analyses/stg_card_transactions.sql</warkthrough-editor-open-file>:

```
{{ codegen.generate_base_model(
    source_name='raw',
    table_name='ext_card_transactions'
) }}
```

This macro will inspect the table schema of the `ext_card_transactions` external table in the `raw` dataset, and will generate a base SQL model for the staging schema.

The generated SQL models will be placed in the `dbt/target/compiled/bigquery_bank/analyses` directory. For example, the corresponding base schema generated for the `ext_card_transactions` table is:

```sql
with source as (

    select * from {{ source('raw', 'ext_card_transactions') }}

),

renamed as (

    select
        cc_number,
        trans_id,
        trans_time,
        epoch_time,
        category,
        merchant,
        merchant_lat,
        merchant_lon,
        amount,
        is_fraud,
        trans_date

    from source

)

select * from renamed
```

## dbt - define staging schema

Normally what happens here is that you will need to model the staging schema in the `dbt/models/staging` directory, based on the generated base schema files in `dbt/target/compiled/bigquery_bank/analyses` in the previous step.

This is the place where you will define partition/clustering for the tables. For example, in <walkthrough-editor-open-file filePath="dbt/models/staging/stg_card_transactions.sql">dbt/models/staging/stg_card_transactions.sql</walkthrough-editor-open-file>, we have added an additional config block on the top of the model file to define partitioning by the `trans_date` column:

```sql
{{ config(
    materialized='table',
    partition_by={
      "field": "trans_date",
      "data_type": "date",
      "granularity": "day"
    }
)}}

with source as (

    select * from {{ source('raw', 'ext_card_transactions') }}

),

renamed as (

    select
        cc_number,
        trans_id,
        trans_time,
        epoch_time,
        category,
        merchant,
        merchant_lat,
        merchant_lon,
        amount,
        is_fraud,
        trans_date

    from source

)

select * from renamed
```

For the purpose of this tutorial though, the staging schemas have already been defined and so there's no action required here.

## dbt - Deploy schema

Deploy the staging schema into BigQuery by executing:

```bash
cd $PROJECT_ROOT/dbt
dbt run
```

## dbt - Execute Data Tests

Execute the data tests in BigQuery by executing:

```bash
cd $PROJECT_ROOT/dbt
dbt test
```

Tests are defined in the `dbt/models/staging/stg_bigquery_bank.yml`, as well as `dbt/tests/*.sql`.

## dbt - Generate docs

dbt comes with some powerful documentation generation facilities. Once the data model has been deployed, you can generate a document website using the following command.

```bash
cd $PROJECT_ROOT/dbt
dbt docs generate
```

This will generate the data catalog json file.

## dbt - Serve documentation website

Now to serve the website, run the following commands:

```bash
cd $PROJECT_ROOT/dbt
dbt docs serve
```

Next, click on the <walkthrough-spotlight-pointer spotlightId="devshell-web-preview-button">web preview icon
</walkthrough-spotlight-pointer> at the top right of the window and click "Preview on port 8080".

When you are done browsing the documentation website, ensure that you press `Ctrl-C` to stop the web server and to bring you back to the shell.

## Terraform - destroy resources

Once you are done with this tutorial, run the following commands to destroy all the resources:

```bash
cd $PROJECT_ROOT/terraform
terraform destroy --auto-approve
```