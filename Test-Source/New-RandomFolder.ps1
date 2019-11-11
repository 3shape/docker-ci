function New-RandomFolder {

    $driveRoot = (Get-PSDrive TestDrive).Root
    do {
        $randomPath = Join-Path $driveRoot $(New-Guid)
    } while (Test-Path -Path $randomPath -PathType Container)
    New-Item -Path $randomPath -ItemType Directory | Out-Null
    return $randomPath
}
