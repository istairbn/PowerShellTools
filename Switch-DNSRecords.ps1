Function Switch-DNSRecords{
<#
    .Synopsis
    Switches the IP addreess for a DNS Alias entry - will not allow creation.  

    .Description
    This script takes an existing CNAME record and replaces sets a new IP address. Designed for use in DR scenarios
    
    .Parameter DNSServer
    The DNS Server you are amending. 

    .Parameter DNSZone
    The DNS Zone you are amending. 

    .Parameter recordName
    The DNS Alias you are amending

    .Parameter recordType
    The type of DNS record. Current set: ("CNAME")

    .Parameter recordAddress
    The IP address you are linking to the record

    .Example
    Switch-DNSRecords -DNSServer ADNSServer -DNSZone ADNSZone -recordName MyDnsAlias -recordType CNAME -recordAddress 127.0.0.1
#>
    [CmdletBinding(SupportsShouldProcess=$True)]
    Param(
        [Parameter(Mandatory=$False)]
        [string]
	    $DNSServer = "BXTS111D31",

        [Parameter(Mandatory=$True)]
        [string]
	    $DNSZone = "eu.rabodev.com",

        [Parameter(Mandatory=$True)]
        [string]
        $recordName,

        [Parameter(Mandatory=$False)]
        [ValidateSet("CNAME")]
        [string]
	    $recordType = "CNAME",

        [Parameter(Mandatory=$True)]
        [string]
	    $recordAddress
    )

        If(!(Test-Connection -ComputerName $recordAddress -Quiet)){
            Write-Error "`n$recordAddress does not exist!`n"
            Exit 1
        }

	    $cmdDelete = "dnscmd $DNSServer /RecordDelete $DNSZone $recordName $recordType /f"
	    $cmdAdd = "dnscmd $DNSServer /RecordAdd $DNSZone $recordName $recordType $recordAddress"

	    Write-Output "Running the following command: $cmdDelete"
	    Invoke-Expression $cmdDelete

	    Write-Output "Running the following command: $cmdAdd"
	    Invoke-Expression $cmdAdd
}
