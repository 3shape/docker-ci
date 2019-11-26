$token = $Env:SlackToken
$module = $Env:Docker_CI_ModuleName

if (!$token) {
    throw ("token not set, cannot publish to slack.")
}
if (!$Env:SlackURI) {
    thow ("Slack integration endpoint not set, cannot publish to slack.")
}
if (!$module) {
    throw ("module name not set, cannot publish to slack.")
}

$slackURI = "${Env:SlackURI}=${token}"
$version = "${Env:GitVersion_Version}${Env:GitVersion_PreReleaseTagWithDash}"
$slackChannel = 'batcave'
$slackMessage = "${module}-${version} has been released`n`n" + `
    "The new version is available from https://www.powershellgallery.com/packages/${module}/${version}"

$body = @{ "text" = $slackMessage; "channel" = $slackChannel; }
Invoke-WebRequest -Uri $slackURI -Body $body -Method POST
