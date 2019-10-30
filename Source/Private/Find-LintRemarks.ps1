function Find-LintRemarks {
    [CmdletBinding()]
    param (
        [AllowEmptyString()]
        [string[]]
        $LintLines
    )
    if ($null -eq $LintLines) {
        return @()
    }

    $lineNumber = "\B\/dev\/stdin:\d+\b"
    $lintRule = "\w{2}\d{4}"
    $lintRemark = ".*)"
    $pattern = "^(?<linenumbergroup>${lineNumber}) (?<lintrule>${lintRule}) (?<lintremark>${lintRemark}"
    [LintRemark[]] $lintRemarks = @()
    $LintLines | Select-String -Pattern $pattern | ForEach-Object {
        $lineNumber, $lintRule, $lintRemark = $_.Matches[0].Groups['linenumbergroup', 'lintrule', 'lintremark'].Value

        $remark = [LintRemark] @{
            LineNumber  = [int] $lineNumber.Substring($lineNumber.LastIndexOf(':') + 1)
            LintRule    = $lintRule.Trim()
            Explanation = $lintRemark.Trim()
        }
        $lintRemarks += $remark
    }
    return $lintRemarks
}
