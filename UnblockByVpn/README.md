# UnblockByVpn
Script for create firewall address group from list of domains

# How to use
## Host
### 1. Clone repository
```sh
git clone git@github.com:kirill-zak/EdgeRouterScripts.git
```

### 2. Copy scripts into router
```sh
scp -r EdgeRouterScripts/UnblockByVpn 192.168.1.1:/config/user-data/UnblockByVpn
```

## Router
### 1. Set chmod
```sh
chmod +x /config/user-data/UnblockByVpn/UnblockByVpn
```

### 2. Create file with list of domains
```sh
touch /config/user-data/UnblockByVpn/domains.conf
```

### 3. Add domains
Add list of domains into **domains.conf**. One domain by line

### 4. Run
```sh
/config/user-data/UnblockByVpn/UnblockByVpn
```

## Enjoy