packer {
  required_plugins {
    vsphere = {
      version = ">= 1.4.0"
      source  = "github.com/hashicorp/vsphere"
    }
    windows-update = {
      version = ">= 0.14.0"
      source  = "github.com/rgl/windows-update"
    }
  }
}

variable "vcenter_server" {
  type = string
}

variable "vcenter_user" {
  type = string
}

variable "vcenter_password" {
  type      = string
  sensitive = true
}

variable "datacenter" {
  type = string
}

variable "cluster" {
  type = string
}

variable "datastore" {
  type = string
}

variable "network" {
  type = string
}

variable "iso_path" {
  type = string
}

variable "vm_name" {
  type    = string
  default = "win11-25h2-template"
}

variable "winrm_username" {
  type    = string
  default = "Administrator"
}

variable "winrm_password" {
  type      = string
  sensitive = true
}

source "vsphere-iso" "win11" {
  # vCenter connection
  vcenter_server      = var.vcenter_server
  username            = var.vcenter_user
  password            = var.vcenter_password
  insecure_connection = true
  datacenter          = var.datacenter
  cluster             = var.cluster
  datastore           = var.datastore

  # VM settings
  vm_name       = var.vm_name
  guest_os_type = "windows2019srvNext_64Guest"
  firmware      = "efi-secure"
  vTPM          = true
  CPUs          = 2
  RAM           = 4096

  # Disk
  disk_controller_type = ["pvscsi"]
  storage {
    disk_size             = 61440
    disk_thin_provisioned = true
    disk_controller_index = 0
  }

  # Network
  network_adapters {
    network      = var.network
    network_card = "vmxnet3"
  }

# ISOs — IDE for reliable EFI boot
  cdrom_type = "ide"
  iso_paths = [
    var.iso_path,
    "[] /vmimages/tools-isoimages/windows.iso"
  ]


  # Floppy — autounattend.xml 
  floppy_files = [
    "answer-files/autounattend.xml"
  ]

cd_files = [
  "Answer-files/AirwatchAgent.msi",
  "Answer-files/enroll-ws1.ps1",
  "answer-files/setupcomplete.ps1",
  "Answer-files/Windows_11.xml"
]
cd_label = "PACKER"

 
  # WinRM
  communicator   = "winrm"
  winrm_username = var.winrm_username
  winrm_password = var.winrm_password
  winrm_use_ssl  = false
  winrm_insecure = true
  winrm_timeout  = "6h"

  ip_wait_timeout   = "45m"
  ip_settle_timeout = "10s"

  # Boot — navigate EFI boot menu to CD-ROM (2x down + enter)
  boot_order   = "cdrom,disk,floppy"
  boot_wait    = "1s"
  boot_command = ["<down><wait1><down><wait1><enter>"]

  # Packer waits until the VM shuts itself down (done by osot-finalize.ps1)
  # No shutdown_command — the VM shuts itself down after MDM finalize
  shutdown_command = "echo 'VM shuts itself down via MDM finalize'"
  shutdown_timeout = "3h"

  # Snapshot and template after shutdown
  create_snapshot     = true
  snapshot_name       = "final-optimized"
  convert_to_template = true
}


build {
  sources = ["source.vsphere-iso.win11"]

  # Step 1: Wait for first restart after Windows setup
  provisioner "windows-restart" {
    restart_timeout = "20m"
  }

  # Step 2: Install Hub and enroll in MDM
  # After this point MDM takes over — Packer releases the VM
  provisioner "powershell" {
    script           = "Answer-files/enroll-ws1.ps1"
    execution_policy = "bypass"
    # Exit codes: 0=ok, 1=non-fatal, 3010=reboot required, 1641=reboot initiated
    valid_exit_codes = [0, 1, 3010, 1641]
  }

  # Step 3: Packer waits here until the VM shuts itself down
  # The VM is shut down by osot-finalize.ps1 when MDM is done
  # No further provisioners needed — MDM handles the rest including reboots
}
