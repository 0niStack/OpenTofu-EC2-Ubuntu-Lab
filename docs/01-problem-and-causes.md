# 01. The Problem and Its Causes

## How OpenTofu installs providers

1. `tofu init` reads the `required_providers` block in `versions.tf`.
2. It asks `registry.opentofu.org` which versions exist and where the files are.
3. The registry points to **GitHub releases** (`github.com/opentofu/terraform-provider-aws`).
4. OpenTofu downloads the provider zip and its `SHA256SUMS` file from GitHub, verifies them, and unpacks the provider into `.terraform/`.

If step 3 or 4 cannot reach GitHub, `init` fails even though your configuration is correct.

## Error 1: 504 Gateway Timeout

```
Error: Failed to install provider

Error while installing hashicorp/aws v5.100.0: could not query provider registry for
registry.opentofu.org/hashicorp/aws: failed to retrieve authentication checksums for
provider: request failed after 2 attempts: 504 Gateway Timeout returned from
https://github.com/opentofu/terraform-provider-aws/releases/download/v5.100.0/terraform-provider-aws_5.100.0_SHA256SUMS
```

**Cause:** GitHub, or the network path between your machine and GitHub, did not
answer in time. Often temporary. Sometimes it is a firewall, proxy, DNS or
regional routing issue on your side.

**Fix:** see [02-quick-fixes.md](02-quick-fixes.md) and
[03-filesystem-mirror-setup.md](03-filesystem-mirror-setup.md).

## Error 2: mirror folder not found

```
Error: Failed to resolve provider packages

Could not resolve provider hashicorp/aws: cannot search /home/root/.opentofu-mirror:
lstat /home/root/.opentofu-mirror: no such file or directory
```

**Cause:** `~/.tofurc` points to a folder that doesn't exist. The usual mistake
is `/home/root/...`. The home directory of `root` is `/root`.

**Fix:** check `echo $HOME` and write the path from `$HOME`
(see [03](03-filesystem-mirror-setup.md#step-5-configure-tofurc)).

## Error 3: not a valid zip file

```
Error while installing hashicorp/aws v5.100.0: zip: not a valid zip file
```

**Cause:** the file in the mirror folder is not a zip. A `curl` without `-f`
saves the server's error page (for example the HTML of a 504 response) under the
zip's filename. The file is only a few dozen bytes:

```
-rw-r--r-- 1 root root 92 Nov  8 08:53 terraform-provider-aws_5.100.0_linux_amd64.zip
```

Check what it contains:

```bash
cat terraform-provider-aws_5.100.0_linux_amd64.zip
# <html><body><h1>504 Gateway Time-out</h1> ...
```

**Fix:** delete it and download again with `curl -f`
(see [03](03-filesystem-mirror-setup.md#step-3-download-the-provider-zip)).

## Error 4: download retries all fail

```
curl: (22) The requested URL returned error: 504
Warning: Problem : HTTP error. Will retry in 5 seconds. 1 retries left.
```

**Cause:** the host you're downloading from is down or unreachable from your
machine, and retrying doesn't help.

**Fix:** use a different download host
([04](04-hashicorp-download-and-lockfile.md)) or download from another computer
and copy the file over with `scp`.
