# Readme
**NOTE: Please replace all the project id `s26-485220` with your own project id** 

## Setup

### setup gcloud, terraform, service accounts
```bash
# login gcloud cli to your corresponding account
gcloud auth login

#enable required apis
gcloud services enable iam.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# initialize terraform 
terraform init

# create new service account for terraform 
# It will have limited permissions (principle of least privilege)
gcloud iam service-accounts create terraform-sa --display-name="Terraform"
gcloud iam service-accounts keys create key.json \
     --iam-account=terraform-sa@s26-485220.iam.gserviceaccount.com

# The command above will create the key.json file in the same folder where it is executed. 

# Add required roles to the service account
gcloud projects add-iam-policy-binding s26-485220 \
  --member="serviceAccount:terraform-sa@s26-485220.iam.gserviceaccount.com" \
  --role="roles/compute.networkViewer"

```

#### Custom roles with principle of least privilege 
Let us create a custom permission and keep all the roles that this terraform config requires there. 
I already have a `custom-terraform-permissions.yaml` file. You can copy this file and modify it as required. 
```sh
gcloud iam roles create terraformSaPermissions \
  --project=s26-485220 \
  --file=custom-terraform-permissions.yaml

# then assign the role to our terraform-sa service account
gcloud projects add-iam-policy-binding s26-485220 \
  --member="serviceAccount:terraform-sa@s26-485220.iam.gserviceaccount.com" \
  --role="projects/s26-485220/roles/terraformSaPermissions"
```
When new permission is required, add it in the `includedPermissions` array of `custom-terraform-permissions.yaml` file, and update the role 
```sh
gcloud iam roles update terraformSaPermissions \
  --project=s26-485220 \
  --file=custom-terraform-permissions.yaml
```

## terraform init, plan, review, apply, destroy
These are the most common commands used in terraform.
```sh
# Needs to be run at the very beginning + anytime you add/update providers in your configuration
terraform init
# generate a plan
terraform plan -out s1.tfplan
# read the terraform plan file
terraform show s1.tfplan

# If you want to see plan in json format it:
# terraform show -json s1.tfplan | jq .
# If you want to see the DAG created by terraform
# (NOTE: this requires graphviz to be installed: https://graphviz.org/download/)
# terraform graph | dot -Tpng > viz.png

terraform apply s1.tfplan

# To read the terraform state file
terraform show

terraform destroy s1.tfplan
```


## Separating configs 
Managing the entire terraform configuration in one file is difficult to maintain. Terraform doesn't impose a specfic way to structure your codebase but there is a general convention in the industry to manage your terraform projects. 
Here are some common files:
- **provider.tf**: Used for defining Terraform provider blocks and backend configuration.
- **main.tf**: Contains the primary resources and overall infrastructure components.
- **<resource_type>.tf**: For larger projects, we can group resources by their function, e.g. `networking.tf` for all the networking related resources, `storage.tf` for all the storage buckets and databases, etc.
- **variables.tf**: All input variables (`variable` blocks) are defined here.
- **outputs.tf**: Output values (`output` blocks) from your configuration are listed here.
- **data.tf**: For data sources

**Best Practices:**
- Place input variables in `variables.tf` and outputs in `outputs.tf`.
- Use separate `.tfvars` file for secrets and environment-specific values (these files should be gitignored). Eg: `dev.tfvars` , `prod.tfvars`
- Keep tfstate, credentials and sensitive data outside version control

## Passing input vars

```sh
# pass input values from flags
terraform plan -out s1.tfplan -var="project-id=s26-485220"

# pass input values from a file
terraform plan -out s1.tfplan -var-file="inputs.tfvars"
```
Here, inputs.tfvars has `key=value` pair. The value needs to match the datatype of the variable. For example:
```sh
some_string_value = "double quoted"
some_bool_value = true
some_int_val = 2
```

## HCL 

### expressions and functions
HCL has a bunch of useful expressios and functions that you can use in your configuration to dynamically create/maintain resources.

For testing, run these HCL values in the repl using command:
```bash
terraform console
```
This will open python-like repl where you can quickly test some commands. 
```hcl
> 5+5

> 5<=5 ? "yes" : "no"

> length("find_length")

> upper("terraform")

> lower("DEV")

> "${lower("DEV")}-database"

> split(",", "hello,14848")
> join(",", ["hello", "14848"])
```

### Review state files
You can also easily view the contents of your terraform state from the console. This is super useful. 
```sh
terraform console
> data.google_compute_zones.available
> google_compute_instance.web1
> google_compute_instance.web-instances[*].name
```
Make sure that these resources actually exist in your configuration.



### Modules
Modules allow us to combine code into logical groups that can be managed together. For example, we can group several resources (e.g. a compute instance, firewall rules, a bucket) into a module and reuse that module across dev and prod, or across multiple projects.

It helps ensure reusability, encapsulation, and maintainability. 

**Module structure (local module):**
A module is a directory containing Terraform files. The root configuration calls it with a `module` block:

```hcl
module "web_instances" {
  source = "./web-server"

  instance_count       = 3
  machine_type         = var.environment_machine_type[var.target_environment]
  labels               = { environment = var.environment_map[var.target_environment] }
  network_self_link    = data.google_compute_network.default.self_link
  subnetwork_self_link = google_compute_subnetwork.subnet-1.self_link
}
```

- **source**: Path to the module (e.g. `./web-server` for a local folder, or a Git/registry URL).
- Arguments passed into the block map to the module’s **input variables** (`variables.tf` inside the module).
- Values from the module are exposed via **outputs**; the root module references them as `module.<name>.<output_name>` (e.g. `module.web_instances.network_ips`).

**Example in this repo: `demo_codes/modules`**

We rewrote the layout from `demo_codes/project_organization` and separated the **web server (web-instances)** into its own module:

| Before (`project_organization`) | After (`demo_codes/modules`) |
|--------------------------------|------------------------------|
| All instances (nginx, web0–web2, web-map, mysqldb) in root `main.tf` | Nginx, web-map, and mysqldb stay in root; the three `web-instances` live in a **web-server** module |

**Layout of `demo_codes/modules`:**
- **Root**: `main.tf`, `variables.tf`, `outputs.tf`, `networking.tf`, `data.tf`, `storage.tf`, `inputs.tfvars` — same roles as in project_organization, but `main.tf` uses `module "web_instances" { source = "./web-server" ... }` instead of a raw `google_compute_instance.web-instances` block.
- **Module `web-server/`**: `main.tf` (resource `google_compute_instance.web-instances` with `count`), `variables.tf` (inputs like `instance_count`, `machine_type`, `labels`, `network_self_link`, `subnetwork_self_link`), `outputs.tf` (e.g. `network_ips`, `instance_names`).

Root `outputs.tf` exposes the web VMs’ private IPs via the module:

```hcl
output "webserver-ips" {
  value = module.web_instances.network_ips
}
```

To run the example:
```sh
cd demo_codes/modules
terraform init
terraform plan -var-file=inputs.tfvars -out=tfplan
terraform apply tfplan
```

See `demo_codes/modules/README.md` for a short walkthrough of the modules layout.

