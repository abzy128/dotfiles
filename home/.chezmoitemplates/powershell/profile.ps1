# Native Windows shell preferences. Install tools separately.
$env:EDITOR = 'nvim'

if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue) {
    Set-PSReadLineOption -EditMode Windows
    # Windows PowerShell ships PSReadLine 2.0, which has no predictions.
    if ((Get-Module PSReadLine).Version -ge [version]'2.2.0') {
        Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
    }
}

if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& starship init powershell | Out-String)
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& zoxide init powershell | Out-String)
}

if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Module -ListAvailable -Name PSFzf)) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# eza and bat aliases mirror the Zsh ones in nix-abzy.
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    function ls { eza @args }
    function l { eza -lbF --git @args }
    function la { eza -lbaF --git @args }
    function ll { eza -lbGF --git @args }
    function lt { eza --tree --level=2 @args }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function cat { bat --plain @args }
}

if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias -Name vim -Value nvim
    Set-Alias -Name vi -Value nvim
}

if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    Set-Alias -Name lg -Value lazygit
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
