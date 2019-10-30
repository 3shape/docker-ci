# The psake module is needed to run tests and publish the module to powershell gallery.
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name psake -MinimumVersion 4.9.0 -Repository "PSGallery" -Scope CurrentUser -Force
Install-Module -Name pester -MinimumVersion 4.9.0 -Repository "PSGallery" -Scope CurrentUser -Force
Install-Module -Name PSCodeCovIo -MinimumVersion 1.0.1 -Repository "PSGallery" -Scope CurrentUser -Force
