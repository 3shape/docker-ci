[![Build status](https://api.travis-ci.com/3shapeAS/dockerbuild-pwsh.svg?branch=master)](https://travis-ci.com/3shapeAS/dockerbuild-pwsh)
[![codecov](https://codecov.io/gh/3shapeAS/dockerbuild-pwsh/branch/master/graph/badge.svg)](https://codecov.io/gh/3shapeAS/dockerbuild-pwsh)
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

## Examples
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

### Building an image from Dockerfile
To build an image based on a Dockerfile, use the Invoke-DockerBuild CmdLet, like so:

```powershell
PS C:\docker> Invoke-DockerBuild . -ImageName structure
Sending build context to Docker daemon  4.608kB

Step 1/8 : FROM ubuntu:18.04
 ---> 775349758637
Step 2/8 : SHELL ["/bin/bash", "-o", "pipefail", "-c"]
 ---> Using cache
 ---> b3d8c49615a7
Step 3/8 : RUN apt-get update     && apt-get install -y --no-install-recommends curl=7.* ca-certificates=*     && apt-get clean     && rm -rf /var/lib/apt/lists/*
 ---> Using cache
 ---> 9470f9c9ecea
Step 4/8 : RUN update-ca-certificates
 ---> Using cache
 ---> 80853c222946
Step 5/8 : RUN curl -sL https://get.docker.com/ | sh
 ---> Using cache
 ---> af17b9b8fb1b
Step 6/8 : RUN curl -LO https://storage.googleapis.com/container-structure-test/v1.8.0/container-structure-test-linux-amd64     && chmod +x container-structure-test-linux-amd64     && mv container-structure-test-linux-amd64 /usr/local/bin/container-structure-test
 ---> Using cache
 ---> bea1dca8e10e
Step 7/8 : VOLUME /configs
 ---> Using cache
 ---> 97e90bf8481b
Step 8/8 : ENTRYPOINT [ "/usr/local/bin/container-structure-test" ]
 ---> Using cache
 ---> 6b9746ab76d8
Successfully built 6b9746ab76d8
Successfully tagged structure:latest
SECURITY WARNING: You are building a Docker image from Windows against a non-Windows Docker host. All files and directories added to build context will have '-rwxr-xr-x' permissions. It is recommended to double check and reset permissions for sensitive files and directories.

Dockerfile    : Dockerfile
ImageName     : structure
Registry      :
Tag           : latest
CommandResult : CommandResult
```

In this scenario, you will see the both the output from Docker and the result of the execution which is a PSCustomObject that holds:

- The path to the Dockerfile being used as the basis for the image.
- The name of the image being produced.
- The registry (if unset defaults to Docker's default registry)
- The command result object which has more detailed information about the execution.

In most cases you will want to store the result in a variable for further processing or output to a CI/CD pipeline, like so:

```powershell
PS C:\docker> Invoke-DockerBuild . -ImageName structure
Sending build context to Docker daemon  4.608kB

Step 1/8 : FROM ubuntu:18.04
 ---> 775349758637
Step 2/8 : SHELL ["/bin/bash", "-o", "pipefail", "-c"]
 ---> Using cache
 ---> b3d8c49615a7
Step 3/8 : RUN apt-get update     && apt-get install -y --no-install-recommends curl=7.* ca-certificates=*     && apt-get clean     && rm -rf /var/lib/apt/lists/*
 ---> Using cache
 ---> 9470f9c9ecea
Step 4/8 : RUN update-ca-certificates
 ---> Using cache
 ---> 80853c222946
Step 5/8 : RUN curl -sL https://get.docker.com/ | sh
 ---> Using cache
 ---> af17b9b8fb1b
Step 6/8 : RUN curl -LO https://storage.googleapis.com/container-structure-test/v1.8.0/container-structure-test-linux-amd64     && chmod +x container-structure-test-linux-amd64     && mv container-structure-test-linux-amd64 /usr/local/bin/container-structure-test
 ---> Using cache
 ---> bea1dca8e10e
Step 7/8 : VOLUME /configs
 ---> Using cache
 ---> 97e90bf8481b
Step 8/8 : ENTRYPOINT [ "/usr/local/bin/container-structure-test" ]
 ---> Using cache
 ---> 6b9746ab76d8
Successfully built 6b9746ab76d8
Successfully tagged structure:latest
SECURITY WARNING: You are building a Docker image from Windows against a non-Windows Docker host. All files and directories added to build context will have '-rwxr-xr-x' permissions. It is recommended to double check and reset permissions for sensitive files and directories.
```
in which case you will only see the output from Docker, the result object is stored in $result.

You can verify the existence of the image you just created using `docker images`
```
PS C:\docker> docker images
```

If you want less output, use `-Quiet` switch to output only the final result of the command. Combined with storing the result in a variable, this will give a completely silent execution of the CmdLet.

### Disabling verbose output
You can also set the enviromenment variable `DOCKER_POSH_QUIET_MODE` to the desired setting for the `-Quiet` switch so you don't have to set it for each invocation of a cmdlet that supports it.

### Linting a Dockerfile
An important aspect of writing quality Docker images is to try and learn from the best in the community. To this end, we provide a convenient way to run `hadolint` against a Dockerfile. Hadolint is a 3rd party component that scans a dockerfile and produces linted output. You can find the hadolint project here: https://github.com/hadolint/hadolint

Here's how to use the linter via a CmdLet:

```powershell
PS C:\docker> $result = Invoke-DockerLint .\Dockerfile
1: FROM ubuntu:18.04
2:
3: SHELL ["/bin/bash", "-o", "pipefail", "-c"]
4:
5: RUN apt-get update \
6:     && apt-get install -y --no-install-recommends curl=7.* ca-certificates=* \
7:     && apt-get clean \
8:     && rm -rf /var/lib/apt/lists/*
9:
10: RUN update-ca-certificates
11:
12: RUN curl -sL https://get.docker.com/ | sh
13:
14: RUN curl -LO https://storage.googleapis.com/container-structure-test/v1.8.0/container-structure-test-linux-amd64 \
15:     && chmod +x container-structure-test-linux-amd64 \
16:     && mv container-structure-test-linux-amd64 /usr/local/bin/container-structure-test
17:
18: VOLUME /configs
19:
20: ENTRYPOINT [ "/usr/local/bin/container-structure-test" ]
```

This Dockerfile in particular has no linting remarks, so it is just output in its entirety with line numbers. Imagine I omitted the instruction in line 3 on how to deal with commands that fail in a piped execution and run the linting again:

```powershell
PS C:\docker> $result = Invoke-DockerLint .\Dockerfile
1: FROM ubuntu:18.04
2:
3: RUN apt-get update \
4:     && apt-get install -y --no-install-recommends curl=7.* ca-certificates=* \
5:     && apt-get clean \
6:     && rm -rf /var/lib/apt/lists/*
7:
8: RUN update-ca-certificates
9:
DL4006 Set the SHELL option -o pipefail before RUN with a pipe in it
10: RUN curl -sL https://get.docker.com/ | sh
11:
12: RUN curl -LO https://storage.googleapis.com/container-structure-test/v1.8.0/container-structure-test-linux-amd64 \
13:     && chmod +x container-structure-test-linux-amd64 \
14:     && mv container-structure-test-linux-amd64 /usr/local/bin/container-structure-test
15:
16: VOLUME /configs
17:
18: ENTRYPOINT [ "/usr/local/bin/container-structure-test" ]
```

Now, the linter is no longer happy and it has added a remark just above line 10 instructing us on how to fix the problem. The first part of the message is a unique lint rule id that can be used to find the lint rationale and in-depth explanation on https://github.com/hadolint/hadolint.

This concludes the examples on linting. Whilst linting can help you improve parts of your Docker-style and quality of the images, it is no substitute for real testing.

### Testing a docker image
We provide testing of docker images using Google's Container Structure framework (https://github.com/GoogleContainerTools/container-structure-test).

To run tests, you first define them in .yml configs. Then you build the image the image you want to test, and then finally you run the tests.

So let's start by building an image called `structure`

```powershell
PS C:\docker> Invoke-DockerBuild . -Quiet -ImageName structure

Dockerfile    : Dockerfile
ImageName     : structure
Registry      :
Tag           : latest
CommandResult : CommandResult
```

Then, we define a test to check if the correct binary was produced and placed in accordance with the documentation at https://github.com/GoogleContainerTools/container-structure-test.

The config file gcs-commands.yml looks like this:

```yml
schemaVersion: "2.0.0"

commandTests:
  - name: "say hello world"
    command: "bash"
    args:
      - -c
      - |
        echo hello &&
        echo world
    exitCode: 0
    expectedOutput: ["hello", "world"]
```

And you run the tests like this:

```powershell
PS C:\docker> $result = Invoke-DockerTests -ImageName 3shape/containerized-structure-test -ConfigFiles gcs-commands.yml
@{Pass=1; Fail=0; Total=1; Results=System.Object[]}
PS C:\docker> $result

TestResult                                          TestReportPath            CommandResult ImageName
----------                                          --------------            ------------- ---------
@{Pass=1; Fail=0; Total=1; Results=System.Object[]} C:\docker\testreport.json CommandResult 3shape/containerized-structure-test
```

This concludes the section with examples. Let us know if there is something missing, that is not clear from the documentation.

# Development environment setup

* Install PowerShell Core 6.x latest
* Run `.\Install-Prerequisites.ps1`
