# terraform-azure-jira

This repository contains scripts to assist with deploying Jira using Terraform to Azure.  This will include a single VM using Azure SQL for the database server.

## Azure requirements

Setup you private Azure creds before running the script :

```
subscription_id     = "---"
client_id           = "---"
client_secret       = "---"
tenant_id           = "---"
```

(Create Service Principal)[https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal]

Note: Above should be stored in a file called terraform.tfvars

## Terraform Files

The following table describes the terraform files and their purpose.  

| File                | Description       | 
| ------------------- | ----------------- | 
| variables.tf        | Contains variables and config values used for deployment| 
| provider.tf         | Contains provider settings     |
| rsg.tf              | Contains resource group settings     |
| nsg.tf              | Contains network security group     |   
| network.tf          | Contains network settings     |
| storage.tf          | Contains storage account settings     |
| vm-1.tf             | Jira virtual machine |
| lb.tf               | Load balancer     |
| sql_db.tf           | Azure SQL DB     |


Note: variables.tf should be customized for your specific settings

### Steps to initialize this project
- Enter all the variables in variable file (terraform.tfvars)
- Add storage account , container name , Access Key at the end of  azure_vm.tf file for storing terraform state file remotely to azure (you need to have a already created storage account for storing the state file )

Run following commands to run & test Terraform scripts :

- terraform init        (To initialize the project)
- terraform plan        (To check the changes to be made by Terraform on azure )
- terraform apply       (To apply the changes to azure)



## Links

https://terraform.io

https://azure.microsoft.com

http://www.techoism.com/how-to-install-jira-on-centosrhel/

https://confluence.atlassian.com/adminjiraserver/installing-jira-applications-on-linux-938846841.html