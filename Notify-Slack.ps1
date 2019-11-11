$token = $Env:SlackToken
$slackURI = "${Env:SlackURI}=${token}"
$version = "${Env:GitVersion_Version}${Env:GitVersion_PreReleaseTagWithDash}"
$slackChannel = 'batcave'
$author = $(git log -1 $TRAVIS_COMMIT --pretty="%aN")
$slackMessage = "${author} released Docker.Build-${version}`n`n" + `
    "The new version is available from https://www.powershellgallery.com/packages/Docker.Build/${version}"

$body = @{ "text" = $slackMessage; "channel" = $slackChannel; }
Invoke-WebRequest -Uri $slackURI -Body $body -Method POST
