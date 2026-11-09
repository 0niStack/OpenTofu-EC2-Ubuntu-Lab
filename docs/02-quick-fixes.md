# 02. Quick Fixes

Try these before setting up a mirror.

## 1. Retry

```bash
tofu init
```

Check https://www.githubstatus.com if it keeps failing.

## 2. Test connectivity

```bash
curl -sI https://github.com | head -1
curl -sI https://registry.opentofu.org | head -1
curl -sI https://releases.hashicorp.com | head -1
nslookup github.com
```

| Result | Meaning | Next step |
|--------|---------|-----------|
| GitHub fails, HashiCorp works | GitHub path is blocked or down | Use the [mirror setup](03-filesystem-mirror-setup.md) with the [HashiCorp download](04-hashicorp-download-and-lockfile.md) |
| All fail | Network, DNS, proxy or firewall problem | Fix DNS or the network first |
| All work | Issue was temporary | Retry `tofu init` |

## 3. Change DNS

```bash
echo "nameserver 1.1.1.1" > /etc/resolv.conf
```

On systems using `systemd-resolved`, this file may be overwritten. Configure
DNS through your network manager if the change doesn't stick.

## 4. Check for a proxy

```bash
env | grep -i proxy
```

If a proxy is set, make sure it allows `github.com`, `*.githubusercontent.com`
and `releases.hashicorp.com`.

## 5. Pin another provider version

If only one release fails to download, pin a different one in `versions.tf`:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.1"
    }
  }
}
```

```bash
tofu init -upgrade
```

## 6. Try later or from another network

A mobile hotspot or a VPN exit in another region often avoids a bad route to
GitHub's CDN.

If none of this works, go to
[03-filesystem-mirror-setup.md](03-filesystem-mirror-setup.md).
