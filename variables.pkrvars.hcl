# -------------------------------------------------------
# Adjust all values below before running packer build
# Add this file to .gitignore — it contains credentials
# -------------------------------------------------------

vcenter_server   = "192.168.1.211"
vcenter_user     = "administrator@vsphere.local"
vcenter_password = "Thijmen7!"

datacenter       = "RDB"
cluster          = "RDB"
datastore        = "Local_NVME_1TB"
network          = "VM Network"

iso_path         = "[Local_NVME_1TB]  Win11_25H2_English_x64_v2.iso"

vm_name          = "win11-25h2-template"

winrm_username = "Administrator"
winrm_password   = "Packer1234!"
