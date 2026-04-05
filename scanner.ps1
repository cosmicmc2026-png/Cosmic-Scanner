# ============================================================
#  MC Anti-Cheat Scanner v2.5 - FULL EDITION
#  Tool di screenshare per Minecraft (uso via AnyDesk)
#  Report automatico su Discord via Webhook
# ============================================================

param(
    [string]$OutputPath = (Join-Path $PSScriptRoot "MC-Scan_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt")
)

$ErrorActionPreference = "SilentlyContinue"

# ============================================================
#  CONFIGURAZIONE DISCORD WEBHOOK (codificato in Base64)
# ============================================================
$_wh = 'aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTQ5MDQyNzAxMzcyNTU1Njk3Ny9YU3JDZFhnNWlTMmtnd3BmU3dpNjZtLVVtMnlsVWdhUXctb2ZoMTNHU2hZVURBX2xqTHl3SEM0SHVZLU1VYW90VExNYg=='
$DiscordWebhookURL = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_wh))

# ============================================================
#  DATABASE
# ============================================================

$SuspiciousKeywords = @(
    "wurst", "impact client", "aristois", "meteor client", "inertia client",
    "kami blue", "kamiblue", "lambda client", "rusherhack", "future client",
    "konas client", "phobos client", "salhack", "gamesense", "pyro client",
    "liquidbounce", "sigma client", "remix client", "rise client", "novoline",
    "exhibition", "vape client", "vape v4", "vape lite", "drip client",
    "entropy client", "moon client hack", "fdp client", "azura client",
    "skilled client", "wurstplus", "bleach hack", "abyss client", "cake client",
    "pandaware", "tenacity client", "hanabi client", "prestige client",
    "expensive client", "moon client", "intent client", "antic client",
    "minecraft hack", "minecraft cheat", "mc hack", "mc cheat",
    "minecraft hacked client", "hacked client download", "cracked client",
    "minecraft kill aura", "minecraft fly hack", "minecraft speed hack",
    "minecraft xray", "x-ray texture", "xray texture pack", "xray mod",
    "minecraft aimbot", "minecraft autoclicker", "auto clicker minecraft",
    "minecraft reach hack", "minecraft scaffold", "minecraft bhop",
    "minecraft nuker", "free alt minecraft", "minecraft alt generator",
    "alt dispenser", "mcleaks", "thealtening", "minecraft alts free",
    "minecraft esp", "minecraft wallhack", "minecraft triggerbot",
    "minecraft velocity", "minecraft timer hack", "minecraft fastplace",
    "minecraft antiknockback", "anti knockback mc", "minecraft nofall",
    "minecraft jesus hack", "minecraft freecam cheat",
    "minecraft inject", "minecraft bypass", "bypass anticheat",
    "bypass watchdog", "bypass gcheat", "bypass vulcan", "bypass matrix",
    "bypass ncp", "bypass spartan", "screenshare bypass", "ss bypass",
    "rat minecraft", "minecraft rat", "token logger", "token grabber",
    "minecraft exploit", "minecraft dupe", "dupe glitch mc",
    "how to bypass screenshare", "hide cheat from ss", "clean screenshare",
    "ss proof", "screenshare proof", "how to pass screenshare",
    "cheat download", "hack download", "client crack",
    "minecraft ghost client", "ghost client", "closet cheating",
    "external cheat minecraft", "internal cheat minecraft",
    "autoclicker download", "macro minecraft", "butterfly click macro",
    "jitter click macro", "double click macro", "op autoclicker",
    "autoclicker undetectable", "cps booster"
)

$SuspiciousFiles = @(
    "wurst", "impact", "aristois", "meteor-client", "inertia",
    "kamiblue", "lambda", "rusherhack", "future", "konas",
    "phobos", "salhack", "gamesense", "pyro", "liquidbounce",
    "sigma", "remix", "rise", "novoline", "exhibition",
    "vape", "drip", "entropy", "fdpclient", "azura",
    "skilled", "wurstplus", "bleachhack", "abyss", "cake",
    "pandaware", "tenacity", "hanabi", "prestige", "expensive",
    "antic", "intent",
    "xray", "x-ray", "killaura", "autoclick", "autoclicker",
    "aimassist", "aim-assist", "reachmod", "velocitymod",
    "scaffoldmod", "flymod", "speedmod", "nukermod",
    "triggerbot", "aimbot", "esp-mod", "wallhack",
    "fastplace", "antiknockback", "nofall", "jesus",
    "timer-mod", "bhop-mod", "velocity-mod",
    "inject", "loader", "cheat-engine", "cheatengine",
    "processhacker", "dll-inject", "jnativehook"
)

$SuspiciousProcesses = @(
    "wurst", "impact", "aristois", "meteor", "liquidbounce",
    "sigma", "novoline", "rise", "vape", "exhibition",
    "autoclicker", "autoclick", "macro", "clicker",
    "cheatengine", "cheat engine", "processhacker",
    "x64dbg", "x32dbg", "ollydbg", "ida64", "ida32",
    "dnspy", "dotpeek", "fiddler", "wireshark",
    "injector", "dll inject", "jnativehook",
    "opautoclick", "gs auto clicker", "murgee", "clickermann"
)

$SuspiciousDomains = @(
    "intent.store", "vfrm.net", "liquidbounce.net",
    "wizardhax.com", "mpgh.net", "unknowncheats.me",
    "thealtening.com", "mcleaks.net", "altdispenser.com",
    "aristois.net", "meteor-client.com", "rusherhack.org",
    "futureclient.net", "wurstclient.net", "sigmaclient.info",
    "novoline.wtf", "rise.world", "exhibition.al",
    "pandaware.club", "tenacity.dev", "intent.store",
    "expensive.gg", "prestige.cc", "hanabi.club"
)

