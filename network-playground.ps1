$GWSharedKey = 'Tomato$4'
$VMlogin = 'dzmitrok'
$EmptySecurePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($VMlogin, $EmptySecurePassword)

$NorthVMSubnetName = 'NorthVMSubnet'
$NorthVNetName = 'NorthVNet'
$NorthGWPubIPName = 'North_GW_Public_IP'
$NorthVMPubIPName = 'North_VM_Public_IP'
$NorthGWConfigName = 'NorthGWConfig'
$NorthGWName = 'NorthGW'
$NorthGWConnectionName = 'NorthToWest'
$NorthNSGRuleSSHName = 'NorthNSGRuleSSH'
$NorthVMName = 'NorthVM'
#Create VM VNet  Config
$NorthVMSubnet = New-AzVirtualNetworkSubnetConfig -Name $NorthVMSubnetName -AddressPrefix 10.10.10.0/26
#Create VNet Gateway Config
$NorthGWSubnet = New-AzVirtualNetworkSubnetConfig -Name GatewaySubnet -AddressPrefix 10.10.10.64/26
#Create VNet
$NorthVNet = New-AzVirtualNetwork -ResourceGroupName North -Name $NorthVNetName -Location NorthEurope -AddressPrefix 10.10.10.0/25 -Subnet $NorthVMSubnet,$NorthGWSubnet
# Grab VNet conif
$NorthVNSubnet = Get-AzVirtualNetworkSubnetConfig -Name GatewaySubnet -VirtualNetwork $NorthVNet
# Create a VNet Gateway Public IP Address
$NorthGWPubIP = New-AzPublicIpAddress -Name $NorthGWPubIPName -ResourceGroupName North -Location NorthEurope -AllocationMethod Dynamic
# Create a VNet Gateway Config
$NorthGWConfig = New-AzVirtualNetworkGatewayIpConfig -Name $NorthGWConfigName -SubnetId $NorthVNSubnet.Id -PublicIpAddressId $NorthGWPubIP.Id
# Create a VNet Gateway
$NorthGW = New-AzVirtualNetworkGateway -Name $NorthGWName -ResourceGroupName North -Location NorthEurope -IpConfigurations $NorthGWConfig  -GatewayType Vpn -VpnType RouteBased -GatewaySku Basic

