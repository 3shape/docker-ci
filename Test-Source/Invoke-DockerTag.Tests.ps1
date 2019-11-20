Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/Docker.Build.Tests.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1

. "$PSScriptRoot\..\Source\Private\Invoke-Command.ps1"

Describe 'Tag docker images' {

    BeforeEach {
        Initialize-MockReg
        Mock -CommandName "Invoke-Command" $Global:CodeThatReturnsExitCodeZero -Verifiable -ModuleName $Global:ModuleName
    }

    AfterEach {
        Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $Global:ModuleName
    }

    Context 'Docker tags public registry images' {

        It 'tags image by image name with image name' {
            Invoke-DockerTag -ImageName 'oldname' -NewImageName 'newimage'
            $result = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag oldname:latest newimage:latest"
        }

        It 'tags image by image name and tag with new image name and tag' {
            Invoke-DockerTag -ImageName 'oldname' -Tag 'pester' -NewImageName 'newimage' -NewTag 'pester'
            $result = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag oldname:pester newimage:pester"
        }

        It 'tags image by image name and tag, with new image name' {
            Invoke-DockerTag -ImageName 'oldname' -Tag 'source' -NewImageName 'newimage'
            $result = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag oldname:source newimage:latest"
        }

        It 'tags image by image name with new image name and tag' {
            Invoke-DockerTag -ImageName 'oldname' -NewImageName 'newimage' -NewTag 'target'
            $result = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag oldname:latest newimage:target"
        }
    }

    Context 'Docker tags private registry images' {

        It 'tags private image as public image with image name only' {
            Invoke-DockerTag -Registry 'artifactoryfqdn' -ImageName 'oldname' -NewImageName 'newimage'
            $result = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag artifactoryfqdn/oldname:latest newimage:latest"
        }

        It 'tags private image as public image with image name and $null registry value' {
            Invoke-DockerTag -Registry 'artifactoryfqdn' -ImageName 'oldname' -NewImageName 'newimage' -NewRegistry $null
            $result = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag artifactoryfqdn/oldname:latest newimage:latest"
        }

        It 'tags private docker image as public docker image with image name and tag' {
            Invoke-DockerTag -Registry 'artifactoryfqdn' -ImageName 'oldname' -NewImageName 'newimage' -NewTag 'newtag'
            $result = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag artifactoryfqdn/oldname:latest newimage:newtag"
        }

        It 'tags private docker image with tag as public docker image with image name only' {
            Invoke-DockerTag -Registry 'artifactoryfqdn' -ImageName 'oldname' -Tag 'nomansland' -NewImageName 'newimage'
            $result = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag artifactoryfqdn/oldname:nomansland newimage:latest"
        }

        It 'tags private docker image with tag as public docker image with image name and tag' {
            Invoke-DockerTag -Registry 'artifactoryfqdn' -ImageName 'oldname' -Tag 'nomansland' -NewImageName 'newimage' -NewTag 'newtag'
            $result = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag artifactoryfqdn/oldname:nomansland newimage:newtag"
        }

        It 'tags private docker image with tag as public docker image with image name, tag and empty registry' {
            Invoke-DockerTag -Registry 'artifactoryfqdn' -ImageName 'oldname' -Tag 'nomansland' -NewImageName 'newimage' -NewTag 'newtag' -NewRegistry ''
            $result = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag artifactoryfqdn/oldname:nomansland newimage:newtag"
        }

        It 'tags private docker image as private docker image with image name only' {
            Invoke-DockerTag -Registry 'artifactoryfqdn/docker-repo' -ImageName 'oldname' -NewRegistry 'dockerhub.com:5999' -NewImageName 'newimage'
            $result = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag artifactoryfqdn/docker-repo/oldname:latest dockerhub.com:5999/newimage:latest"
        }

        It 'tags private docker image as private docker image with image name and tag' {
            Invoke-DockerTag -Registry 'artifactoryfqdn' -ImageName 'oldname' -NewRegistry 'dockerhub.com:5999/docker-repo' -NewImageName 'newimage' -NewTag 'newtag'
            $result = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag artifactoryfqdn/oldname:latest dockerhub.com:5999/docker-repo/newimage:newtag"
        }

        It 'tags public docker image as private docker image with image name only' {
            Invoke-DockerTag -ImageName 'oldname' -NewRegistry 'dockerhub.com:5999/docker-repo' -NewImageName 'newimage'
            $result = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag oldname:latest dockerhub.com:5999/docker-repo/newimage:latest"
        }

        It 'tags public docker image as private docker image with image name and tag' {
            Invoke-DockerTag -ImageName 'oldname' -NewRegistry 'dockerhub.com:5999' -NewImageName 'newimage' -NewTag 'newtag'
            $result = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag oldname:latest dockerhub.com:5999/newimage:newtag"
        }

        It 'tags explicit public docker image as private docker image with image name and tag' {
            Invoke-DockerTag -Registry '' -ImageName 'oldname' -NewRegistry 'dockerhub.com:5999' -NewImageName 'newimage' -NewTag 'newtag'
            $result = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag oldname:latest dockerhub.com:5999/newimage:newtag"
        }
    }

    Context 'tags invalid image' {

        It 'tags invalid image with invalid registry' {
            Mock -CommandName "Invoke-Command" $Global:CodeThatReturnsExitCodeOne -Verifiable -ModuleName $Global:ModuleName
            $runner = { Invoke-DockerTag -ImageName 'oldname' -NewRegistry '.' -NewImageName 'newimage' -NewTag 'newtag' }
            $runner | Should -Throw -ExceptionType ([System.Exception]) -PassThru
        }
    }

    Context 'Pipeline execution' {

        BeforeAll {
            $pipedInput = {
                $input = [PSCustomObject]@{
                    "ImageName"    = "myimage";
                    "NewRegistry"  = "localhost";
                    "NewImageName" = "my-new-image";
                    "NewTag"       = "v1.0.2";
                }
                return $input
            }
        }

        It 'can consume arguments from pipeline' {
            & $pipedInput | Invoke-DockerTag
        }

        It 'returns the expected pscustomobject' {
            $result = & $pipedInput | Invoke-DockerTag
            $result.ImageName | Should -Be 'my-new-image'
            $result.Registry | Should -Be 'localhost/'
            $result.Tag | Should -Be 'v1.0.2'
            $result.CommandResult | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Verbosity of execution' {

        It 'It outputs result if Quiet is disabled' {
            Mock -CommandName "Invoke-Command" $Global:CodeThatReturnsExitCodeZero -Verifiable -ModuleName $Global:ModuleName
            $tempFile = New-TemporaryFile

            Invoke-DockerTag -Quiet:$false -Registry 'artifactoryfqdn' -ImageName 'oldname' -NewImageName 'newimage' 6> $tempFile

            $result = Get-Content $tempFile
            $result | Should -Be @('Hello', 'World')
        }

        It 'It suppresses output if Quiet is enabled' {
            Mock -CommandName "Invoke-Command" $Global:CodeThatReturnsExitCodeZero -Verifiable -ModuleName $Global:ModuleName
            $tempFile = New-TemporaryFile

            Invoke-DockerTag -Quiet:$enable -Registry 'artifactoryfqdn' -ImageName 'oldname' -NewImageName 'newimage' 6> $tempFile

            $result = Get-Content $tempFile
            $result | Should -Be @('Hello', 'World')
        }

    }
}
