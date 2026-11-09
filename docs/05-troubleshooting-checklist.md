# 05. Troubleshooting Checklist

## Symptom → fix

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `504 Gateway Timeout` from github.com | GitHub or network path unavailable | Retry; or use a [mirror](03-filesystem-mirror-setup.md) with the [HashiCorp download](04-hashicorp-download-and-lockfile.md) |
| `cannot search ... lstat ... no such file or directory` | Wrong mirror path in `~/.tofurc` | Rewrite `~/.tofurc` using `$HOME`; check `echo $HOME` |
| `zip: not a valid zip file` | Saved error page instead of the zip | `rm` the file; re-download with `curl -f`; size must be about 90-100 MB |
| `curl: (22) ... returned error: 504` on every retry | That host is unreachable from this machine | Use the other host, or download elsewhere and `scp` it |
| `unzip: command not found` | `unzip` not installed | `apt install unzip` |
| No matching package / wrong platform | Wrong architecture in filename | Match `uname -m` (`linux_amd64` or `linux_arm64`) |
| Provider version not found | Version in `versions.tf` isn't in the mirror | Make zip filename and version constraint agree |
| Checksum mismatch after leaving the mirror | Lock file has hashes from the other build | `rm .terraform.lock.hcl && tofu init` |
| `~/.tofurc` seems ignored | File in the wrong place or wrong user | Check `ls -l ~/.tofurc`; set `TF_CLI_CONFIG_FILE=/root/.tofurc` |
| Mirror used when you don't want it | `~/.tofurc` still present | `rm ~/.tofurc` |

## Diagnostic script

Copy and paste to see the state of everything at once:

```bash
echo "== user / home =="; whoami; echo $HOME
echo "== arch ==";        uname -m
echo "== tofu ==";        tofu version
echo "== tofurc ==";      cat ~/.tofurc 2>&1
echo "== mirror files =="; ls -lh ~/.opentofu-mirror/registry.opentofu.org/hashicorp/aws/ 2>&1
echo "== zip test ==";    unzip -t ~/.opentofu-mirror/registry.opentofu.org/hashicorp/aws/*.zip 2>&1 | tail -2
echo "== connectivity =="
for u in https://github.com https://registry.opentofu.org https://releases.hashicorp.com; do
  printf "%s -> " "$u"; curl -s -o /dev/null -m 10 -w "%{http_code}\n" "$u"
done
echo "== dns ==";         nslookup github.com 2>&1 | head -6
echo "== proxy ==";       env | grep -i proxy || echo "no proxy set"
```

Reading the output:
- Zip under 1 MB or `unzip -t` errors: bad download, delete and retry.
- `000` for a host: it could not be reached at all (DNS, firewall, no route).
- `5xx` for a host: the server side is failing.
- `200`/`301`/`302`: the host is reachable.

## Rolling back

Go back to normal provider downloads:

```bash
rm ~/.tofurc
tofu init -upgrade
```

Optionally remove the mirror folder:

```bash
rm -rf ~/.opentofu-mirror
```

## Good habits

- Commit `.terraform.lock.hcl`; never commit `terraform.tfvars` or state files.
- Keep a copy of the provider zip you use somewhere safe so a future outage doesn't block you.
- Pin the provider version you tested.
- Avoid running everything as `root`; use a normal user with `sudo` when AWS credentials are on the machine.
