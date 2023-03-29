# Deploy PowerProtect DDMC and PowerProtect DDVE
````
---
# MISC
ad_domain: vcorp.local
artifact_path: /var/lib/awx/projects/common
# DDMC
ddmc_host: ddmc-01
ddmc_ip: 192.168.3.9
ddmc_ova: ddmc-ddnvm-infra-7.10.0.20-1023227.ova
ddmc_old_pwd: changeme
# POWERPROTECT DD
ddve_host: ddve-01
ddve_old_pwd: changeme
ddve_ip: 192.168.3.110
ddve_netmask: 255.255.252.0
ddve_gateway: 192.168.1.250
ddve_dns1: 192.168.1.11
ddve_dns2: 192.168.1.11
ddve_ova: ddve-7.10.0.20-1023227.ova
ddve_disk_size: 500
ddve_disk_type: thin

# VCENTER
vcenter_host: vc-01.vcorp.local
vcenter_dc: DC01-VC01
vcenter_ds: Unity-DS1
vcenter_folder: "/{{vcenter_dc}}/vm/Deploy/"
vcenter_network: VM Network
````