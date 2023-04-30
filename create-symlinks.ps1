New-Item -ItemType SymbolicLink -Path "$HOME\documents\PowerShell\starship.toml" -Value "$PSScriptRoot\starship.toml"
New-Item -ItemType SymbolicLink -Path "$HOME\documents\PowerShell\profile.ps1" -Value "$PSScriptRoot\profile.ps1"

New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig-lambda" -Value "$PSScriptRoot\.gitconfig-lambda"
New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig" -Value "$PSScriptRoot\.gitconfig"

New-Item -ItemType SymbolicLink -Path "$HOME\.wslconfig" -Value "$PSScriptRoot\.wslconfig"