# ============================================================
#  VARIABILI GLOBALI PER IL REPORT
# ============================================================
$script:AllAlerts = [System.Collections.ArrayList]::new()
$script:TotalAlerts = 0
$script:ScanStartTime = Get-Date
$script:ModuleResults = [System.Collections.ArrayList]::new()

# ============================================================
#  FUNZIONI GRAFICHE
# ============================================================

function Show-Banner {
    $banner = @"

    ==========================================================
    |                                                        |
    |   __  __  ____   ____                                  |
    |  |  \/  |/ ___| / ___|  ___ __ _ _ __  _ __   ___ _ _ |
    |  | |\/| | |     \___ \ / __/ _` | '_ \| '_ \ / _ \ '_||
    |  | |  | | |___   ___) | (_| (_| | | | | | | |  __/ |  |
    |  |_|  |_|\____| |____/ \___\__,_|_| |_|_| |_|\___|_|  |
    |                                                        |
    |        Anti-Cheat Screenshare Tool v2.5                |
    |        15 Moduli  -  Tutti i Browser  -  Discord       |
    |                                                        |
    ==========================================================
"@
    Write-Host $banner -ForegroundColor Cyan
}

function Show-ProgressModule {
    param([int]$Current, [int]$Total, [string]$ModuleName)

    $percent = [math]::Floor(($Current / $Total) * 100)
    $barLength = 30
    $filled = [math]::Floor(($percent / 100) * $barLength)
    $empty = $barLength - $filled

    $bar = "[" + ("#" * $filled) + ("-" * $empty) + "]"

    Write-Host ""
    Write-Host "  ----------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "    $bar $percent% ($Current/$Total)" -ForegroundColor Cyan
    Write-Host "    >> $ModuleName" -ForegroundColor Yellow
    Write-Host "  ----------------------------------------------------------" -ForegroundColor DarkGray
}

function Show-ModuleResult {
    param([string]$ModuleName, [int]$Alerts)

    if ($Alerts -eq 0) {
        Write-Host "     [OK] " -ForegroundColor Green -NoNewline
        Write-Host "$ModuleName " -ForegroundColor White -NoNewline
        Write-Host "- Pulito" -ForegroundColor Green
    } else {
        Write-Host "     [!!] " -ForegroundColor Red -NoNewline
        Write-Host "$ModuleName " -ForegroundColor White -NoNewline
        Write-Host "-$Alerts alert trovati!" -ForegroundColor Red
    }

    $null = $script:ModuleResults.Add(@{ Name = $ModuleName; Alerts = $Alerts })
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $line = "[$timestamp] [$Level] $Message"
    Add-Content -Path $OutputPath -Value $line

    if ($Level -eq "ALERT") {
        $null = $script:AllAlerts.Add($Message)
        Write-Host "       [!] $Message" -ForegroundColor Red
    }
    elseif ($Level -eq "WARNING") {
        Write-Host "       ! $Message" -ForegroundColor Yellow
    }
}

function Write-LogSection {
    param([string]$Title)
    Add-Content -Path $OutputPath -Value "`n$("=" * 60)`n  $Title`n$("=" * 60)"
}

function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $pr = New-Object Security.Principal.WindowsPrincipal($id)
    return $pr.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# ============================================================
#  MODULO 1: INFO SISTEMA
# ============================================================

