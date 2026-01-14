## Application Infrastructure

This project demonstrates a DevOps infrastructure setup for deploying a **web application** on **Microsoft Azure**.

The project showcases modern **Infrastructure as Code (IaC)** practices, automated **CI/CD pipelines**, containerization, and orchestration using **Kubernetes**. The infrastructure is designed with scalability, reproducibility, and DevOps best practices in mind.

**Note:** This repository is a **public portfolio copy** created for demonstration and learning purposes.

### Technology Stack

- **Cloud Platform**: Microsoft Azure
- **Infrastructure as Code**: Terraform
- **Container Orchestration**: Kubernetes (AKS)
- **Container Registry**: Azure Container Registry (ACR)
- **Database**: Azure MySQL Flexible Server
- **Ingress Controller**: Traefik
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus + Grafana
- **Deployment**: Helm Charts

### Architecture

The project follows a microservices architecture with three separate repositories:

1. **Infrastructure Repository** (this repo)
2. **Frontend Repository**
3. **Backend Repository**

When changes are pushed to frontend or backend repositories, webhooks trigger automated builds and deployments through the infrastructure repository.

## Infrastructure Components

### Azure Resources Created by Terraform

- **Networking**
- **Azure Kubernetes Service (AKS)**
- **Azure Container Registry (ACR)**
- **Azure MySQL Flexible Server 8.0.21**
- **Traefik Ingress Controller**
- **Prometheus**
- **Grafana**

## Helm Chart Structure

The project uses a unified Helm chart to deploy both frontend and backend components

- **High Availability**: Minimum 2 replicas for each service
- **Auto-scaling**: HPA configured for both frontend and backend
- **Health Checks**: Liveness and readiness probes
- **Configuration Management**: ConfigMaps for JWT, Secrets for credentials
- **Ingress Routing**: Path-based routing (`/api/*` → backend, `/*` → frontend)

## CI/CD Pipeline

The deployment pipeline consists of three sequential GitHub Actions workflows:

### 1. Terraform Workflow
**Trigger**: Push to `master` branch or manual dispatch

**Actions**:
- Authenticates to Azure via OIDC (no static credentials)
- Initializes Terraform with remote state in Azure Storage
- Plans and applies infrastructure changes
- Deploys Traefik, Prometheus, and Grafana via Helm
- Exports outputs (ACR URL, MySQL host, public IP)

### 2. Build & Push Workflow
**Trigger**: Terraform completion, repository webhooks, or manual dispatch

**Actions**:
- Checks out frontend and backend repositories
- Builds Docker images with commit-specific tags
- Pushes images to Azure Container Registry
- Tags images as `latest` for deployment

### 3. Deploy Workflow
**Trigger**: Build completion or manual dispatch

**Actions**:
- Retrieves Terraform outputs
- Connects to AKS cluster
- Deploys application using Helm
- Configures dynamic values (domain, database, secrets)
- Waits for rollout completion
- Verifies deployment status

## Getting Started

### Prerequisites

- Azure account with active subscription
- Azure CLI installed
- GitHub account
- kubectl installed (for local management)

### Step 1: Create Service Principal

Create a Service Principal for GitHub Actions authentication:

```bash
az ad sp create-for-rbac \
  --name "github-terraform-ci-cd" \
  --role="Contributor" \
  --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID" \
  --sdk-auth
```

Save the JSON output for GitHub Secrets configuration.

### Step 2: Create Terraform Backend Storage

Set up variables:

```bash
RESOURCE_GROUP="rg-terraform-state"
LOCATION="northeurope"
STORAGE_ACCOUNT="tfstategames123451854321"
CONTAINER_NAME="tfstate"
SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
```

Create resources:

```bash
# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create storage account
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --encryption-services blob \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

# Create container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT \
  --auth-mode login

# Enable versioning
az storage account blob-service-properties update \
  --account-name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --enable-versioning true

# Enable soft delete
az storage account blob-service-properties update \
  --account-name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --enable-delete-retention true \
  --delete-retention-days 30

# Grant Service Principal access
az role assignment create \
  --assignee  \
  --role "Storage Blob Data Contributor" \
  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT
```

