# Terraform IaC for ASP.NET Web Application Deployment

### Project Goals
The primary goals of this project are:
- automate the provisioning of infrastructure using Terraform modules
- deploy an ASP.NET web application to the Web VM
- establish secure communication between the Web VM and DB VM via a private IP address
- utilize Azure Storage Account for storing scripts and images
- implement a scalable and maintainable IaC approach for managing the entire application stack

### Project Overview
This project focuses on automating the deployment of an ASP.NET web application MyPortfolioApp and its associated infrastructure using Terraform. 

The infrastructure includes two virtual machines (VMs) hosted in Microsoft Azure: a web VM for hosting the ASP.NET web application and a database (DB) VM for running Microsoft SQL Server. The web VM is publicly accessible, while the DB VM is only accessible via a private IP within the virtual network.


## Infrastructure as Code (IaC)

### Prerequisites
Before starting the project, ensure the following prerequisites are met:
- Azure Image available in the Azure Compute gallery
- image should be pre-configured with:
  - Installed Internet Information Services (IIS)
  - Web Management Services
  - ASP.NET Hosting Bundle
  - Web Deploy 3.6
- use a custom script extension to prepare the VM(script in scripts folder) or manually create an Azure VM, connect to it, install the required components, and create an image from deployed VM using [Microsoft Azure UI](https://learn.microsoft.com/en-us/azure/virtual-machines/capture-image-portal)

### Infrastructure Components
The project's infrastructure consists of the following components:
- Web Virtual Machine (Web VM) which hosts the ASP.NET web application and has a public IP address to accept connections from the internet
  - This VM is provisioned using an Azure Image from the Azure Compute gallery, image is a prerequisite for the project as explained in [Prerequisites](#prerequisites) section
- Database Virtual Machine (DB VM) which hosts Microsoft SQL Server and does not have a public IP address, the Web VM communicates with it via a private IP within the virtual network
- Azure Storage Account where scripts and images for the web application are stored

### Terraform Modules
Terraform is used to create and manage these infrastructure components. The project is organized into modular Terraform configurations for ease of management and reusability. 

### Azure Resources
Azure resources created by the Terraform modules include virtual machines, virtual networks, subnets, network security groups, public IPs, private IPs, Azure Storage Account, Azure Bastion and more.

## ASP.NET Web Application Deployment
After provisioning the infrastructure, the next step is to deploy the ASP.NET web application to the Web VM. This can be done manually or through a CI/CD pipeline. The web application interacts with the DB VM using a private IP to retrieve image paths stored in the database. These paths are then used in the `src` attribute of HTML elements to fetch images from the Azure Storage Account.

The Web VM communicates with the DB VM using a private IP address within the same virtual network. This ensures secure and efficient communication between the two VMs while keeping the DB VM inaccessible from the public internet.

## Getting Started
To get started with this project, follow these steps:
- clone this repository to your local machine
```shell
git clone https://github.com/CREPIC21/az-administrator-architect.git
```
- change into the project directory:
```shell
cd az-administrator-architect/05_Azure_IaC_Project_ASP.NET_Website/MyPortfolioAppTerraformIaC
```
- set up your Azure credentials and Terraform environment
- customize the Terraform variables and configurations to match your requirements, specifically below variables:
  - `DB_VM_ADMIN_USERNAME`
  - `DB_VM_ADMIN_PASSWORD`
  - `SQL_USERNAME`
  - `SQL_PASSWORD`
- run `terraform init` to initialize the project
- run `terraform apply` to create the infrastructure
- once the infrastructure is provisioned, deploy your ASP.NET web application to the web VM and ensure that the application is configured to communicate with the DB VM using the private IP address
  - in `appsettings.json` replace nessesary credentails:
  ```json
  {
  "ConnectionStrings": {
    "SQLConnection": "Server=<server_ip>;Database=<db_name>;User Id=<user>;Password=<password>"
    }
  }
  ```