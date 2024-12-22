# YouTubeToAddressGroup
Script for create firewall address group from list of YouTube IP

# How to use
## Host
### 1. Clone repository
```sh
git clone git@github.com:kirill-zak/EdgeRouterScripts.git
```

### 2. Copy scripts into router
```sh
scp -r EdgeRouterScripts/YouTubeToAddressGroup 192.168.1.1:/config/user-data/YouTubeToAddressGroup
```

## Router
### 1. Set chmod
```sh
chmod +x /config/user-data/YouTubeToAddressGroup/YouTubeToAddressGroup.sh
```

### 2. Run
```sh
/config/user-data/YouTubeToAddressGroup/YouTubeToAddressGroup.sh
```

## Enjoy