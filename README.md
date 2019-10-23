[![Build status](https://api.travis-ci.com/3shapeAS/dockerbuild-pwsh.svg?branch=master)](https://travis-ci.com/3shapeAS/dockerbuild-pwsh)
[![PS Gallery](https://img.shields.io/badge/install-PS%20Gallery-blue.svg)](https://www.powershellgallery.com/packages/Docker.Build/)

# dockerbuild-pwsh

PowerShell Core script to build and test Docker images.
The module comes with CmdLets to perform the most commonly used tasks with regards to building docker images:

- Build
- Tests
- Lint
- Login
- Pull
- Push
- Tag

For each tasks there is a corresponding CmdLet:

- Invoke-DockerBuild
- Invoke-DockerTests
- Invoke-DockerLint
- Invoke-DockerLogin
- Invoke-DockerPull
- Invoke-DockerPush
- Invoke-DockerTag

To run, just do

```pwsh
PS> Invoke-DockerBuild .
```
and so on.

# Development environment setup

* Install PowerShell Core 6.x latest
* Run `.\Install-Prerequisites.ps1`
