# Infracost

- [Introduction](#introduction)
- [Objectives](#objectives)
- [Implementation](#implementation)
    - [Step 1- Installing Infracost](#step-1-installing-infracost)


<br><br>

## Introduction
Infracost is an open source (has SaaS product) aims to show the cloud cost estimate with breakdowns and diffs to understand the costs before launching or making changes to the Infrastructure as Code configuration either in the terminal or pull requests from the VCS provider.

Terraform is the only supported IaC tool at the moment of this writing while the rest of the tools are still part of their product roadmap.




<br><br>
## Objectives
These are the top goals of using Infracost.

* Cost visibility and awareness before resources are launched.
* Aligned budgets and costs.
* Provides cost-benefit analysis for the Consultants to their customers.

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

Registration is **free** for getting the Infracost API key. To do that, issue the command below and it will navigate you to the registration page.

```bash
infracost auth login
```

Retrieve the Infracost API key with the command below.

```bash
infracost configure get api_key
```

Set the Infracost API key to your local computer.

```xml
infracost configure set api_key <your-infracost-api-key-here>
```

<br><br>
### Step 3: Running Infracost CLI
<br>

These are the basic commands of the Infracost CLI.


<details><summary>➡️ Click here to show an estimated cost <u>breakdown</u>.</summary>
<p>

The example below will be showing a breakdown of the cost for all the resources in the Terraform code.

```bash
cd /path/to/terraform-code-project

infracost breakdown --path .
```

Example output:

![Infracost CLI Output](images/infracost-cli1.png)


</p>
</details>

<br>
<details><summary>➡️ Click here to show an estimated cost <u>diff</u>erence.</summary>
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

![Infracost CLI Output](images/infracost-cli2.png)

</p>
</details>



<br><br>
### Step 4: Automate Cloud Cost with CI/CD Integrations


<br><br>
#### Using GitHub Action

Please refer to the [Infracost GitHub Actions](https://github.com/infracost/actions) guide for more details.


* [Create a Github repository secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository) with the following details.
  * Name   = `INFRACOST_API_KEY`
  * Secret = `<Your Infracost API key>`

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
* Now, try to create a pull request to your Github repository and the Actions will automatically running. Below is an example of how it looks like.

  ![Github Comment](images/github.comment.png)

  <br>
  Here is another example combination with Terraform Core workflow.

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
