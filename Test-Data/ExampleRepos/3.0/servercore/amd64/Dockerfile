  # escape=`

<<<<<<< HEAD
FROM ubuntu:18.04
=======
# Installer image
FROM artifactorydk.3shape.local/threeshapedocker/threeshape.servercore:ltsc2019-servercore-amd64

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Retrieve .NET Core Runtime
# Configure web servers to bind to port 80 when present
ENV ASPNETCORE_URLS=http://+:80 `
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true `
    DOTNET_VERSION=3.0.0

RUN Invoke-WebRequest -OutFile dotnet.zip https://dotnetcli.blob.core.windows.net/dotnet/Runtime/$Env:DOTNET_VERSION/dotnet-runtime-$Env:DOTNET_VERSION-win-x64.zip; `
    $dotnet_sha512 = '9cab40057badcad236cd4855fcccb2acab150fa85c26b9c794f1eeab28c6ed5f0e338da5dec0ab4a8ba3a1af5f0feada987bae0d456dacef6858736a6033f4c5'; `
    if ((Get-FileHash dotnet.zip -Algorithm sha512).Hash -ne $dotnet_sha512) { `
        Write-Host 'CHECKSUM VERIFICATION FAILED!'; `
        exit 1; `
    }; `
    `
    Expand-Archive dotnet.zip -DestinationPath \"C:/Program Files/dotnet\"; `
    Remove-Item -Force dotnet.zip

RUN $AddedLocation =\"C:/Program Files/dotnet\"; `
    $Reg = \"Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment\"; `
    $OldPath = (Get-ItemProperty -Path "$Reg" -Name PATH).Path; `
    $NewPath= $OldPath + ’;’ + $AddedLocation; `
    Set-ItemProperty -Path "$Reg" -Name PATH –Value $NewPath
>>>>>>> parent of 1cc0e27... Format-DockerTag requires ContextRoot (#28)

