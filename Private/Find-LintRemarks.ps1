function Find-LintRemarks {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $text
    )
    $lineNumber = "\B\/dev\/stdin:\d+\b"
    $lintRule = "\w{2}\d{4}"
    $lintRemark = ".*)"
    $splitExpression = "(.+?(?=\/dev\/stdin:\d+?))"
    $lines = ($text -split $splitExpression | Where-Object { $_ })
    $pattern = "^(?<linenumbergroup>${lineNumber}) (?<lintrule>${lintRule}) (?<lintremark>${lintRemark}"

    [LintRemark[]] $lintRemarks = @()
    $lines | Select-String -Pattern $pattern | ForEach-Object {
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
