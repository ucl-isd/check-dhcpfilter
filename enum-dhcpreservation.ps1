# enum-dhcpreservation.ps1
#							Mar 2025 Bri

# Requires the DhcpServer module
# => Run on a D@U Mgmt server

# Use this target for all DHCP operations
# (there is a way to make this the default for a group of cmdlets - but ...)
$srv = "dhcp-win01"


# Get all filtered addresses
$f = Get-DhcpServerv4Filter -ComputerName $srv

# Get all DHCP scopes
$scope = Get-DhcpServerv4Scope -ComputerName $srv

# Filter scopes
$s = $scope |? {$_.Name -match '^AudioVisual'}

# Get all reservations for the scopes
$r = $s | Get-DhcpServerv4Reservation -ComputerName $srv


# Check if MAC addresses are in the filter and add if not
$r |% {
	$i = $_
	$mac = $i.ClientId

	# Find matching entries
	$q = $f |? {$_.MacAddress -match $mac}

	if (@($q) -ne $null) {
		$i | Add-Member -Membertype NoteProperty -Name 'List' -Value $q.List
	} else {
		"Allow: $mac"
		Add-DhcpServerv4Filter -ComputerName $srv -List Allow -MacAddress $mac -Description $i.Name
	}
}

# Is this necessary for filter replication?
Invoke-DhcpServerv4FailoverReplication -ComputerName $srv

