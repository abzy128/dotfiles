# Dual boot with NixOS (abzy-pc-nixos, nix-abzy docs/abzy-pc-nixos.md). The
# firmware always starts systemd-boot on the NixOS disk, and its default is
# Windows. LoaderEntryOneShot overrides that for the next boot only;
# systemd-boot matches it as a glob and boots the first match in menu order,
# which is the newest NixOS generation. This writes one systemd-boot EFI
# variable and nothing else: no files, no Windows boot settings.
function Restart-NixOS {
    [CmdletBinding()]
    param(
        # Set the one-shot entry but don't restart.
        [switch]$NoRestart,
        # Remove a pending one-shot entry instead.
        [switch]$Cancel
    )

    $guid = '{4a67b082-0a4c-41cf-b6c7-440b29bb8c4f}' # systemd-boot's vendor GUID
    $name = 'LoaderEntryOneShot'
    $entry = 'nixos-generation-*'

    if (-not ('AbzyDualBoot.Firmware' -as [type])) {
        Add-Type -Namespace AbzyDualBoot -Name Firmware -MemberDefinition @'
[StructLayout(LayoutKind.Sequential, Pack = 4)]
public struct TokenPrivilege { public uint Count; public long Luid; public uint Attributes; }
[DllImport("kernel32.dll")]
public static extern IntPtr GetCurrentProcess();
[DllImport("advapi32.dll", SetLastError = true)]
public static extern bool OpenProcessToken(IntPtr process, uint access, out IntPtr token);
[DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
public static extern bool LookupPrivilegeValue(string system, string name, out long luid);
[DllImport("advapi32.dll", SetLastError = true)]
public static extern bool AdjustTokenPrivileges(IntPtr token, bool disableAll, ref TokenPrivilege state, uint length, IntPtr previous, IntPtr returnLength);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool CloseHandle(IntPtr handle);
[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
public static extern bool SetFirmwareEnvironmentVariableEx(string name, string guid, byte[] value, uint size, uint attributes);
[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
public static extern uint GetFirmwareEnvironmentVariableEx(string name, string guid, byte[] buffer, uint size, out uint attributes);
'@
    }
    $fw = [AbzyDualBoot.Firmware]

    # Writing EFI variables needs SeSystemEnvironmentPrivilege, which an
    # elevated (or admin SSH) token holds but doesn't enable by default.
    $token = [IntPtr]::Zero
    if (-not $fw::OpenProcessToken($fw::GetCurrentProcess(), 0x28, [ref]$token)) {
        throw "OpenProcessToken failed: $([Runtime.InteropServices.Marshal]::GetLastWin32Error())"
    }
    try {
        $privilege = New-Object AbzyDualBoot.Firmware+TokenPrivilege
        $privilege.Count = 1
        $privilege.Attributes = 2 # SE_PRIVILEGE_ENABLED
        $luid = 0L
        if (-not $fw::LookupPrivilegeValue($null, 'SeSystemEnvironmentPrivilege', [ref]$luid)) {
            throw "LookupPrivilegeValue failed: $([Runtime.InteropServices.Marshal]::GetLastWin32Error())"
        }
        $privilege.Luid = $luid
        $ok = $fw::AdjustTokenPrivileges($token, $false, [ref]$privilege, 0, [IntPtr]::Zero, [IntPtr]::Zero)
        $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
        if (-not $ok -or $err -eq 1300) {
            throw 'Cannot enable SeSystemEnvironmentPrivilege: run from an elevated (administrator) shell.'
        }
    } finally {
        [void]$fw::CloseHandle($token)
    }

    if ($Cancel) {
        # A zero-size write with the variable's attributes deletes it;
        # ignore "not found".
        if (-not $fw::SetFirmwareEnvironmentVariableEx($name, $guid, [byte[]]@(), 0, 7)) {
            $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
            if ($err -ne 203) { throw "Clearing $name failed: $err" }
        }
        Write-Host 'Cleared the pending NixOS one-shot boot.'
        return
    }

    # UTF-16LE with a terminating NUL; non-volatile, boot and runtime access.
    $value = [Text.Encoding]::Unicode.GetBytes($entry + [char]0)
    if (-not $fw::SetFirmwareEnvironmentVariableEx($name, $guid, $value, $value.Length, 7)) {
        throw "Setting $name failed: $([Runtime.InteropServices.Marshal]::GetLastWin32Error())"
    }
    $buffer = New-Object byte[] 256
    $attributes = 0
    $size = $fw::GetFirmwareEnvironmentVariableEx($name, $guid, $buffer, $buffer.Length, [ref]$attributes)
    $readBack = [Text.Encoding]::Unicode.GetString($buffer, 0, $size).TrimEnd([char]0)
    if ($readBack -ne $entry) { throw "$name reads back as '$readBack', expected '$entry'" }

    if ($NoRestart) {
        Write-Host "Next boot goes to NixOS ($entry). Undo with: Restart-NixOS -Cancel"
        return
    }
    Write-Host 'Restarting into NixOS...'
    Restart-Computer -Force
}
