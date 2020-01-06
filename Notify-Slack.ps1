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
$version = "${Env:GitVersion_Version}${Env:GitVersion_PreReleaseTagWithDash}"
$slackChannel = 'batcave'
$slackMessage = "${module}-${version} has been released`n`n" + `
    "The new version is available from https://www.powershellgallery.com/packages/${module}/${version}"

$body = @{
    'text'    = $slackMessage;
    'channel' = $slackChannel;
}
$headers = @{
    'Authorization' = "Bearer $ENV:SLACK_TOKEN"
}
Invoke-WebRequest -Uri "$Env:SLACK_URL" -Headers $headers -Body $body -Method POST
