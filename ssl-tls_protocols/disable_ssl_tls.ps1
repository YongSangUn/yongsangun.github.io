$protocalPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"

$allProtocals = @("SSL 2.0", "SSL 3.0", "TLS 1.0", "TLS 1.1")
$endpoints = @("Server", "Client")

foreach ($p in $allProtocals) {
    foreach ($e in $endpoints) {
        $path = "$protocalPath\$p\$e"
        New-Item $path -Force | Out-Null
        New-ItemProperty -Path $path -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null
        New-ItemProperty -Path $path -name 'DisabledByDefault' -value 1 -PropertyType 'DWord' -Force | Out-Null
    }
    Write-Host "$p has been disabled."
}
