# Infracost

- [Introduction](#introduction)
- [Objectives](#objectives)
- [Implementation](#implementation)
    - [Step 1- Installing Infracost](#step-1-installing-infracost)


<br><br>

## Introduction
<hr>
Infracost aims to show the cloud cost estimation with breakdowns to understand the costs before launching or making changes to the Infrastructure as Code (Terraform at the moment) configuration either in the terminal or pull requests from VCS.<br>

Behind the Scene of Infracost
<screenshot here>

<br><br>
## Objectives
<hr>
These are the top 3 purpose of using Infracost tool.

* Cost visibility and awareness.
* Aligned budgets and costs.
* Consultants: cost-benefit analysis.

<br>
<br>

## Implementation
<hr>

<br>

### Step 1: Installing Infracost

| **Platform**         | Commands                                                                                                                                                                                                                                                                                                       |   |   |   |
|----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---|---|---|
| macOS (Brew)         | `brew install infracost`                                                                                                                                                                                                                                                                                       |   |   |   |
| macOS/Linux (Manual) | `curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh \| sh`                                                                                                                                                                                                             |   |   |   |
| Docker               | `docker pull infracost/infracost:ci-latest` <br><br> `docker run --rm \` <br> `-e INFRACOST_API_KEY=<api-key-here> \` <br> `-v $PWD/:/path/to/tf/code/ infracost/infracost:ci-latest breakdown --path /path/to/tf/code/` |   |   |   |
| Windows (Chocolatey) | `choco install infracost`                                                                                                                                                                                                                                                                                      |   |   |   |
| Windows (Manual)     | Download and unzip the latest release at https://github.com/infracost/infracost/releases/latest/download/infracost-windows-amd64.zip.                                                                                                                                                                          |   |   |   |





<br><br>
### Step 2: Getting API Key

* Registration is free to get the Infracost API key. To do that, issue the command below and it will navigate you to the registration page.

    ```bash
    infracost auth login
    ```
* Retrieve the API key with the command below.
    ```bash
    infracost configure get api_key
    ```


<br><br>
### Step 3: Running Infracost CLI
<br>

<details><summary>➡️ Showing an estimated cost <u>breakdown</u>.</summary>
<p>

The example below will be showing a breakdown of the cost for all the resources in the Terraform code.

```bash
cd /path/to/terraform-code-project

infracost breakdown --path .
```

Example output:
<p align="center"><img align="center" src="images/infracost-cli1.png"></p>

</p>
</details>

<br>
<details><summary>➡️ Showing an estimated cost <u>diff</u>erence.</summary>
<p>

The example below will be showing an estimated cost difference of before and after making changes on the resources in the Terraform code.

* Generate a JSON file as the baseline.
    ```bash
    cd /path/to/terraform-code-project
    infracost breakdown --path . --format json --out-file before.json
    ```
* Try to change any resources in Terraform code like AWS instance type.
* Generate a diff by comparing the latest code change with the previous one.
    ```bash
    infracost diff --path . --compare-to before.json
    ```

Example output:
<p align="center"><img align="center" src="images/infracost-cli2.png"></p>

</p>
</details>



<br><br>
### Step 4: Automate Cloud Cost - CI/CD Integrations


<br><br>
#### Using GitHub Action



<br><br>
#### Using GitLab CI

<br><br>
### Step 4: Command Line Basic Commands





 
## 3-Steps to Use INFRACOST in CI/CD Pipeline
* The example below is when you're using GitHub Action.
* For using other VCS provider, please refer to https://www.infracost.io/docs/integrations/.

### Step 1: Add to `~/.github/workflows/infracost.yml`
```yaml
on: [pull_request]

jobs:
  infracost:
    runs-on: ubuntu-latest
    env:
      working-directory: "./" # Update this!
      INFRACOST_API_KEY: ${{ secrets.INFRACOST_API_KEY }}
      AWS_ACCESS_KEY_ID:  ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY:  ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      AWS_SESSION_TOKEN:  ${{ secrets.AWS_SESSION_TOKEN }}

    name: Run Infracost
    steps:
      - name: Check out repository
        uses: actions/checkout@v2
        
      - name: Install terraform
        uses: hashicorp/setup-terraform@v1
        with:
          terraform_wrapper: false  # This is recommended so the `terraform show` command outputs valid JSON

      - name: Terraform init
        run: terraform init
        working-directory: ${{ env.working-directory }}


      - name: Terraform plan
        run: terraform plan -out tfplan.binary
        working-directory: ${{ env.working-directory }}

      - name: Terraform show
        run: terraform show -json tfplan.binary > plan.json
        working-directory: ${{ env.working-directory }}

      - name: Setup Infracost
        uses: infracost/actions/setup@v1
        with:
          api-key: ${{ secrets.INFRACOST_API_KEY }}

      - name: Set AUD Currency and Generate Infracost JSON
        run: |
          infracost configure set currency AUD
          infracost breakdown --path plan.json --project-name terraform-code-standards/infracost --format json --out-file /tmp/infracost.json
        working-directory: ${{ env.working-directory }}
        
      - name: Post Infracost comment
        uses: infracost/actions/comment@v1
        with:
          path: /tmp/infracost.json
          # Choose the commenting behavior, 'update' is a good default:
          behavior: update # Create a single comment and update it. The "quietest" option.                 
          # behavior: delete-and-new # Delete previous comments and create a new one.
          # behavior: hide-and-new # Minimize previous comments and create a new one.
          # behavior: new # Create a new cost estimate comment on every push.
```

### Step 2

### Step 3






## 3-Steps to Use INFRACOST in Command Line (CLI)

### Step 1 - Install Infracost & API Key

**1.1 Install Infracost**

Please refer to https://www.infracost.io/docs/#1-install-infracost.

**1.2 Get free API Key**

Please refer to https://www.infracost.io/docs/#2-get-api-key

### Step 2

### Step 3