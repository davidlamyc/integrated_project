1. Set the following environment variables per your credentials
```
export ARM_CLIENT_ID="<YOUR_CLIENT_ID>"
export ARM_CLIENT_SECRET="<YOUR_CLIENT_SECRET>"
export ARM_TENANT_ID="<YOUR_TENANT_ID>"
export ARM_SUBSCRIPTION_ID="<YOUR_SUBSCRIPTION_ID>"
```
2. In each of the infra layers run `./terraform init`, `./terraform plan -out="main.tfplan`, `./terraform plan -out="main.tfplan"`
3. Create a principal and get the credentials (should be skippable)
```
az ad sp create-for-rbac --name "github-actions-deployer" --role contributor --scopes /subscriptions/<subscription-id>/resourceGroups/rg-hubspoke-network --sdk-auth
```
4. Copy and paste the output from 3. into Action's secrets with the key as `AZURE_CREDENTIALS` (should be skippable)
5. Set up `AZURE_STATIC_WEB_APPS_API_TOKEN` per terraform's output for `static_web_app_api_key`
6. Get (from portal UI) and set up `AZURE_WEBAPP_PUBLISH_PROFILE`
7. Trigger both deployment runs for backend and frontend
8. Run `nslookup backend-mssql-server.database.windows.net` to check db connectivity
