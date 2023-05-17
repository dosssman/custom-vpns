# vultr-cli tools

A collection of scripts to automate generic VPN node creation on VULTR VPS provider.

- Creating an instance:

```bash
vultr-cli instance create -o <osId> --p <planId> --r <regionId> -s <sshId_0,sshId_1> --script-id <scriptId_0,scriptId_1> -l <label>

# JP Server VPN Node example
vultr-cli instance create -o 387 -p "vc2-1c-1gb" -r nrt -l "GenericVPN-JP" -s "a6fb92f8-b8d1-47c9-9511-8f2dc116714b,6bc9749a-ad09-4d35-add4-fc41afeb8341" --script-id "18a18387-c4ec-4c0a-8fcd-d1151486fa27"
```

The `vultr-cli` is fairly self-explanotory and intutive to use.