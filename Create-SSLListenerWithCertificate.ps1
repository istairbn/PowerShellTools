[CmdletBinding(SupportsShouldProcess=$True)]
<#
    .Synopsis
    Given a PFX file, will import the certificate and create an HTTPS listener

    .Description
    This script will take a pfx certificate and a password as arguments. It will add the certificate to the correct store
    and create the listener

    .Parameter CertificatePath
    Path to the certificate. Must be a PFX

    .Parameter Password
    The Password of the PFX file
    
    .Example
    .\Create-SSLListenerWithCertificate.ps1 -CertificatePath Hostname.contoso.com -Password MySecurePassword
#>
Param(
[parameter(Mandatory=$true)]
[ValidateScript({((Test-Path $_) -and($_ -match ".pfx") )})]
[String]
$CertificatePath = "Hostname.contoso.com",

[parameter(Mandatory=$false)]
[string]
$password = "password"
)

#Import Certificate
$mypwd = ConvertTo-SecureString -String $password -Force –AsPlainText
$Importing = Import-PfxCertificate -FilePath $CertificatePath -CertStoreLocation Cert:\LocalMachine\My\ -Password $mypwd -Exportable

$Thumbprint = $Importing.Thumbprint
$SubjectName = $Importing.SubjectName.Name.Split(",")[0].split("=")[1]

$WhoAmI = "$env:COMPUTERNAME.$Env:USERDNSDOMAIN"

If($WhoAmI -notmatch $SubjectName){
    Write-Error "$WhoAmI does not match $SubjectName"
    Exit 1
}

#Create WinRM Https Listener
$WinrmCreate = "winrm create --% winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=`"$SubjectName`";CertificateThumbprint=`"$Thumbprint`"}"
Invoke-Expression $WinrmCreate