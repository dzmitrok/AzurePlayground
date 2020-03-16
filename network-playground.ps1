$NorthVMSubnetName = 'NorthVMSubnet'
$NorthVNetName = 'NorthVNet'
$NorthGWPubIPName = 'North_GW_Public_IP'
$NorthGWConfigName = 'NorthGWConfig'
$NorthGWName = 'NorthGW'
$NorthGWConnectionName = 'NorthToWest'
$NorthVMSubnet = New-AzVirtualNetworkSubnetConfig -Name $NorthVMSubnetName -AddressPrefix 10.10.10.0/26
$NorthGWSubnet = New-AzVirtualNetworkSubnetConfig -Name GatewaySubnet -AddressPrefix 10.10.10.64/26
$NorthVNet = New-AzVirtualNetwork -ResourceGroupName North -Name $NorthVNetName -Location NorthEurope -AddressPrefix 10.10.10.0/25 -Subnet $NorthVMSubnet,$NorthGWSubnet
$NorthVNSubnet = Get-AzVirtualNetworkSubnetConfig -Name GatewaySubnet -VirtualNetwork $NorthVNet
$NorthGWPubIP = New-AzPublicIpAddress -Name $NorthGWPubIPName -ResourceGroupName North -Location NorthEurope -AllocationMethod Dynamic
$NorthGWConfig = New-AzVirtualNetworkGatewayIpConfig -Name $NorthGWConfigName -SubnetId $NorthVNSubnet.Id -PublicIpAddressId $NorthGWPubIP.Id
New-AzVirtualNetworkGateway -Name $NorthGWName -ResourceGroupName North -Location NorthEurope -IpConfigurations $NorthGWConfig  -GatewayType Vpn -VpnType RouteBased -GatewaySku Basic
New-AzVirtualNetworkGatewayConnection -Name $NorthGWConnectionName -ResourceGroupName North -Location NorthEurope -VirtualNetworkGateway1 $NorthGW -VirtualNetworkGateway2 $WestGW -ConnectionType Vnet2Vnet -SharedKey 'Tomato$4'

$WestVMSubnetName = 'WestVMSubnet'
$WestVNetName = 'WestVNet'
$WestGWPubIPName = 'West_GW_Public_IP'
$WestGWConfigName = 'WestGWConfig'
$WestGWName = 'WestGW'
$WestGWConnectionName = 'WestToNorth'
$WestVMSubnet = New-AzVirtualNetworkSubnetConfig -Name $WestVMSubnetName -AddressPrefix 10.10.10.128/26
$WestGWSubnet = New-AzVirtualNetworkSubnetConfig -Name GatewaySubnet -AddressPrefix 10.10.10.192/26
$WestVNet = New-AzVirtualNetwork -ResourceGroupName West -Name $WestVNetName -Location WestEurope -AddressPrefix 10.10.10.128/25 -Subnet $WestVMSubnet,$WestGWSubnet
$WestVNSubnet = Get-AzVirtualNetworkSubnetConfig -Name GatewaySubnet -VirtualNetwork $WestVNet
$WestGWPubIP = New-AzPublicIpAddress -Name $WestGWPubIPName -ResourceGroupName West -Location WestEurope -AllocationMethod Dynamic
$WestGWConfig = New-AzVirtualNetworkGatewayIpConfig -Name $WestGWConfigName -SubnetId $WestVNSubnet.Id -PublicIpAddressId $WestGWPubIP.Id
New-AzVirtualNetworkGateway -Name $WestGWName -ResourceGroupName West -Location WestEurope -IpConfigurations $WestGWConfig  -GatewayType Vpn -VpnType RouteBased -GatewaySku Basic
New-AzVirtualNetworkGatewayConnection -Name $WestGWConnectionName -ResourceGroupName West -Location WestEurope -VirtualNetworkGateway1 $WestGW -VirtualNetworkGateway2 $NorthGW -ConnectionType Vnet2Vnet -SharedKey 'Tomato$4'