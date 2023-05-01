Import-Module posh-git

Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-PSReadLineOption -PredictionSource HistoryAndPlugin

Invoke-Expression (&starship init powershell)

$ENV:STARSHIP_CONFIG = "$($PSScriptRoot)\starship.toml"
