#Requires -Version 6
# The psake module is needed to run tests and publish the module to powershell gallery.
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Force -Name psake -MinimumVersion 4.9.0 -Repository "PSGallery"
Install-Module -Force -Name pester -RequiredVersion 4.9.0 -Repository "PSGallery"
Install-Module -Force -Name PSCodeCovIo -MinimumVersion 1.0.1 -Repository "PSGallery"
