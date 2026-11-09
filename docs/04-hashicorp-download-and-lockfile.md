# 04. Downloading from HashiCorp and the Lock File

## Why use releases.hashicorp.com

The `hashicorp/aws` provider zip is published on two hosts:

| Host | Published by | Used by default |
|------|--------------|-----------------|
| `github.com/opentofu/terraform-provider-aws` | OpenTofu project (via `registry.opentofu.org`) | Yes |
| `releases.hashicorp.com` | HashiCorp | No |

When GitHub returns 504 but HashiCorp's server responds, download from
HashiCorp and put the zip in the [filesystem mirror](03-filesystem-mirror-setup.md).

```bash
cd ~/.opentofu-mirror/registry.opentofu.org/hashicorp/aws/

curl -fL --retry 5 --retry-delay 5 --retry-all-errors \
  -o terraform-provider-aws_5.100.0_linux_amd64.zip \
  https://releases.hashicorp.com/terraform-provider-aws/5.100.0/terraform-provider-aws_5.100.0_linux_amd64.zip

ls -lh
unzip -t terraform-provider-aws_5.100.0_linux_amd64.zip | tail -2
```

Flags:

| Flag | Purpose |
|------|---------|
| `-f` | Fail on HTTP errors instead of saving the error page |
| `-L` | Follow redirects |
| `--retry 5 --retry-delay 5` | Retry up to 5 times, 5 seconds apart |
| `--retry-all-errors` | Retry on any error, including 5xx |
| `-o <name>` | Save under the exact filename the mirror expects |

## Verify the download

A mirror install does not check signatures against the registry, so verify the
file yourself. Download the checksum file from the same release and compare:

```bash
cd /tmp
curl -fLO https://releases.hashicorp.com/terraform-provider-aws/5.100.0/terraform-provider-aws_5.100.0_SHA256SUMS

grep linux_amd64.zip terraform-provider-aws_5.100.0_SHA256SUMS
sha256sum ~/.opentofu-mirror/registry.opentofu.org/hashicorp/aws/terraform-provider-aws_5.100.0_linux_amd64.zip
```

The two SHA-256 values must be identical. If they differ, delete the zip and download again.

## Lock file behavior

`tofu init` writes `.terraform.lock.hcl`, which records the provider version and
its hashes:

```hcl
provider "registry.opentofu.org/hashicorp/aws" {
  version     = "5.100.0"
  constraints = "~> 5.0"
  hashes = [
    "h1:...",
  ]
}
```

Things to know:

- When a provider is installed from a **mirror**, the lock file records hashes of the package that was actually installed.
- The zip built by HashiCorp and the one built by the OpenTofu project are the same provider version but may not be byte-identical, so their hashes can differ.
- If you later remove the mirror and install from the registry again, `tofu init` may report a **checksum mismatch** against the recorded hashes.

### Fixing a checksum mismatch

Option 1: delete the lock file and initialize again.

```bash
rm .terraform.lock.hcl
tofu init
```

Option 2: keep the lock file and add the hashes for other platforms or sources:

```bash
tofu providers lock \
  -platform=linux_amd64 \
  -platform=linux_arm64 \
  -platform=darwin_arm64
```

This one needs access to the registry, so use it once GitHub is reachable.

### Committing the lock file

Commit `.terraform.lock.hcl` so every machine gets the same provider version.
If different teammates install from different sources, expect to run
`tofu providers lock` for the platforms you use.

## Using another version

Change the version in both places so they match:

1. `versions.tf`: `version = "5.100.0"` (or `"~> 5.0"`)
2. The zip filename in the mirror folder: `terraform-provider-aws_<version>_linux_amd64.zip`

Then run `tofu init -upgrade`.