### Step 3: Configure GitHub Secrets

Add the following secrets to your GitHub repository:

#### Azure Authentication
- `AZURE_CLIENT_ID` - Service Principal Application ID
- `AZURE_TENANT_ID` - Azure Tenant ID
- `AZURE_SUBSCRIPTION_ID` - Azure Subscription ID

#### Application Secrets
- `MYSQL_ADMIN_PASSWORD` - MySQL administrator password (strong password)
- `GRAFANA_ADMIN_PASSWORD` - Grafana admin password
- `JWT_SECRET` - JWT signing secret (generate random string)
- `RAWG_KEY` - RAWG API key (if using RAWG API)

#### GitHub Integration
- `PAT_TOKEN` - Personal Access Token with `repo` scope

### Step 4: Configure External Repositories

In your **frontend repository**, create `.github/workflows/webhook.yml`:

```yaml
name: Trigger Build on Main Repo

on:
  push:
    branches:
      - main

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger build in main repository
        run: |
          curl -X POST \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Authorization: token ${{ secrets.PAT_TOKEN }}" \
            https://api.github.com/repos/YOUR_USERNAME/my-project-infrastructure/dispatches \
            -d '{"event_type":"frontend-updated","client_payload":{"ref":"${{ github.ref }}","sha":"${{ github.sha }}"}}'

      - name: Summary
        run: |
          echo "Commit: ${{ github.sha }}" >> $GITHUB_STEP_SUMMARY
          echo "Branch: ${{ github.ref_name }}" >> $GITHUB_STEP_SUMMARY
```

In your **backend repository**, create the same file but change `event_type` to `backend-updated`.

Add the `PAT_TOKEN` secret to both repositories.

### Step 5: Update Configuration

Update the following files with your values:

**`.github/workflows/build-push.yml`**:
```yaml
env:
  FRONTEND_REPO: "YOUR_ORG/frontend"
  BACKEND_REPO: "YOUR_ORG/backend"
```

**Terraform variables** (create `terraform/terraform.tfvars`):
```hcl
acr_name          = "acrgamesYOURUNIQUEID"
mysql_server_name = "mysql-games-YOURUNIQUEID"
```

### Step 6: Deploy Infrastructure

Push changes to the `master` branch or manually trigger the Terraform workflow:

```bash
git add .
git commit -m "Initial infrastructure setup"
git push origin master
```

Monitor the deployment in GitHub Actions tab.

## Accessing the Application

After successful deployment, your application will be available at:

Application:  http://games.<PUBLIC_IP>.nip.io
Grafana:      http://grafana.<PUBLIC_IP>.nip.io

### Update Application

To deploy new versions:

1. Push changes to frontend or backend repository
2. Webhook automatically triggers build and deploy
3. Monitor deployment in GitHub Actions

Or manually trigger:
- Go to `Actions` → `Deploy to Kubernetes` → `Run workflow`

## Monitoring

### Grafana Dashboards

Access Grafana at `http://grafana.<PUBLIC_IP>.nip.io`

**Login**: `admin` / `<GRAFANA_ADMIN_PASSWORD>`

### Prometheus Metrics

Prometheus is available internally and scrapes:
- Kubernetes cluster metrics
- Node metrics
- Traefik metrics
- Application metrics (if exposed)

## Cleanup

To destroy all resources:
- Via GitHub Actions
- Go to `Actions` → `Terraform Azure CI/CD` → `Run workflow`
- Set destroy input to "destroy"

## Security Features

- OIDC authentication (no static Azure credentials)
- Private MySQL endpoint (no public access)
- Encrypted Terraform state with versioning
- AKS RBAC enabled
- Network isolation with private endpoints
- Secrets stored in GitHub Secrets/Kubernetes Secrets
- ACR authentication via Managed Identity
