# Infracost

- [Introduction](#introduction)
- [Objectives](#objectives)
- [Implementation](#implementation)
    - [Step 1 - Installing Infracost](#step-1-installing-infracost)
    - [Step 2 - Register for Infracost API Key](#step-2-register-for-infracost-api-key)
    - [Step 3 - Running Infracost CLI](#step-3-running-infracost-cli)
    - [Step 4 - CI/CD Integrations](#step-4-cicd-integrations)


<br><br>

## Introduction
Infracost is an open source software (and has SaaS offerings) aims to show the cloud cost estimate with breakdowns and diffs to understand the costs before launching or making changes to the Infrastructure as Code configuration either in the terminal or pull requests from the VCS provider.

Terraform is the only supported IaC tool at the moment of this writing while the rest of the tools are still part of their product roadmap.


<br><br>
## Objectives
These are the top goals of using Infracost.

* Cost visibility and awareness before resources are launched.
* Aligned budgets and costs.
* For the Consultants, it provides cost-benefit analysis to their customers.

<br>
<br>

## Implementation

<br>

### Step 1: Installing Infracost

| **Platform**         | Commands                                                                                                                                                                                                                                        |
|----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| macOS (Brew)         | ```brew install infracost```                                                                                                                                                                                                               |
| macOS/Linux (Manual) | ```curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh \| sh```                                                                                                                                     |
| Docker               | ```docker pull infracost/infracost:ci-latest  docker run --rm \ -e INFRACOST_API_KEY=see_following_step_on_how_to_get_this \ -v $PWD/:/path/to/terraform/code/ infracost/infracost:ci-latest breakdown --path /path/to/terraform/code/ ``` |
| Windows (Chocolatey) | ```choco install infracost ```                                                                                                                                                                                                             |
| Windows (Manual)     | Download and unzip the latest release at https://github.com/infracost/infracost/releases/latest/download/infracost-windows-amd64.zip.                                                                                                           |


<br><br>
### Step 2: Register for Infracost API Key

Registration is **free** for getting the Infracost API key. To do that, issue the command below and it will navigate you to the infracost website registration page.

```bash
infracost auth login
```

Retrieve your Infracost API key with the command below.

```bash
infracost configure get api_key
```

Set your retrieved Infracost API key to your local computer.

```xml
infracost configure set api_key <your-infracost-api-key-here>
```

<br><br>
### Step 3: Running Infracost CLI
<br>

The following are examples of the basic commands for the Infracost CLI.<br>

<br>

#### ➡️ Showing an estimated cost <u>breakdown</u>

<br>
The example below will show an estimated cost breakdown for all the resources in the Terraform code.

```bash
cd /path/to/terraform-code-project

infracost breakdown --path .
```

Example output:

![Infracost CLI Output](images/infracost-cli1.png)


<br><br>

#### ➡️ Showing an estimated cost <u>diff</u>erence

<br>
The example below will show an estimated cost difference of before and after making changes to the resources (aws instance type) in the Terraform code.

* Generate a JSON file as the baseline.
    ```bash
    cd /path/to/terraform-code-project

    infracost breakdown --path . --format json --out-file infracost-base.json
    ```
* Try to change any resources in the Terraform code like AWS instance type.
* Generate a differences by comparing the latest code change from the previous one.
    ```bash
    infracost diff --path . --compare-to infracost-base.json
    ```

Example output:

![Infracost CLI Output](images/infracost-cli2.png)


<br><br>
### Step 4: CI/CD Integrations
Infracost can be integrated to multiple CI/CD platforms. This tool is recommended to add in every pull requests.
<br><br>The example below is for GitHub Actions. The other platforms (like GitLab, Jenkins, etc) guide can be found in [here](https://www.infracost.io/docs/integrations/cicd/).

<br>

#### ➡️ Using GitHub Actions
<br>

Please visit the [Infracost GitHub Actions](https://github.com/infracost/actions) guide to explore other options and details.
<br>

* [Create a Github repository secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository) with the following details.
  * Name   = `INFRACOST_API_KEY`
  * Secret = `<Your Infracost API key>` 
  
  <br>

  ![Github Secrets](images/github.secrets.png)


* Create a file `.github/workflows/infracost.yml` with the contents below.
  ```yaml
  name: Infracost
  on: [pull_request]

  jobs:
    terraform-project:
      name: Terraform project
      runs-on: ubuntu-latest
      permissions:
        contents: read
        pull-requests: write

      env:
        # The location of the Terraform code
        TF_ROOT: ./

      steps:
        - name: Setup Infracost
          uses: infracost/actions/setup@v2
          with:
            api-key: ${{ secrets.INFRACOST_API_KEY }}

        # Checkout the base branch of the pull request (e.g. main/master).
        - name: Checkout base branch
          uses: actions/checkout@v3
          with:
            ref: '${{ github.event.pull_request.base.ref }}'

        # Generate Infracost JSON file as the baseline.
        - name: Generate Infracost cost estimate baseline
          run: |
            infracost breakdown --path=${TF_ROOT} \
                                --format=json \
                                --out-file=/tmp/infracost-base.json

        # Checkout the current PR branch so we can create a diff.
        - name: Checkout PR branch
          uses: actions/checkout@v3

        # Generate an Infracost diff and save it to a JSON file.
        - name: Generate Infracost diff
          run: |
            infracost diff --path=${TF_ROOT} \
                            --format=json \
                            --compare-to=/tmp/infracost-base.json \
                            --out-file=/tmp/infracost.json

        # Posts a comment to the PR using the 'update' behavior.
        # See https://www.infracost.io/docs/features/cli_commands/#comment-on-pull-requests for other options.
        - name: Post Infracost comment
          run: |
              infracost comment github --path=/tmp/infracost.json \
                                      --repo=$GITHUB_REPOSITORY \
                                      --github-token=${{github.token}} \
                                      --pull-request=${{github.event.pull_request.number}} \
                                      --behavior=update

  ```
* Now, you can try to create a pull request to your GitHub repository and the workflow will be running automatically. 
  <br>A comment will be posted to the PR comment thread displaying an estimated cost outcome.
  <br><br>Below is an example of the Infracost output.

  ![Github Comment](images/github.comment.png)

  <br>
  <details><summary>
   ➡️ Click here for another example combination of the core Terraform workflow.
  </summary>

  ```yml
  name: terraform-infracost
  on: [pull_request]

  jobs:
    infracost:
      runs-on: ubuntu-latest
      env:
        working-directory: ./
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
            terraform_wrapper: false # This is recommended so the `terraform show` command outputs valid JSON

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
            infracost breakdown --path plan.json --format json --out-file /tmp/infracost.json
          working-directory: ${{ env.working-directory }}
          
        - name: Post Infracost comment
          uses: infracost/actions/comment@v1
          with:
            path: /tmp/infracost.json
            # Choose the commenting behavior, 'update' is a good default:
            behavior: update # Create a single comment and update it. The "quietest" 
  ```
  </summary>

<br><br>

## Other Useful Information and Commands

* The Infracost monthly pricing is automatically detected in the Terraform code based on the defined region (i.e. AWS Sydney region).

* The default currency is USD. You can change the format using the [Infracost CLI and environment variables](https://www.infracost.io/docs/features/environment_variables/#infracost_currency).
  ```bash
  infracost configure set currency AUD
  ```
  ```bash
  export INFRACOST_CURRENCY=AUD
  ```