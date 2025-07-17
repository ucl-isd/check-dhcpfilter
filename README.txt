enum-dhcpreservation.ps1

====

SolarWinds IPAM is able to create/update reservations that are stored in AD DHCP.

For client's DHCP requests to be visible to the AD DHCP service, their MAC addresses need to be included in the DHCP Filter allow List.

To interrogate/update the list requires this PowerShell module to be loaded:
DhcpServer

Command to retrieve the list is:
Get-DhcpServerv4Filter -ComputerName dhcp-win01

The user performing the query/update needs to be a member (nested or otherwise) of the group:
rg-dhcp-win-admin

----

The script enumerates the reservations that have been allocated to scopes prefixed with "AudioVisual".
Any MAC addresses from these reservations that are not already in the DHCP Filter are added.

This operation is performed against both the AD DHCP servers:
dhcp-win01.ac.ucl.ac.uk
dhcp-win02.ad.ucl.ac.uk

----

This script can be run on a D@U Mgmt session (the PowerShell module is already present on these systems).
