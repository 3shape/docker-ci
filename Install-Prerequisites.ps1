#Requires -Version 6
# The psake module is needed to run tests and publish the module to powershell gallery.
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name psake -MinimumVersion 4.9.0 -Repository "PSGallery" -Force
Install-Module -Name pester -MinimumVersion 4.9.0 -Repository "PSGallery" -Force
Install-Module -Name PSCodeCovIo -MinimumVersion 1.0.1 -Repository "PSGallery" -Force

if ($env:TRAVIS -eq 'true') {
    if (Test-Path -Path "$env:HOME/.dotnet/tools/dotnet-gitversion") {
        Write-Host "GitVersion already installed"
    } else {
        & dotnet tool install --global GitVersion.Tool --version 5.1.1
    }
}
