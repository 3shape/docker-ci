#Requires -Version 6
# The psake module is needed to run tests and publish the module to powershell gallery.
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name -Force psake -MinimumVersion 4.9.0 -Repository "PSGallery"
Install-Module -Name -Force pester -MinimumVersion 4.9.0 -Repository "PSGallery"
Install-Module -Name -Force PSCodeCovIo -MinimumVersion 1.0.1 -Repository "PSGallery"
