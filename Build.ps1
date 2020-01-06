
###############################################################################
# Customize these properties for your module.
###############################################################################
Properties {
    $TestsDir = "$PSScriptRoot\Test-Source"
    $SourceDir = "$PSScriptRoot\Source"
    # The name of your module should match the basename of the PSD1 file.
    $ModuleName = (Get-Item $SourceDir\*.psd1)[0].BaseName
    # Unless it's set in the env vars, in which case that value is used.
    if ($Env:MODULE_NAME) {
        $ModuleName = $Env:MODULE_NAME
    }
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
    $functionScriptFiles = @(Get-ChildItem -Path $PublishDir\Public\*.ps1 -ErrorAction SilentlyContinue)

    Write-Debug "These functions will be included in the published module: ${functionScriptFiles}"

    [string[]]$functionNames = @($functionScriptFiles.BaseName)

    if (!$env:GitVersion_Version) {
        throw 'Module version not found in env:GitVersion_Version where it was expected. Bailing.'
    }

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
    $NuGetApiKey = $env:POWERSHELL_GALLERY_API_TOKEN

    $publishParams = @{
        Path        = $PublishDir
        NuGetApiKey = $NuGetApiKey
    }

    if ($Repository) {
        $publishParams['Repository'] = $Repository
    }

    $prerelease = $env:GitVersion_PreReleaseTagWithDash
    if ($prerelease) {
        $publishParams['Prerelease'] = $prerelease
    }

    Write-Output "Publishing $ModuleName"
    Write-Output "Version is $env:GitVersion_Version (prerelease: $($prerelease -ne $null))"
    Write-Output "publishParams is: ${publishParams}"

    Publish-Module @publishParams

    Write-Output "Publishing done"
}

Task Test -depends Build {
    Import-Module Pester
    $testResult = Invoke-Pester $TestsDir -CodeCoverage @("${SourceDir}/Public/*.ps1", "${SourceDir}/Private/*.ps1") -PassThru

    Export-CodeCovIoJson -CodeCoverage $testResult.CodeCoverage -RepoRoot $pwd -Path coverage.json;

    if ($TestResult.FailedCount -gt 0) {
        $TestResult | Format-List
        throw 'One or more tests for the module failed. Failing the build.'
    }
}

Task Build -depends Clean -requiredVariables PublishDir, Exclude, ModuleName {
    Copy-Item $SourceDir\* -Destination $PublishDir -Recurse -Exclude $Exclude

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
