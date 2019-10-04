# The psake module is needed to run tests and publish the module to powershell gallery.
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name psake -RequiredVersion 4.8.0 -Repository "PSGallery"
Install-Module -Name pester -RequiredVersion 4.8.0 -Repository "PSGallery"


