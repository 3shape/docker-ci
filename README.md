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
- Inspect (not implemented yet)

For each tasks there is a corresponding CmdLet:

- Invoke-DockerBuild
- Invoke-DockerTests
- Invoke-DockerLint
- Invoke-DockerLogin
- Invoke-DockerPull
- Invoke-DockerPush
- Invoke-DockerTag

To run, just do

```powershell
PS C:\docker> Invoke-DockerBuild .
```
and so on.


## Installation

```powershell
PS C:\docker> Install-Module Docker.Build -Repository PSGallery
```

## Example
In the following section we'll cover how to use the module to add testing and linting to an existing Dockerfile. I am assuming you repository looks like this at the moment:

```powershell
PS C:\docker> Get-Content .\Dockerfile
FROM ubuntu:18.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl=7.* ca-certificates=* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN update-ca-certificates

RUN curl -sL https://get.docker.com/ | sh

RUN curl -LO https://storage.googleapis.com/container-structure-test/v1.8.0/container-structure-test-linux-amd64 \
    && chmod +x container-structure-test-linux-amd64 \
    && mv container-structure-test-linux-amd64 /usr/local/bin/container-structure-test

VOLUME /configs

ENTRYPOINT [ "/usr/local/bin/container-structure-test" ]
```

### Buiding the Dockerfile
To build the Dockerfile, use the Invoke-DockerBuild CmdLet, like so:

```powershell
PS C:\docker> Invoke-DockerBuild . -ImageName structure

Dockerfile    : Dockerfile
ImageName     : structure
Registry      :
Tag           : latest
CommandResult : CommandResult
```
In this scenario, you will see the result of the execution which is a PSCustomObject that holds the command result and image name of the image you just created.

You can verify the existence of the image using `docker images`
```
PS C:\docker> docker images
```

This is fine when everything goes well. But it's not very practial for troubleshooting. It would be better, if we could get some feedback while on the go.
To see the output of the Docker command being run, use the `-PassThru` switch of the pertinent CmdLet.
For example:

```powershell
PS C:\docker> Invoke-DockerBuild . -ImageName structure -PassThru
```
which will yield output along these lines:

```powershell
Sending build context to Docker daemon   2.56kB

Step 1/8 : FROM ubuntu:18.04
 ---> 775349758637
Step 2/8 : SHELL ["/bin/bash", "-o", "pipefail", "-c"]
 ---> Using cache
 ---> b3d8c49615a7
Step 3/8 : RUN apt-get update     && apt-get install -y --no-install-recommends curl=7.* ca-certificates=*     && apt-get clean     && rm -rf /var/lib/apt/lists/*
 ---> Using cache
 ---> 9470f9c9ecea
Step 4/8 : RUN update-ca-certificates

 (snip)


Dockerfile    : Dockerfile
ImageName     : structure
Registry      :
Tag           : latest
CommandResult : CommandResult
```

Now, we get both the result and the output from the docker command.

In most cases you will want to store the result in a variable for further processing or output to a CI/CD pipeline.



# Development environment setup

* Install PowerShell Core 6.x latest
* Run `.\Install-Prerequisites.ps1`