# Create a public IP address 
$NorthVMPubIP = New-AzPublicIpAddress -Name $NorthVMPubIPName -ResourceGroupName North -Location NorthEurope -AllocationMethod Dynamic
# Create an inbound network security group rule for port 22
$NorthNSGRuleSSH = New-AzNetworkSecurityRuleConfig -Name $NorthNSGRuleSSHName -Description "North VM port 22 Network security rule" `
-Protocol Tcp -Direction Inbound  -SourceAddressPrefix * -SourcePortRange * -DestinationPortRange 22  -DestinationAddressPrefix * -Access Allow -Priority 1000
# Create a network security group
$NorthNSG = New-AzNetworkSecurityGroup -ResourceGroupName North -Location NorthEurope -Name $NorthNSGRuleSSHName -SecurityRules $NorthNSGRuleSSH
#Create VM config
$NorthVMNic = New-AzNetworkInterface -Name $($NorthVMName+"Nic") -ResourceGroupName North -Location NorthEurope -SubnetId $NorthVNet.Subnets[0].id -PublicIpAddressId $NorthVMPubIP.Id -NetworkSecurityGroupId $NorthNSG.Id
#Create VM config
$NorthVMConfig = New-AzVMConfig -VMName $NorthVMName -VMSize "Standard_D1" | 
Set-AzVMOperatingSystem -Linux -ComputerName $NorthVMName -Credential $cred -DisablePasswordAuthentication | 
Set-AzVMSourceImage -PublisherName Debian -Offer Debian-11-daily -Skus 11 -Version "latest" |
Add-AzVMNetworkInterface -Id $NorthVMNic.Id
# Configure the SSH key
$sshPublicKey = cat D:\SkyDrive\Azure\xvazusa0000\xvazusa0000.pub
Add-AzVMSshPublicKey -VM $NorthVMConfig -KeyData $sshPublicKey -Path "/home/$VMlogin/.ssh/authorized_keys"
New-AzVM -ResourceGroupName North -Location NorthEurope -VM $NorthVMConfig




$WestVMSubnetName = 'WestVMSubnet'
$WestVNetName = 'WestVNet'
$WestGWPubIPName = 'West_GW_Public_IP'
$WestVMPubIPName = 'West_VM_Public_IP'
$WestGWConfigName = 'WestGWConfig'
$WestGWName = 'WestGW'
$WestGWConnectionName = 'WestToNorth'
$WestNSGRuleSSHName = 'WestNSGRuleSSH'
$WestVMName = 'WestVM'
#Create VM VNet  Config
$WestVMSubnet = New-AzVirtualNetworkSubnetConfig -Name $WestVMSubnetName -AddressPrefix 10.10.10.128/26
#Create VNet Gateway Config
$WestGWSubnet = New-AzVirtualNetworkSubnetConfig -Name GatewaySubnet -AddressPrefix 10.10.10.192/26
#Create VNet
$WestVNet = New-AzVirtualNetwork -ResourceGroupName West -Name $WestVNetName -Location WestEurope -AddressPrefix 10.10.10.128/25 -Subnet $WestVMSubnet,$WestGWSubnet
# Grab VNet conif
$WestVNSubnet = Get-AzVirtualNetworkSubnetConfig -Name GatewaySubnet -VirtualNetwork $WestVNet
# Create a VNet Gateway Public IP Address
$WestGWPubIP = New-AzPublicIpAddress -Name $WestGWPubIPName -ResourceGroupName West -Location WestEurope -AllocationMethod Dynamic
# Create a VNet Gateway Config
$WestGWConfig = New-AzVirtualNetworkGatewayIpConfig -Name $WestGWConfigName -SubnetId $WestVNSubnet.Id -PublicIpAddressId $WestGWPubIP.Id
# Create a VNet Gateway
$WestGW = New-AzVirtualNetworkGateway -Name $WestGWName -ResourceGroupName West -Location WestEurope -IpConfigurations $WestGWConfig  -GatewayType Vpn -VpnType RouteBased -GatewaySku Basic


New-AzVirtualNetworkGatewayConnection -Name $WestGWConnectionName -ResourceGroupName West -Location WestEurope -VirtualNetworkGateway1 $WestGW -VirtualNetworkGateway2 $NorthGW -ConnectionType Vnet2Vnet -SharedKey $GWSharedKey
New-AzVirtualNetworkGatewayConnection -Name $NorthGWConnectionName -ResourceGroupName North -Location NorthEurope -VirtualNetworkGateway1 $NorthGW -VirtualNetworkGateway2 $WestGW -ConnectionType Vnet2Vnet -SharedKey $GWSharedKey

# Create a public IP address 
$WestVMPubIP = New-AzPublicIpAddress -Name $WestVMPubIPName -ResourceGroupName West -Location WestEurope -AllocationMethod Dynamic
# Create an inbound network security group rule for port 22
$WestNSGRuleSSH = New-AzNetworkSecurityRuleConfig -Name $WestNSGRuleSSHName -Description "West VM port 22 Network security rule" `
-Protocol Tcp -Direction Inbound  -SourceAddressPrefix * -SourcePortRange * -DestinationPortRange 22  -DestinationAddressPrefix * -Access Allow -Priority 1000
# Create a network security group
$WestNSG = New-AzNetworkSecurityGroup -ResourceGroupName West -Location WestEurope -Name $WestNSGRuleSSHName -SecurityRules $WestNSGRuleSSH
#create VM Network interface
$WestVMNic = New-AzNetworkInterface -Name $($WestVMName+"Nic") -ResourceGroupName West -Location WestEurope -SubnetId $WestVNet.Subnets[0].id -PublicIpAddressId $WestVMPubIP.Id -NetworkSecurityGroupId $WestNSG.Id
#Create VM config
$WestvmConfig = New-AzVMConfig -VMName $WestVMName -VMSize "Standard_D1" | 
Set-AzVMOperatingSystem -Linux -ComputerName $WestVMName -Credential $cred -DisablePasswordAuthentication | 
Set-AzVMSourceImage -PublisherName Debian -Offer Debian-11-daily -Skus 11 -Version "latest" |
Add-AzVMNetworkInterface -Id $WestVMNic.Id
# Configure the SSH key
$sshPublicKey = cat D:\SkyDrive\Azure\xvazusa0000\xvazusa0000.pub
Add-AzVMSshPublicKey -VM $WestVMConfig -KeyData $sshPublicKey -Path "/home/$VMlogin/.ssh/authorized_keys"
New-AzVM -ResourceGroupName West -Location WestEurope -VM $WestVMConfig
