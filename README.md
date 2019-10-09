[![Build status](https://api.travis-ci.com/3shapeAS/dockerbuild-pwsh.svg?branch=master)](https://travis-ci.com/3shapeAS/dockerbuild-pwsh)

# dockerbuild-pwsh

PowerShell Core script to build and test Docker images.
The module comes with CmdLets to perform the most commonly used tasks with regards to building docker images:

- Build
- Test (not implemented yet)
- Lint
- Tag
- Push (not implemented yet)

For each tasks there is a corresponding CmdLet, for instance Invoke-DockerBuild to build an image.

To run, just do

```pwsh
PS> Invoke-DockerBuild .
```
and so on.

# Development environment setup

* Install PowerShell Core 6.x latest
* Run `.\Install-Prerequisites.ps1`
