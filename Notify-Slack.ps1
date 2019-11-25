$token = $Env:SlackToken
$module = $Env:Docker_CI_ModuleName
$slackURI = "${Env:SlackURI}=${token}"
$version = "${Env:GitVersion_Version}${Env:GitVersion_PreReleaseTagWithDash}"
$slackChannel = 'batcave'
$slackMessage = "${module}-${version} has been released`n`n" + `
    "The new version is available from https://www.powershellgallery.com/packages/${module}/${version}"

$body = @{ "text" = $slackMessage; "channel" = $slackChannel; }
Invoke-WebRequest -Uri $slackURI -Body $body -Method POST
