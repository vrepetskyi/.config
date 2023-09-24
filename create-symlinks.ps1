$Data = 'D:\'

# Prompt
New-Item -ItemType SymbolicLink -Force -Path $HOME\Documents\PowerShell\starship.toml -Value $PSScriptRoot\starship.toml
New-Item -ItemType SymbolicLink -Force -Path $HOME\Documents\PowerShell\profile.ps1 -Value $PSScriptRoot\profile.ps1

# Git
New-Item -ItemType SymbolicLink -Force -Path $HOME\.gitconfig -Value $PSScriptRoot\.gitconfig

# WSL
New-Item -ItemType SymbolicLink -Force -Path $HOME\.wslconfig -Value $PSScriptRoot\.wslconfig
New-Item -ItemType SymbolicLink -Force -Path $Data\wsl\mount-home.ps1 -Value $PSScriptRoot\mount-home.ps1