function Scan-SystemInfo {
    Write-LogSection "INFO SISTEMA"

    $info = @{
        Computer = $env:COMPUTERNAME
        Utente   = $env:USERNAME
        OS       = [System.Environment]::OSVersion.VersionString
        Admin    = if (Test-IsAdmin) { "SI" } else { "NO" }
        Data     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    $uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    if ($uptime) {
        $info["Uptime"] = "$([math]::Floor($uptime.TotalHours))h $($uptime.Minutes)m"
    }

    foreach ($k in $info.Keys) {
        Write-Log "$k`: $($info[$k])"
    }

    return $info
}

# ============================================================
#  MODULO 2: DIRECTORY MINECRAFT
# ============================================================

function Scan-MinecraftDirectories {
    Write-LogSection "DIRECTORY MINECRAFT"
    $a = 0

    $mcPaths = @(
        "$env:APPDATA\.minecraft", "$env:APPDATA\.lunarclient",
        "$env:APPDATA\.badlion", "$env:APPDATA\.tlauncher",
        "$env:APPDATA\.feather", "$env:APPDATA\.pvplounge",
        "$env:APPDATA\.labymod", "$env:APPDATA\.crystal",
        "$env:APPDATA\.fabric", "$env:APPDATA\.forge",
        "$env:APPDATA\.salwyrr", "$env:APPDATA\.paladium",
        "$env:APPDATA\.polymc", "$env:APPDATA\PrismLauncher",
        "$env:APPDATA\PolyMC", "$env:APPDATA\ATLauncher",
        "$env:LOCALAPPDATA\MultiMC",
        "$env:LOCALAPPDATA\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe"
    ) | Where-Object { Test-Path $_ }

    if ($mcPaths.Count -eq 0) {
        Write-Log "Nessuna installazione MC trovata" "WARNING"
        return 0
    }

    foreach ($mcPath in $mcPaths) {
        Write-Log "Scansione: $mcPath"

        foreach ($sub in @("mods","versions","resourcepacks","shaderpacks","saves","config")) {
            $subPath = Join-Path $mcPath $sub
            if (-not (Test-Path $subPath)) { continue }

            Get-ChildItem -Path $subPath -Recurse -Force -File 2>$null | ForEach-Object {
                $fn = $_.Name.ToLower()
                foreach ($s in $SuspiciousFiles) {
                    if ($fn -match [regex]::Escape($s)) {
                        $sz = [math]::Round($_.Length/1KB,2)
                        $msg = "[$sub] $($_.FullName) (match: $s) - ${sz}KB - $($_.LastWriteTime)"
                        Write-Log $msg "ALERT"
                        $a++; break
                    }
                }
            }
        }

        # JAR nella root
        Get-ChildItem -Path $mcPath -Filter "*.jar" -Force -File 2>$null | ForEach-Object {
            $fn = $_.Name.ToLower()
            foreach ($s in $SuspiciousFiles) {
                if ($fn -match [regex]::Escape($s)) {
                    Write-Log "JAR root: $($_.FullName) (match: $s)" "ALERT"; $a++; break
                }
            }
        }

        # launcher_profiles.json
        $pf = Join-Path $mcPath "launcher_profiles.json"
        if (Test-Path $pf) {
            $c = Get-Content $pf -Raw 2>$null
            if ($c) {
                foreach ($s in $SuspiciousFiles) {
                    if ($c -match [regex]::Escape($s)) {
                        Write-Log "Profilo launcher contiene '$s'" "ALERT"; $a++
                    }
                }
            }
        }

        # Log recenti
        $lp = Join-Path $mcPath "logs"
        if (Test-Path $lp) {
            Get-ChildItem -Path $lp -Filter "*.log" -Force 2>$null |
                Sort-Object LastWriteTime -Descending | Select-Object -First 5 | ForEach-Object {
                $lc = Get-Content $_.FullName -Raw 2>$null
                if ($lc) {
                    foreach ($s in $SuspiciousFiles) {
                        if ($lc -match [regex]::Escape($s)) {
                            Write-Log "Log $($_.Name) contiene '$s'" "ALERT"; $a++
                        }
                    }
                }
            }
        }
    }

    return $a
}

# ============================================================
#  MODULO 3: FILE NASCOSTI
# ============================================================

function Scan-HiddenFiles {
    Write-LogSection "FILE NASCOSTI"
    $a = 0

    $paths = @(
        "$env:APPDATA\.minecraft", "$env:APPDATA",
        "$env:LOCALAPPDATA\Temp", "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\Documents"
    ) | Where-Object { Test-Path $_ }

    foreach ($p in $paths) {
        # File hidden
        Get-ChildItem -Path $p -Force -File -Recurse -Depth 3 2>$null |
            Where-Object { $_.Attributes -match "Hidden" } | ForEach-Object {
            $fn = $_.Name.ToLower()

            foreach ($s in $SuspiciousFiles) {
                if ($fn -match [regex]::Escape($s)) {
                    $sz = [math]::Round($_.Length/1KB,2)
                    Write-Log "File nascosto: $($_.FullName) (match: $s) - ${sz}KB" "ALERT"
                    $a++; break
                }
            }

            if ($fn -match "\.(jar|dll|exe)$" -and $_.DirectoryName -match "minecraft|mods|Temp|Desktop") {
                Write-Log "Eseguibile nascosto: $($_.FullName)" "ALERT"; $a++
            }
        }

        # Cartelle hidden sospette
        Get-ChildItem -Path $p -Force -Directory -Depth 2 2>$null |
            Where-Object { $_.Attributes -match "Hidden" -and $_.Name -notmatch "^\." } | ForEach-Object {
            $dn = $_.Name.ToLower()
            foreach ($s in $SuspiciousFiles) {
                if ($dn -match [regex]::Escape($s)) {
                    Write-Log "Cartella nascosta: $($_.FullName)" "ALERT"; $a++; break
                }
            }
        }
    }

    return $a
}

# ============================================================
#  MODULO 4: TEMP / APPDATA
# ============================================================

function Scan-TempAppData {
    Write-LogSection "TEMP / APPDATA"
    $a = 0

    foreach ($bp in @("$env:LOCALAPPDATA\Temp", "$env:APPDATA", "$env:LOCALAPPDATA")) {
        if (-not (Test-Path $bp)) { continue }

        Get-ChildItem -Path $bp -Directory -Force -Depth 1 2>$null | ForEach-Object {
            $dn = $_.Name.ToLower()
            foreach ($s in $SuspiciousFiles) {
                if ($dn -match [regex]::Escape($s)) {
                    Write-Log "Cartella sospetta: $($_.FullName)" "ALERT"; $a++; break
                }
            }
        }

        if ($bp -match "Temp") {
            $cutoff = (Get-Date).AddDays(-30)
            Get-ChildItem -Path $bp -Force -File -Recurse -Depth 2 2>$null |
                Where-Object { $_.LastWriteTime -gt $cutoff -and $_.Extension -match "\.(jar|dll|exe|bat|ps1|vbs)$" } | ForEach-Object {
                $fn = $_.Name.ToLower()
                foreach ($s in $SuspiciousFiles) {
                    if ($fn -match [regex]::Escape($s)) {
                        Write-Log "File sospetto in Temp: $($_.FullName)" "ALERT"; $a++; break
                    }
                }
                if ($_.Extension -eq ".jar") {
                    $sz = [math]::Round($_.Length/1KB,2)
                    Write-Log "JAR in Temp: $($_.FullName) - ${sz}KB" "WARNING"
                }
            }
        }
    }

    return $a
}

# ============================================================
#  MODULO 5: PROCESSI ATTIVI
# ============================================================

function Scan-Processes {
    Write-LogSection "PROCESSI ATTIVI"
    $a = 0

    $procs = Get-Process 2>$null |
        Select-Object Name, Id, Path, @{N='MB';E={[math]::Round($_.WorkingSet64/1MB,2)}}

    foreach ($p in $procs) {
        $pn = $p.Name.ToLower()
        $pp = if ($p.Path) { $p.Path.ToLower() } else { "" }

        foreach ($s in $SuspiciousProcesses) {
            if ($pn -match [regex]::Escape($s) -or $pp -match [regex]::Escape($s)) {
                $msg = "Processo: $($p.Name) (PID $($p.Id)) - $($p.Path)"
                Write-Log $msg "ALERT"; $a++
            }
        }
    }

    # Java analysis
    $javaProcs = $procs | Where-Object { $_.Name -match "java|javaw" }
    foreach ($jp in $javaProcs) {
        $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId = $($jp.Id)" 2>$null).CommandLine
        if ($cmd) {
            foreach ($s in $SuspiciousFiles) {
                if ($cmd.ToLower() -match [regex]::Escape($s)) {
                    Write-Log "Java CmdLine contiene '$s' (PID $($jp.Id))" "ALERT"; $a++
                }
            }
            $trunc = if ($cmd.Length -gt 300) { $cmd.Substring(0,300) + "..." } else { $cmd }
            $msg = "Java PID $($jp.Id) - $($jp.MB)MB - $trunc"
            Write-Log $msg
        }
    }

    return $a
}

# ============================================================
#  MODULO 6: CRONOLOGIA TUTTI I BROWSER
# ============================================================

function Scan-AllBrowsers {
    Write-LogSection "CRONOLOGIA BROWSER"
    $a = 0

    $browsers = @(
        @{ Name="Chrome";       Type="chromium"; Path="$env:LOCALAPPDATA\Google\Chrome\User Data" },
        @{ Name="Edge";         Type="chromium"; Path="$env:LOCALAPPDATA\Microsoft\Edge\User Data" },
        @{ Name="Opera";        Type="chromium"; Path="$env:APPDATA\Opera Software\Opera Stable" },
        @{ Name="Opera GX";     Type="chromium"; Path="$env:APPDATA\Opera Software\Opera GX Stable" },
        @{ Name="Brave";        Type="chromium"; Path="$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data" },
        @{ Name="Vivaldi";      Type="chromium"; Path="$env:LOCALAPPDATA\Vivaldi\User Data" },
        @{ Name="Chromium";     Type="chromium"; Path="$env:LOCALAPPDATA\Chromium\User Data" },
        @{ Name="Yandex";       Type="chromium"; Path="$env:LOCALAPPDATA\Yandex\YandexBrowser\User Data" },
        @{ Name="360 Browser";  Type="chromium"; Path="$env:LOCALAPPDATA\360Chrome\Chrome\User Data" },
        @{ Name="CentBrowser";  Type="chromium"; Path="$env:LOCALAPPDATA\CentBrowser\User Data" },
        @{ Name="Epic";         Type="chromium"; Path="$env:LOCALAPPDATA\Epic Privacy Browser\User Data" },
        @{ Name="Comodo";       Type="chromium"; Path="$env:LOCALAPPDATA\Comodo\Dragon\User Data" },
        @{ Name="Iron";         Type="chromium"; Path="$env:LOCALAPPDATA\Chromodo\User Data" },
        @{ Name="Firefox";      Type="firefox";  Path="$env:APPDATA\Mozilla\Firefox\Profiles" },
        @{ Name="Waterfox";     Type="firefox";  Path="$env:APPDATA\Waterfox\Profiles" },
        @{ Name="LibreWolf";    Type="firefox";  Path="$env:APPDATA\librewolf\Profiles" },
        @{ Name="Pale Moon";    Type="firefox";  Path="$env:APPDATA\Moonchild Productions\Pale Moon\Profiles" },
        @{ Name="Tor Browser";  Type="firefox";  Path="$env:USERPROFILE\Desktop\Tor Browser\Browser\TorBrowser\Data\Browser\profile.default" }
    )

    $hasSqlite = [bool](Get-Command sqlite3 -ErrorAction SilentlyContinue)

    foreach ($br in $browsers) {
        if (-not (Test-Path $br.Path)) { continue }
        Write-Log "Browser trovato: $($br.Name)"

        $dbFiles = @()

        if ($br.Type -eq "chromium") {
            # Direct history (Opera-style)
            $dh = Join-Path $br.Path "History"
            if (Test-Path $dh) { $dbFiles += @{ Prof="Default"; Db=$dh } }

            # Profile folders
            Get-ChildItem -Path $br.Path -Directory 2>$null |
                Where-Object { $_.Name -match "^(Default|Profile)" } | ForEach-Object {
                $h = Join-Path $_.FullName "History"
                if (Test-Path $h) { $dbFiles += @{ Prof=$_.Name; Db=$h } }
            }
        }
        else {
            # Firefox direct
            $dp = Join-Path $br.Path "places.sqlite"
            if (Test-Path $dp) { $dbFiles += @{ Prof="default"; Db=$dp } }

            # Firefox profiles
            Get-ChildItem -Path $br.Path -Directory 2>$null | ForEach-Object {
                $pp = Join-Path $_.FullName "places.sqlite"
                if (Test-Path $pp) { $dbFiles += @{ Prof=$_.Name; Db=$pp } }
            }
        }

        foreach ($db in $dbFiles) {
            $brClean = $br.Name -replace ' ',''
            $profName = $db.Prof
            $tmp = Join-Path $env:TEMP "scan_${brClean}_${profName}.db"
            Copy-Item $db.Db $tmp -Force 2>$null
            if (-not (Test-Path $tmp)) { continue }

            if ($hasSqlite) {
                if ($br.Type -eq "chromium") {
                    $q = 'SELECT url, title, datetime(last_visit_time/1000000-11644473600,''unixepoch'',''localtime'') FROM urls ORDER BY last_visit_time DESC LIMIT 10000;'
                } else {
                    $q = 'SELECT url, title, datetime(last_visit_date/1000000,''unixepoch'',''localtime'') FROM moz_places WHERE visit_count > 0 ORDER BY last_visit_date DESC LIMIT 10000;'
                }
                $rows = & sqlite3 $tmp $q 2>$null
                foreach ($row in $rows) {
                    $rl = $row.ToLower()
                    foreach ($kw in $SuspiciousKeywords) {
                        if ($rl -match [regex]::Escape($kw)) {
                            $bName = $br.Name
                            $msg = "${bName} (${profName}): $row"
                            Write-Log $msg "ALERT"; $a++; break
                        }
                    }
                }
            }
            else {
                try {
                    $raw = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($tmp))
                    foreach ($kw in $SuspiciousKeywords) {
                        if ($raw -match [regex]::Escape($kw)) {
                            $bName = $br.Name
                            $msg = "${bName} contiene keyword: ${kw} (${profName})"
                            Write-Log $msg "ALERT"; $a++
                        }
                    }
                } catch {}
            }

            Remove-Item $tmp -Force 2>$null
        }
    }

    return $a
}

