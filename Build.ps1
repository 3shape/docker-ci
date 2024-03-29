
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

    Get-ChildItem Env:GitVersion* | Format-List

    $functionScriptFiles = @(Get-ChildItem -Path $PublishDir\Public\*.ps1 -ErrorAction SilentlyContinue)

    Write-Debug "These functions will be included in the published module: ${functionScriptFiles}"

    [string[]]$functionNames = @($functionScriptFiles.BaseName)

    if (!$env:GitVersion_Version) {
        throw 'Module version not found in env:GitVersion_Version where it was expected. Bailing.'
    }

    if (!$env:POWERSHELL_GALLERY_API_TOKEN) {
        throw 'env:POWERSHELL_GALLERY_API_TOKEN is not present'
    }

    $UpdateManifest = @{
        Path              = "$PublishDir\${ModuleName}.psd1"
        FunctionsToExport = $functionNames
        ModuleVersion     = "$env:GitVersion_Version"
    }

    if ($env:GitVersion_PreReleaseTag) {
        $env:Prerelease = $env:GitVersion_PreReleaseTag -replace '[^a-zA-Z0-9]', ''
        $UpdateManifest.Prerelease = "-$env:Prerelease"
    }

    Update-ModuleManifest @UpdateManifest
}

Task PostPublish {
    if ($env:Prerelease) {
        Write-Output 'Skipping notifications to slack because this is a pre-release.'
        return
    }
    $module = "$Env:MODULE_NAME"

    if (!$Env:SLACK_TOKEN) {
        throw ("token not set, cannot publish to slack.")
    }
    if (!$Env:SLACK_URL) {
        thow ("Slack integration endpoint not set, cannot publish to slack.")
    }
    if (!$module) {
        throw ("module name not set, cannot publish to slack.")
    }
    $version = "${env:GitVersion_Version}"
    $slackChannel = 'cicd'
    $slackMessage = "${module}-${version} has been released`n`n" + `
        "The new version is available from https://www.powershellgallery.com/packages/${module}/${version}"
    $Request = @{
        Uri     = "$Env:SLACK_URL"
        Headers = @{
            'Authorization' = "Bearer $ENV:SLACK_TOKEN"
        }
        Body    = @{
            'text'    = $slackMessage;
            'channel' = $slackChannel;
        }
        Method  = 'POST'
    }
    Invoke-WebRequest @Request
}

###############################################################################
# Core task implementations - this possibly "could" ship as part of the
# vscode-powershell extension and then get dot sourced into this file.
###############################################################################
Task default -depends Build

Task Publish -depends Build, PrePublish, PublishImpl, PostPublish {
}

Task PublishImpl -requiredVariables PublishDir {

    $NuGetApiKey = $env:POWERSHELL_GALLERY_API_TOKEN

    $publishParams = @{
        Path        = $PublishDir
        NuGetApiKey = $NuGetApiKey
    }

    if ($Repository) {
        $publishParams['Repository'] = $Repository
    }

    Write-Output "Publishing $ModuleName"
    Write-Output "Version is $env:GitVersion_Version (prerelease: $env:Prerelease)"
    Write-Output "publishParams is: ${publishParams}"

    Publish-Module -Force @publishParams

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

Task GitVersion {
    $_GitVersionMajorMinorMatch = dotnet gitversion -output json -showvariable majorminorpatch
    $_GitVersionPreReleaseTagWithDash = dotnet gitversion -output json -showvariable PreReleaseTagWithDash
    Write-Output "GitVersion says version is : ${_GitVersionMajorMinorMatch}"
    Write-Output "##vso[task.setvariable variable=GitVersion.MajorMinorMatch;isOutput=true]${_GitVersionMajorMinorMatch}"
    Write-Output "GitVersion says prerelease tag is: ${_GitVersionPreReleaseTagWithDash}"
    Write-Output "##vso[task.setvariable variable=GitVersion.PreReleaseTagWithDash;isOutput=true]${_GitVersionPreReleaseTagWithDash}"
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
