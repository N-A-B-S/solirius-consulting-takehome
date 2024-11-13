Step by Step Guide:

1. Install Terraform and Azure CLI.
2. `az login` and `az account set -s subscription` (Login to Azure and set your subscription)
3. Create a service principal. `az ad sp create-for-rbac --name "terraform" --scopes /subcriptions/<subscription_id>` (Allows Terraform and GitHub Actions to authenticate with Azure. This outputs `appId`, `client_secret (password)`, `tenant` and `subscription`)
4. Storage space for tfstate. I'm initialising this manually so it can be used right away when Terraform runs the first time. Else, Terraform would use local state, and then I'd need to reconfigure to use the remote state.
    - `az group create --name tfstate_rg --location uk-south`
    - `az storage account create --name tfstate --resource-group tfstate_rg --location uk-south --sku Standard_LRS`
    - `az storage container create --name tfstate --account-name tfstate `
5. Create separate blocks and files for infrastructure. App plan, app. SQL server. Modularisation allows extendability as you can easily make changes to one section without affecting others. Parameterisation of key values such as location and names allow them to be easily changes/reused without needing to effect the underlying code. Configuring autoscaling early allows our applications to scale for use easily, 
6.  SQL I use read-replicas and zone redundancyu to allow scalability of reads, and redunancy in the event of a failure of an AZ. In production, I would recommend cross-region replication to allow for disaster recovery.

