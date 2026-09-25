# Native Windows shell preferences. Install tools separately.
$env:EDITOR = 'nvim'

if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue) {
    Set-PSReadLineOption -EditMode Windows
}

if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& starship init powershell | Out-String)
}

if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias -Name vim -Value nvim
    Set-Alias -Name vi -Value nvim
}

function terminalNewTabInDirectory {
    if (Get-Command wt -ErrorAction SilentlyContinue) {
        & wt -w 0 nt -d $PWD.Path
    }
}
Set-Alias -Name wtd -Value terminalNewTabInDirectory

if ($PSVersionTable.PSVersion.Major -ge 7 -and (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        dotnet complete --position $cursorPosition "$commandAst" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}