# ============================================================
#  MODULO 7: DOWNLOADS + ZONE IDENTIFIER
# ============================================================

function Scan-Downloads {
    Write-LogSection "CARTELLA DOWNLOADS + ZONE ID"
    $a = 0

    $dlPath = [Environment]::GetFolderPath("UserProfile") + "\Downloads"
    if (-not (Test-Path $dlPath)) { return 0 }

    $cutoff = (Get-Date).AddDays(-90)
    Get-ChildItem -Path $dlPath -Recurse -Force -File 2>$null |
        Where-Object { $_.LastWriteTime -gt $cutoff } | ForEach-Object {
        $fn = $_.Name.ToLower()

        foreach ($s in $SuspiciousFiles) {
            if ($fn -match [regex]::Escape($s)) {
                $sz = [math]::Round($_.Length/1KB,2)
                Write-Log "Download: $($_.FullName) (match: $s) - ${sz}KB" "ALERT"
                $a++; break
            }
        }

        if ($fn -match "\.jar$" -and $fn -match "hack|cheat|client|inject|crack|exploit|wurst|vape") {
            Write-Log "JAR sospetto: $($_.FullName)" "ALERT"; $a++
        }

        # Zone.Identifier ADS check
        $zi = $_.FullName + ":Zone.Identifier"
        if (Test-Path $zi -PathType Leaf 2>$null) {
            $zc = Get-Content $zi 2>$null | Out-String
            foreach ($d in $SuspiciousDomains) {
                if ($zc -match [regex]::Escape($d)) {
                    Write-Log "Scaricato da sito sospetto: $($_.Name) -> $d" "ALERT"; $a++
                }
            }
        }
    }

    return $a
}

