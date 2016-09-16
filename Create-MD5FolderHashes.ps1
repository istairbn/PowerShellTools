Function Create-MD5FolderHashes{
<#
    .Synopsis
    Creates a map of filenames and MD5 hashes - suitable for comparing 

    .Description
    This script takes a folder as an argument (as well as an optional substring filter) and creates a map of hashes and names. You can use this to compare file contents. 
    
    .Parameter FolderLocation
    The folder you wish to compare

    .Parameter Filter
    The substring you want to use as a filter - eg DLL 

    .Example
    Create-MD5FolderHashes -FolderLocation C:\Temp -Filter DLL 
#>
 
[CmdletBinding()]
Param(
[Parameter(Mandatory=$True)]
[ValidateScript({Test-Path $_ })]
[string[]]
$FolderLocation,

[Parameter(Mandatory=$False)]
[string]
$Filter
)

function md5hash($path)
{
    $fullPath = Resolve-Path $path
    $md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    $file = [System.IO.File]::Open($fullPath,[System.IO.Filemode]::Open, [System.IO.FileAccess]::Read)
    [System.BitConverter]::ToString($md5.ComputeHash($file))
    $file.Dispose()
}

$DLLS = Get-ChildItem $FolderLocation -Recurse -File | Where-Object {$_.Name -match "$Filter"}

$Collection = @{}

ForEach($DLL in $DLLS){
    $Value = md5hash -path $DLL.FullName
    $Collection.Add($DLL.Name,$Value)
}

Write-Output $Collection
}