# opentofu-ec2-ubuntu

OpenTofu project that provisions 1-10 identical AWS EC2 instances (default: 3, named `lab-1`, `lab-2`, `lab-3`) with:

- **Count / names:** `instance_count` VMs named `<name_prefix>-1`, `-2`, ...
- **Instance type:** `t3.medium`
- **OS:** Ubuntu 24.04 LTS, pinned AMI `ami-0d6dd9e8265d48906` (us-east-1, build 20261023)
- **Storage:** 30 GiB gp3 root volume
- **Key pair:** created in AWS by importing your existing public key
- **Security group:** SSH (22) and all TCP ports (0-65535) open inbound, all outbound allowed

## Structure

```
opentofu-ec2-ubuntu/
├── main.tf                    # wires the modules together
├── providers.tf               # AWS provider + default tags
├── versions.tf                # OpenTofu / provider versions
├── variables.tf               # root input variables
├── outputs.tf                 # names, IPs, SSH commands
├── terraform.tfvars.example   # copy to terraform.tfvars and edit
├── .gitignore
└── modules/
    ├── key-pair/              # imports your public key
    ├── security-group/        # SSH + all TCP rules
    └── ec2/                   # instances (count, pinned AMI)
```

## Prerequisites

- [OpenTofu](https://opentofu.org/docs/intro/install/) >= 1.6
- AWS credentials configured (`aws configure` or `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`)
- An existing SSH key pair on your machine (public key file ending in `.pub`)

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: region, ami_id, key_name, public_key_path, allowed CIDRs

tofu init
tofu plan
tofu apply
```

Connect with the `ssh_commands` output, one per VM:

```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@<public_ip>
```

Change `instance_count` and re-run `tofu apply` to scale. Going from 3 to 2
destroys `lab-3`; going from 2 to 3 adds a new `lab-3`.

Destroy everything:

```bash
tofu destroy
```

## Variables

| Name | Default | Description |
|------|---------|-------------|
| `region` | `us-east-1` | AWS region (must match the AMI) |
| `ami_id` | `ami-0d6dd9e8265d48906` | Pinned Ubuntu 24.04 AMI (us-east-1) |
| `instance_count` | `3` | Number of VMs (1-10) |
| `name_prefix` | `lab` | VM names: `<prefix>-1`, `<prefix>-2`, ... |
| `instance_type` | `t3.medium` | Instance type |
| `root_volume_size` | `30` | Root volume size (GiB) |
| `key_name` | `my-imported-key` | Key pair name created in AWS |
| `public_key_path` | `~/.ssh/id_ed25519.pub` | Public key to import |
| `ssh_allowed_cidrs` | `["0.0.0.0/0"]` | CIDRs allowed on port 22 |
| `all_tcp_allowed_cidrs` | `["0.0.0.0/0"]` | CIDRs allowed on all TCP ports |
| `tags` | ManagedBy, Project | Default tags |

## Security warning

By default, **every TCP port is open to the whole internet**. Anything listening
on the instance (databases, dashboards, etc.) becomes publicly reachable.
Restrict both CIDR variables to your own IP:

```hcl
ssh_allowed_cidrs     = ["203.0.113.10/32"]
all_tcp_allowed_cidrs = ["203.0.113.10/32"]
```

## Notes

- Uses the default VPC of the selected region. The instance gets a public IP
  from the default subnet.
- If a key pair with the same name already exists in AWS, change `key_name` or
  run `tofu import module.key_pair.aws_key_pair.this <key_name>`.
- Never commit `terraform.tfvars` or state files (see `.gitignore`).

## Changing the AMI

AMI IDs are region-specific. To use another region or a newer Ubuntu build, look
up the ID at https://cloud-images.ubuntu.com/locator/ec2/ and set both `region`
and `ami_id`. Verify with:

```bash
aws ec2 describe-images --region us-east-1 --image-ids ami-0d6dd9e8265d48906 \
  --query 'Images[0].[OwnerId,Name,Architecture]' --output text
```