# ============================================================
#  MODULO 8: DNS CACHE
# ============================================================

function Scan-DNS {
    Write-LogSection "DNS CACHE"
    $a = 0

    $dns = Get-DnsClientCache 2>$null
    if (-not $dns) { Write-Log "DNS cache non accessibile" "WARNING"; return 0 }

    foreach ($e in $dns) {
        $en = $e.Entry.ToLower()
        foreach ($d in $SuspiciousDomains) {
            if ($en -match [regex]::Escape($d)) {
                Write-Log "DNS: $($e.Entry) -> $($e.Data)" "ALERT"; $a++
            }
        }
    }

    return $a
}

# ============================================================
#  MODULO 9: PREFETCH
# ============================================================

function Scan-Prefetch {
    Write-LogSection "PREFETCH"
    $a = 0

    $pfPath = "$env:SystemRoot\Prefetch"
    if (-not (Test-Path $pfPath)) { Write-Log "Prefetch non accessibile" "WARNING"; return 0 }

    Get-ChildItem -Path $pfPath -Filter "*.pf" -Force 2>$null | ForEach-Object {
        $pn = $_.Name.ToLower()
        foreach ($s in $SuspiciousProcesses) {
            if ($pn -match [regex]::Escape($s)) {
                $msg = "Prefetch: $($_.Name) - Last: $($_.LastAccessTime)"
                Write-Log $msg "ALERT"; $a++
            }
        }
        if ($pn -match "autoclicker|autoclick|macro|inject|hack|cheat|crack|exploit") {
            $msg = "Prefetch generico: $($_.Name) - Last: $($_.LastAccessTime)"
            Write-Log $msg "ALERT"; $a++
        }
    }

    return $a
}

# ============================================================
#  MODULO 10: CESTINO
# ============================================================

function Scan-RecycleBin {
    Write-LogSection "CESTINO"
    $a = 0

    try {
        $shell = New-Object -ComObject Shell.Application
        $bin = $shell.NameSpace(0x0a)
        if ($bin) {
            foreach ($item in $bin.Items()) {
                $in = $item.Name.ToLower()
                $ip = if ($item.Path) { $item.Path.ToLower() } else { "" }
                foreach ($s in $SuspiciousFiles) {
                    if ($in -match [regex]::Escape($s) -or $ip -match [regex]::Escape($s)) {
                        $msg = "Cestino: $($item.Name) - $($item.Path)"
                        Write-Log $msg "ALERT"; $a++; break
                    }
                }
            }
        }
    } catch {
        Write-Log "Cestino non accessibile" "WARNING"
    }

    return $a
}

# ============================================================
#  MODULO 11: FILE RECENTI + ADS
# ============================================================

function Scan-RecentFiles {
    Write-LogSection "FILE RECENTI + ADS"
    $a = 0

    $rp = "$env:APPDATA\Microsoft\Windows\Recent"
    if (Test-Path $rp) {
        Get-ChildItem -Path $rp -Force -File 2>$null |
            Sort-Object LastWriteTime -Descending | Select-Object -First 300 | ForEach-Object {
            $fn = $_.Name.ToLower()
            foreach ($s in $SuspiciousFiles) {
                if ($fn -match [regex]::Escape($s)) {
                    $msg = "Recente: $($_.Name) - $($_.LastWriteTime)"
                    Write-Log $msg "ALERT"; $a++; break
                }
            }
            if ($fn -match "autoclicker|autoclick|macro|inject|hack|cheat|crack") {
                $msg = "Recente generico: $($_.Name) - $($_.LastWriteTime)"
                Write-Log $msg "ALERT"; $a++
            }
        }
    }

    # ADS su mods MC
    $mcMods = "$env:APPDATA\.minecraft\mods"
    if (Test-Path $mcMods) {
        Get-ChildItem -Path $mcMods -Filter "*.jar" -Force 2>$null | ForEach-Object {
            $zi = $_.FullName + ":Zone.Identifier"
            try {
                $zc = Get-Content $zi 2>$null | Out-String
                if ($zc) {
                    foreach ($d in $SuspiciousDomains) {
                        if ($zc -match [regex]::Escape($d)) {
                            Write-Log "Mod scaricato da: $($_.Name) -> $d" "ALERT"; $a++
                        }
                    }
                }
            } catch {}
        }
    }

    return $a
}

