workflow vSphereMgmt {

#Sample workflow for managing vmware guest machines managed by vSphere

param (
[parameter(Mandatory=$true)]
[String]$GuestVM1,

[parameter(Mandatory=$true)]
[String]$GuestVM2,

[parameter(Mandatory=$true)]
[String]$GuestVM3,

[parameter (Mandatory=$true)]
[string]$VIServer
)

$Connection = Get-AutomationConnection -Name VIServer
$VIServer = $VIServer
$VIUser = $Connection.Username
$VIPassword = $Connection.Password
$ModuleProxy = Get-AutomationVariable -Name ModuleProxy
$VIHost = Get-AutomationVariable -Name VIHost

#Add VI PSSnapin
inlinescript {
Add-PSSnapin -Name "VMware.VimAutomation.Core"
} -pscomputername $ModuleProxy

#Connect to vSphere 5.0 Server.
inlinescript {
Connect-VIServer -Server $Using:VIServer -User $Using:VIUser -Password $Using:VIPassword
} -pscomputername $ModuleProxy 

#Create new Resource Pool.
inlinescript {
New-ResourcePool -Name "Automation" -Location $Using:VIHost
} -pscomputername $ModuleProxy

#Create new VMs on host.
inlinescript {
New-VM -VMHost $Using:VIHost -Name $Using:GuestVM1 -Datastore "datastore1" -ResourcePool "Automation" -MemoryGB 1
New-VM -VMHost $Using:VIHost -Name $Using:GuestVM2 -Datastore "datastore1" -ResourcePool "Automation"
New-VM -VMHost $Using:VIHost -Name $Using:GuestVM3 -Datastore "datastore1" -ResourcePool "Automation"
} -pscomputername $ModuleProxy

#Snapshot VM.
inlinescript {
$snap = $Using:GuestVM1+"SNAP"
New-Snapshot -VM $Using:GuestVM1 -Description "SMA Generated Snapshot" -Name $snap
} -pscomputername $ModuleProxy

#Add virtual 1GB disk.
inlinescript {
New-HardDisk -Datastore "datastore1" -VM $Using:GuestVM1 -CapacityGB 1 
} -pscomputername $ModuleProxy

inlinescript {
#Add cd/dvd drive, mount WS2008R2 iso.
New-CDDrive -VM $Using:GuestVM1 -IsoPath "[datastore1] ISO Images/Windows Server 2008 R2/en_windows_server_2008_r2_serverenterprise_x64_VL.iso" -StartConnected
} -pscomputername $ModuleProxy

#Start VM.
inlinescript {
Start-VM -VM $Using:GuestVM1
Start-VM -VM $Using:GuestVM2
Start-VM -VM $Using:GuestVM3
} -pscomputername $ModuleProxy

}