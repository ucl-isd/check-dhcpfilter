# check-dhcpfilter

## Overview

`enum-dhcpreservation.ps1` is a PowerShell script that synchronises the DHCP Filter allow list on Active Directory (AD) DHCP servers with the MAC addresses found in DHCP reservations for **AudioVisual** subnets.

### Background

- **SolarWinds IPAM** can create and update DHCP reservations stored in AD DHCP.
- For a client device's DHCP requests to be served by the AD DHCP service, its MAC address must appear on the **DHCP Filter allow list**.
- This script automates the process of checking all AudioVisual-scope reservations and adding any missing MAC addresses to that allow list.

---

## Prerequisites

| Requirement | Detail |
|---|---|
| PowerShell module | `DhcpServer` (pre-installed on D@U Management servers) |
| Run environment | A D@U Mgmt session, or any system that has the `DhcpServer` module available |
| Permissions | The executing account must be a member (direct or nested) of **`ag-dhcp-win-admin`** |

---

## How the Script Works

The script defines a single function, `update_allow`, and then calls it once for each of the two AD DHCP servers.

### `update_allow` function

```
update_allow [-srv <server-name>]
```

| Step | What happens |
|---|---|
| 1 | Retrieves the full DHCP Filter list from the target server (`Get-DhcpServerv4Filter`). |
| 2 | Retrieves all DHCPv4 scopes from the target server (`Get-DhcpServerv4Scope`). |
| 3 | Filters those scopes to only those whose **Name** starts with `AudioVisual`. |
| 4 | Enumerates every DHCP reservation within those scopes (`Get-DhcpServerv4Reservation`). |
| 5 | For each reservation, checks whether its MAC address (`ClientId`) already exists in the filter list. |
| 6 | **If the MAC is already listed** – records the current list value on the reservation object (no change made). |
| 7 | **If the MAC is not listed** – prints `Allow: <MAC>` to the console and adds the MAC to the **Allow** filter list (`Add-DhcpServerv4Filter`), using the reservation's `Name` field as the description. |

### Server targets

The function is called for both AD DHCP servers:

```powershell
update_allow "dhcp-win01"   # dhcp-win01.ad.ucl.ac.uk
update_allow "dhcp-win02"   # dhcp-win02.ad.ucl.ac.uk
```

---

## Usage

1. Open a PowerShell session on a D@U Mgmt server (the `DhcpServer` module is already present).
2. Run the script:

```powershell
.\enum-dhcpreservation.ps1
```

The script will output a line for each MAC address that is newly added to the allow list:

```
Allow: aa-bb-cc-dd-ee-ff
```

No output for a given MAC means it was already present in the filter.

---

## Permissions

| Group | Purpose |
|---|---|
| `ag-dhcp-win-admin` | Required to query and update the DHCP Filter allow list on AD DHCP servers |

---

## Notes

- The commented-out block at the bottom of the script (`Invoke-DhcpServerv4FailoverReplication`) would trigger replication between the failover pair. It is currently not used because the `update_allow` calls target each server individually, making explicit replication unnecessary in the current workflow.
- The script targets **DHCPv4** only.