# ============================================================
#  MODULO 12: PROGRAMMI INSTALLATI
# ============================================================

function Scan-Programs {
    Write-LogSection "PROGRAMMI INSTALLATI"
    $a = 0

    $regPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $progs = foreach ($rp in $regPaths) {
        Get-ItemProperty $rp 2>$null | Where-Object { $_.DisplayName } |
            Select-Object DisplayName, Publisher
    }

    $sp = @("cheat engine","process hacker","autoclicker","auto clicker",
        "macro recorder","dll injector","x64dbg","ollydbg","dnspy","game guardian")

    foreach ($p in $progs) {
        $pn = $p.DisplayName.ToLower()
        foreach ($s in $sp) {
            if ($pn -match [regex]::Escape($s)) {
                $msg = "Programma: $($p.DisplayName) - $($p.Publisher)"
                Write-Log $msg "ALERT"; $a++
            }
        }
    }

    return $a
}

# ============================================================
#  MODULO 13: STARTUP
# ============================================================

function Scan-Startup {
    Write-LogSection "AVVIO AUTOMATICO"
    $a = 0

    foreach ($key in @(
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    )) {
        if (-not (Test-Path $key)) { continue }
        $entries = Get-ItemProperty $key 2>$null
        $entries.PSObject.Properties | Where-Object { $_.Name -notmatch "^PS" } | ForEach-Object {
            $v = $_.Value.ToString().ToLower()
            foreach ($s in $SuspiciousProcesses) {
                if ($v -match [regex]::Escape($s)) {
                    Write-Log "Startup: $($_.Name) -> $($_.Value)" "ALERT"; $a++
                }
            }
        }
    }

    $sf = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    if (Test-Path $sf) {
        Get-ChildItem -Path $sf -Force -File 2>$null | ForEach-Object {
            $fn = $_.Name.ToLower()
            foreach ($s in $SuspiciousProcesses) {
                if ($fn -match [regex]::Escape($s)) {
                    Write-Log "File startup: $($_.FullName)" "ALERT"; $a++
                }
            }
        }
    }

    return $a
}

# ============================================================
#  MODULO 14: TASK PIANIFICATI + HOSTS
# ============================================================

function Scan-TasksHosts {
    Write-LogSection "TASK PIANIFICATI + HOSTS"
    $a = 0

    Get-ScheduledTask 2>$null | Where-Object { $_.State -ne "Disabled" } | ForEach-Object {
        $tn = $_.TaskName.ToLower()
        foreach ($s in $SuspiciousProcesses) {
            if ($tn -match [regex]::Escape($s)) {
                $msg = "Task: $($_.TaskName) - $($_.TaskPath)"
                Write-Log $msg "ALERT"; $a++
            }
        }
        if ($tn -match "inject|hack|cheat|autoclicker|macro") {
            Write-Log "Task generico: $($_.TaskName)" "ALERT"; $a++
        }
    }

    $hp = "$env:SystemRoot\System32\drivers\etc\hosts"
    if (Test-Path $hp) {
        $custom = Get-Content $hp 2>$null |
            Where-Object { $_ -and $_ -notmatch "^\s*#" -and $_ -notmatch "^\s*$" -and
                          $_ -notmatch "^127\.0\.0\.1\s+localhost" -and $_ -notmatch "^::1\s+localhost" }
        foreach ($e in $custom) {
            Write-Log "Hosts entry: $e" "WARNING"
            if ($e -match "anticheat|watchdog|hypixel|mineplex|badlion|lunar") {
                Write-Log "BLOCCO ANTICHEAT nel hosts!" "ALERT"; $a++
            }
        }
    }

    return $a
}

# ============================================================
#  MODULO 15: CARTELLE UTENTE (Desktop, Documenti, etc.)
# ============================================================

function Scan-UserFolders {
    Write-LogSection "CARTELLE UTENTE"
    $a = 0

    $folders = @(
        "$env:USERPROFILE\Desktop", "$env:USERPROFILE\Documents",
        "$env:USERPROFILE\Videos", "$env:USERPROFILE\Music",
        "$env:USERPROFILE\Pictures",
        "$env:USERPROFILE\OneDrive\Desktop", "$env:USERPROFILE\OneDrive\Documents"
    ) | Where-Object { Test-Path $_ }

    foreach ($f in $folders) {
        Get-ChildItem -Path $f -Force -File -Recurse -Depth 3 2>$null |
            Where-Object { $_.Extension -match "\.(jar|exe|dll|bat|ps1|vbs|cmd|msi)$" } | ForEach-Object {
            $fn = $_.Name.ToLower()

            foreach ($s in $SuspiciousFiles) {
                if ($fn -match [regex]::Escape($s)) {
                    $folder = Split-Path $f -Leaf
                    $sz = [math]::Round($_.Length/1KB,2)
                    $hid = $_.Attributes -match 'Hidden'
                    $msg = "${folder}: $($_.FullName) (match: $s) - ${sz}KB - Hidden:${hid}"
                    Write-Log $msg "ALERT"
                    $a++; break
                }
            }

            if ($fn -match "\.jar$" -and $fn -match "hack|cheat|client|inject|crack|exploit|xray|killaura|aimbot") {
                Write-Log "JAR sospetto: $($_.FullName)" "ALERT"; $a++
            }
        }
    }

    return $a
}

# ============================================================
#  DISCORD WEBHOOK - Invio Report
# ============================================================

