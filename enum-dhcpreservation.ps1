# enum-dhcpreservation.ps1
#							Mar 2025 Bri

# Requires the DhcpServer module
# => Run on a D@U Mgmt server

# Reads all DHCP reservations for Audiovisual subnets and updates the DHCP allow list to include all MAC addresses

function update_allow {
	param (
		$srv = "dhcp-win01"
	)

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

}

# Is this necessary for reservation replication?
#$srv = "dhcp-win01"
#Invoke-DhcpServerv4FailoverReplication -ComputerName $srv

# Need to update the allow list on each AD DHCP server directly
update_allow "dhcp-win01"
update_allow "dhcp-win02"
