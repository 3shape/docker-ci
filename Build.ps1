
###############################################################################
# Customize these properties for your module.
###############################################################################
Properties {
    # The name of your module should match the basename of the PSD1 file.
    $ModuleName = (Get-Item $PSScriptRoot\*.psd1)[0].BaseName

    # Path to the release notes file.  Set to $null if the release notes reside in the manifest file.
    $ReleaseNotesPath = $null

    # The directory used to publish the module from.  If you are using Git, the
    # $PublishDir should be ignored if it is under the workspace directory.
    $PublishDir = "$PSScriptRoot\.publish\$ModuleName"

    # The following items will not be copied to the $PublishDir.
    # Add items that should not be published with the module.
    $Exclude = @(
        '*.Tests.ps1',
        '.git*',
        '.publish',
        '.vscode',
        (Split-Path $PSCommandPath -Leaf)
    )
}

###############################################################################
# Customize these tasks for performing operations before and/or after publish.
###############################################################################
Task PrePublish {
    $functionScriptFiles  = @(Get-ChildItem -Path $PublishDir\Public\*.ps1 -ErrorAction SilentlyContinue)
    [string[]]$functionNames = @($functionScriptFiles.BaseName)

    Update-ModuleManifest -Path $PublishDir\${ModuleName}.psd1 `
        -ModuleVersion "$env:GitVersion_Version" `
        -FunctionsToExport $functionNames
}

Task PostPublish {
}

###############################################################################
# Core task implementations - this possibly "could" ship as part of the
# vscode-powershell extension and then get dot sourced into this file.
###############################################################################
Task default -depends Build

Task Publish -depends Test, PrePublish, PublishImpl, PostPublish {
}

Task PublishImpl -depends Test -requiredVariables PublishDir {
    $NuGetApiKey = $env:PSGalleryAPIToken

    $publishParams = @{
        Path        = $PublishDir
        NuGetApiKey = $NuGetApiKey
    }

    if ($Repository) {
        $publishParams['Repository'] = $Repository
    }

    Write-Host "Publishing $ModuleName version $env:GitVersion_Version"

    Publish-Module @publishParams
}

Task Test -depends Build {
    Import-Module Pester
    $testResult = Invoke-Pester $PSScriptRoot/Tests -PassThru

    if ($TestResult.FailedCount -gt 0) {
        $TestResult | Format-List
        throw 'One or more tests for the module failed. Failing the build.'
    }
}

Task Build -depends Clean -requiredVariables PublishDir, Exclude, ModuleName {
    Copy-Item $PSScriptRoot\* -Destination $PublishDir -Recurse -Exclude $Exclude

    # Get contents of the ReleaseNotes file and update the copied module manifest file
    # with the release notes.
    if ($ReleaseNotesPath) {
        $releaseNotes = @(Get-Content $ReleaseNotesPath)
        Update-ModuleManifest -Path $PublishDir\${ModuleName}.psd1 -ReleaseNotes $releaseNotes
    }
}

Task Clean -depends Init -requiredVariables PublishDir {
    # Sanity check the dir we are about to "clean".  If $PublishDir were to
    # inadvertently get set to $null, the Remove-Item commmand removes the
    # contents of \*.  That's a bad day.  Ask me how I know?  :-(
    if ($PublishDir.Contains($PSScriptRoot)) {
        Remove-Item $PublishDir\* -Recurse -Force
    }
}

Task Init -requiredVariables PublishDir {
   if (!(Test-Path $PublishDir)) {
       $null = New-Item $PublishDir -ItemType Directory
   }
}

Task ? -description 'Lists the available tasks' {
    "Available tasks:"
    $psake.context.Peek().tasks.Keys | Sort
}