function Send-DiscordReport {
    param(
        [hashtable]$SystemInfo,
        [int]$TotalAlerts,
        [System.Collections.ArrayList]$ModuleResults,
        [System.Collections.ArrayList]$AllAlerts
    )

    if (-not $DiscordWebhookURL) {
        Write-Host ""
        Write-Host "  ----------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "    Discord webhook non configurato - report non inviato" -ForegroundColor Yellow
        Write-Host "    Configura " -ForegroundColor White -NoNewline
        Write-Host "`$DiscordWebhookURL" -ForegroundColor Cyan -NoNewline
        Write-Host " nello script per attivarlo" -ForegroundColor White
        Write-Host "  ----------------------------------------------------------" -ForegroundColor DarkGray
        return
    }

    Write-Host ""
    Write-Host "  >> Invio report su Discord..." -ForegroundColor Cyan

    # Verdetto
    $verdict = if ($TotalAlerts -eq 0) { "PULITO" }
               elseif ($TotalAlerts -le 3) { "SOSPETTO BASSO" }
               elseif ($TotalAlerts -le 10) { "SOSPETTO MEDIO" }
               else { "SOSPETTO ALTO" }

    $color = if ($TotalAlerts -eq 0) { 3066993 }       # verde
             elseif ($TotalAlerts -le 3) { 16776960 }   # giallo
             elseif ($TotalAlerts -le 10) { 16744448 }   # arancione
             else { 15158332 }                           # rosso

    $emojiIcon = if ($TotalAlerts -eq 0) { ":green_circle:" }
                 elseif ($TotalAlerts -le 3) { ":yellow_circle:" }
                 elseif ($TotalAlerts -le 10) { ":orange_circle:" }
                 else { ":red_circle:" }

    # Costruisci il campo moduli
    $moduleSummary = ""
    foreach ($mr in $ModuleResults) {
        $mrName = $mr.Name
        $mrAlerts = $mr.Alerts
        if ($mrAlerts -eq 0) {
            $moduleSummary += "[OK] $mrName`n"
        } else {
            $moduleSummary += "[!!] **${mrAlerts}** $mrName`n"
        }
    }

    # Top 10 alert
    $alertPreview = ""
    $maxAlerts = [math]::Min($AllAlerts.Count, 10)
    for ($i = 0; $i -lt $maxAlerts; $i++) {
        $alertText = $AllAlerts[$i]
        if ($alertText.Length -gt 80) { $alertText = $alertText.Substring(0, 80) + "..." }
        $alertPreview += "- $alertText`n"
    }
    $remaining = $AllAlerts.Count - 10
    if ($remaining -gt 0) {
        $alertPreview += "- ... e altri $remaining alert`n"
    }
    if (-not $alertPreview) { $alertPreview = "Nessun alert trovato" }

    # Durata
    $duration = [math]::Round(((Get-Date) - $script:ScanStartTime).TotalSeconds)

    # Build values
    $compName = $SystemInfo['Computer']
    $userName = $SystemInfo['Utente']
    $osName = $SystemInfo['OS']
    $adminStatus = $SystemInfo['Admin']
    $uptimeVal = $SystemInfo['Uptime']
    $dateNow = Get-Date -Format 'dd/MM/yyyy HH:mm'
    $tsNow = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
    $alertBlock = '```' + "`n$alertPreview" + '```'

    # Payload as hashtable
    $embedObj = @{
        title       = "$emojiIcon Screenshare Report - $verdict"
        color       = $color
        description = "Scansione completata su **${compName}** (utente: **${userName}**)"
        fields      = @(
            @{ name = "Verdetto";      value = "**$verdict** - $TotalAlerts alert totali"; inline = $false },
            @{ name = "Sistema";       value = "${osName} - Admin: ${adminStatus} - Uptime: ${uptimeVal}"; inline = $false },
            @{ name = "Moduli";        value = $moduleSummary; inline = $false },
            @{ name = "Alert (top 10)"; value = $alertBlock; inline = $false },
            @{ name = "Durata";        value = "${duration} secondi"; inline = $true },
            @{ name = "Data";          value = $dateNow; inline = $true }
        )
        footer      = @{ text = "MC Anti-Cheat Scanner v2.5" }
        timestamp   = $tsNow
    }

    $payload = @{
        username   = "MC Anti-Cheat Scanner"
        avatar_url = "https://i.imgur.com/AfFp7pu.png"
        embeds     = @($embedObj)
    }
    $jsonPayload = $payload | ConvertTo-Json -Depth 10

    try {
        $utf8 = [System.Text.Encoding]::UTF8.GetBytes($jsonPayload)
        Invoke-RestMethod -Uri $DiscordWebhookURL -Method Post -Body $utf8 -ContentType 'application/json; charset=utf-8' | Out-Null
        Write-Host "  [OK] Report inviato su Discord!" -ForegroundColor Green
    }
    catch {
        $errMsg = $_.Exception.Message
        Write-Host "  [ERRORE] Invio Discord: $errMsg" -ForegroundColor Red
    }

    # Invia anche il file log come allegato
    try {
        $boundary = [System.Guid]::NewGuid().ToString()
        $fileBytes = [System.IO.File]::ReadAllBytes($OutputPath)
        $fileName = [System.IO.Path]::GetFileName($OutputPath)
        $enc = [System.Text.Encoding]::UTF8

        $bodyLines = @(
            "--$boundary",
            "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"",
            "Content-Type: text/plain",
            "",
            $enc.GetString($fileBytes),
            "--$boundary--"
        )
        $bodyStr = $bodyLines -join "`r`n"
        $bodyBytes = $enc.GetBytes($bodyStr)

        Invoke-RestMethod -Uri $DiscordWebhookURL -Method Post -Body $bodyBytes `
            -ContentType "multipart/form-data; boundary=$boundary" | Out-Null
        Write-Host "  [OK] File log allegato su Discord!" -ForegroundColor Green
    }
    catch {
        Write-Host "  [!] Impossibile allegare il file log" -ForegroundColor Yellow
    }
}

# ============================================================
#  RIEPILOGO FINALE GRAFICO
# ============================================================

function Show-FinalReport {
    param([int]$TotalAlerts)

    $duration = [math]::Round(((Get-Date) - $script:ScanStartTime).TotalSeconds)

    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor White
    Write-Host "                     RIEPILOGO FINALE                        " -ForegroundColor White
    Write-Host "  ==========================================================" -ForegroundColor White
    Write-Host ""

    # Moduli
    foreach ($mr in $script:ModuleResults) {
        $mrName = $mr.Name
        $mrAlerts = $mr.Alerts
        if ($mrAlerts -eq 0) {
            Write-Host "     [OK] $mrName" -ForegroundColor Green
        } else {
            Write-Host "     [!!] $mrName - $mrAlerts alert trovati" -ForegroundColor Red
        }
    }

    Write-Host ""
    Write-Host "  ----------------------------------------------------------" -ForegroundColor White

    # Verdetto
    if ($TotalAlerts -eq 0) {
        Write-Host ""
        Write-Host "     VERDETTO: " -ForegroundColor White -NoNewline
        Write-Host "PULITO" -ForegroundColor Green
        Write-Host "     Nessuna traccia sospetta trovata" -ForegroundColor Green
    } elseif ($TotalAlerts -le 3) {
        Write-Host ""
        Write-Host "     VERDETTO: " -ForegroundColor White -NoNewline
        Write-Host "SOSPETTO BASSO ($TotalAlerts alert)" -ForegroundColor Yellow
        Write-Host "     Pochi elementi, verificare manualmente" -ForegroundColor Yellow
    } elseif ($TotalAlerts -le 10) {
        Write-Host ""
        Write-Host "     VERDETTO: " -ForegroundColor White -NoNewline
        Write-Host "SOSPETTO MEDIO ($TotalAlerts alert)" -ForegroundColor Yellow
        Write-Host "     Diversi elementi sospetti trovati" -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "     VERDETTO: " -ForegroundColor White -NoNewline
        Write-Host "SOSPETTO ALTO ($TotalAlerts alert)" -ForegroundColor Red
        Write-Host "     Molti elementi sospetti trovati!" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "     Durata scansione: ${duration} secondi" -ForegroundColor White
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor White
}

# ============================================================
#  MAIN
# ============================================================

Clear-Host
Show-Banner

if (-not (Test-IsAdmin)) {
    Write-Host "  [!] Non sei admin - alcuni controlli saranno limitati" -ForegroundColor Yellow
    Write-Host "  [!] Per scansione completa: tasto destro -> Esegui come Admin" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "  Log: $OutputPath" -ForegroundColor DarkGray
Write-Host ""

# Init log file
Set-Content -Path $OutputPath -Value "MC Anti-Cheat Scanner v2.5 - FULL EDITION"
Add-Content -Path $OutputPath -Value "Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Content -Path $OutputPath -Value ("=" * 60)

# Definizione moduli
$modules = @(
    @{ Name = "Info Sistema";         Func = { Scan-SystemInfo } ;                    IsInfo = $true },
    @{ Name = "Directory Minecraft";  Func = { Scan-MinecraftDirectories } ;          IsInfo = $false },
    @{ Name = "File Nascosti";        Func = { Scan-HiddenFiles } ;                  IsInfo = $false },
    @{ Name = "Temp / AppData";       Func = { Scan-TempAppData } ;                  IsInfo = $false },
    @{ Name = "Processi Attivi";      Func = { Scan-Processes } ;                    IsInfo = $false },
    @{ Name = "Cronologia Browser";   Func = { Scan-AllBrowsers } ;                  IsInfo = $false },
    @{ Name = "Downloads + Zone ID";  Func = { Scan-Downloads } ;                    IsInfo = $false },
    @{ Name = "DNS Cache";            Func = { Scan-DNS } ;                          IsInfo = $false },
    @{ Name = "Prefetch";             Func = { Scan-Prefetch } ;                     IsInfo = $false },
    @{ Name = "Cestino";              Func = { Scan-RecycleBin } ;                   IsInfo = $false },
    @{ Name = "File Recenti + ADS";   Func = { Scan-RecentFiles } ;                 IsInfo = $false },
    @{ Name = "Programmi Installati"; Func = { Scan-Programs } ;                     IsInfo = $false },
    @{ Name = "Avvio Automatico";     Func = { Scan-Startup } ;                     IsInfo = $false },
    @{ Name = "Task + Hosts";         Func = { Scan-TasksHosts } ;                  IsInfo = $false },
    @{ Name = "Cartelle Utente";      Func = { Scan-UserFolders } ;                 IsInfo = $false }
)

$totalAlerts = 0
$sysInfo = @{}

for ($i = 0; $i -lt $modules.Count; $i++) {
    $mod = $modules[$i]

    Show-ProgressModule -Current ($i + 1) -Total $modules.Count -ModuleName $mod.Name

    if ($mod.IsInfo) {
        $sysInfo = & $mod.Func
        Show-ModuleResult -ModuleName $mod.Name -Alerts 0
    }
    else {
        $alerts = & $mod.Func
        $totalAlerts += $alerts
        Show-ModuleResult -ModuleName $mod.Name -Alerts $alerts
    }
}

# Log finale
Add-Content -Path $OutputPath -Value "`n$("=" * 60)`nTOTALE ALERT: $totalAlerts`n$("=" * 60)"

# Riepilogo grafico
Show-FinalReport -TotalAlerts $totalAlerts

# Invio Discord
Send-DiscordReport -SystemInfo $sysInfo -TotalAlerts $totalAlerts `
    -ModuleResults $script:ModuleResults -AllAlerts $script:AllAlerts

Write-Host ""
Write-Host "  Log salvato: $OutputPath" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Premi un tasto per uscire..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
