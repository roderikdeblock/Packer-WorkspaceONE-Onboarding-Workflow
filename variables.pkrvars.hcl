# -------------------------------------------------------
# Adjust all values below before running packer build
# Add this file to .gitignore — it contains credentials
# -------------------------------------------------------

vcenter_server   = "<FQDN or IP Address>"
vcenter_user     = "<vCenter User/Admin>"
vcenter_password = "<Password>"

datacenter       = "<DC - NAME>"
cluster          = "<Cluster - NAME>"
datastore        = "<Datastore - NAME>"
network          = "<VM Network>"

iso_path         = "< Example [Local_NVME_1TB]  Win11_25H2_English_x64_v2.iso>"

vm_name          = "win11-25h2-template"

winrm_username = "Administrator"
winrm_password   = "<Packer1234!>"
