# 03. Filesystem Mirror Setup

A filesystem mirror lets OpenTofu install a provider from a local folder
instead of downloading it from GitHub during `init`.

## Step 1: Check your architecture

```bash
uname -m
```

| Output | Use in filename |
|--------|-----------------|
| `x86_64` | `linux_amd64` |
| `aarch64` | `linux_arm64` |

The examples use `linux_amd64` and version `5.100.0`.

## Step 2: Create the mirror folder

The layout must match the registry path exactly:

```
~/.opentofu-mirror/
└── registry.opentofu.org/
    └── hashicorp/
        └── aws/
            └── terraform-provider-aws_5.100.0_linux_amd64.zip
```

```bash
mkdir -p ~/.opentofu-mirror/registry.opentofu.org/hashicorp/aws
cd ~/.opentofu-mirror/registry.opentofu.org/hashicorp/aws
```

## Step 3: Download the provider zip

Use `-f` so curl fails on HTTP errors instead of saving the error page as the
zip. Keep the **exact filename**.

From HashiCorp's release server (see [04](04-hashicorp-download-and-lockfile.md)):

```bash
curl -fL --retry 5 --retry-delay 5 --retry-all-errors \
  -o terraform-provider-aws_5.100.0_linux_amd64.zip \
  https://releases.hashicorp.com/terraform-provider-aws/5.100.0/terraform-provider-aws_5.100.0_linux_amd64.zip
```

Or from GitHub:

```bash
curl -fL --retry 5 --retry-delay 5 --retry-all-errors \
  -O https://github.com/opentofu/terraform-provider-aws/releases/download/v5.100.0/terraform-provider-aws_5.100.0_linux_amd64.zip
```

If neither works from the server, download the zip in a browser on another
computer and copy it:

```bash
scp terraform-provider-aws_5.100.0_linux_amd64.zip \
  root@SERVER_IP:/root/.opentofu-mirror/registry.opentofu.org/hashicorp/aws/
```

## Step 4: Verify the download

```bash
ls -lh
unzip -t terraform-provider-aws_5.100.0_linux_amd64.zip | tail -2
```

Expected:
- File size roughly 90-100 MB
- Last line: `No errors detected in compressed data of ...`

If `unzip` isn't installed: `apt install unzip`.

If the file is tiny or `unzip -t` fails, delete it and download again:

```bash
rm terraform-provider-aws_5.100.0_linux_amd64.zip
```

Keep only valid provider zips in this folder.

## Step 5: Configure `~/.tofurc`

Using `$HOME` in the heredoc avoids wrong-path mistakes:

```bash
cat > ~/.tofurc <<EOF
provider_installation {
  filesystem_mirror {
    path    = "$HOME/.opentofu-mirror"
    include = ["registry.opentofu.org/hashicorp/aws"]
  }
  direct {
    exclude = ["registry.opentofu.org/hashicorp/aws"]
  }
}
EOF
cat ~/.tofurc
```

The `path` must be an absolute path: `/root/.opentofu-mirror` for root,
`/home/<user>/.opentofu-mirror` for a normal user. Do not use `~` inside the file.

What the blocks mean:
- `filesystem_mirror` with `include`: `hashicorp/aws` is installed from the local folder
- `direct` with `exclude`: every other provider is still downloaded normally, but not `hashicorp/aws`

## Step 6: Initialize

```bash
cd ~/OpenTofu-EC2-Ubuntu-Lab
tofu init
```

Expected output:

```
- Installing hashicorp/aws v5.100.0...
OpenTofu has been successfully initialized!
```

The provider version you pin in `versions.tf` must exist in the mirror folder.
`~> 5.0` accepts `5.100.0`.

## Optional: plugin cache

Avoid re-downloading providers in every project:

```bash
mkdir -p ~/.opentofu-plugin-cache
```

Add this line to `~/.tofurc` (outside the `provider_installation` block):

```hcl
plugin_cache_dir = "/root/.opentofu-plugin-cache"
```

## Adding more providers or versions

Put another zip next to the first one with the same naming pattern
(`terraform-provider-aws_<version>_<os>_<arch>.zip`). For a different provider,
create `registry.opentofu.org/<namespace>/<type>/` and add its address to the
`include` list.
