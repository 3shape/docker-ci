class DockerTagInfo {
    [string] $Arch
    [string] $Distro
    [string] $Version

    [string]Tag() {
        return $this.Version + '-' + $this.Distro + '-' + $this.Arch
    }

    [string]ToString() {
        return $this.Tag()
    }
}
