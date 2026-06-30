function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function y {
	$tmp = (New-TemporaryFile).FullName
	yazi.exe @args --cwd-file="$tmp"
	$cwd = Get-Content -Path $tmp -Encoding UTF8
	if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
		Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
	}
	Remove-Item -Path $tmp
}

function whichdir($name) {
    $directory = Split-Path -Parent (Get-Command $name | Select-Object -ExpandProperty Definition)
    return $directory
}

function ping($name) {
    ping.exe -t $name
}

function p {
    ping.exe -t google.com
}

function lg {
    pwsh -NoProfile -Command "lazygit"
}

Import-Module PSCompletions

# Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
# Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
# Set-PSReadLineKeyHandler -Key Tab -Function Complete
oh-my-posh init pwsh --config 'pure' | Invoke-Expression
Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
