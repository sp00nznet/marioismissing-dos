<#
  setup.ps1 - the Quick start (README, Getting Started). Setup.cmd runs this.

  From a plain download to a "Mario Is Missing" shortcut in this folder:
    1. check the tools (Python 3, CMake, Git, Visual Studio 2022 C++ build
       tools) and offer to install what is missing
    2. copy your CD's MARIO folder into original\mim
    3. fetch the pcrecomp toolkit next to this folder, at the tested commit
    4. lift MARIO.BIN to C (tools\lift.py mim)
    5. build with CMake/MSVC and run the self-test
    6. put a shortcut in this folder

  Every step is skipped when its result is already there (-Force redoes the
  lift), so running it again after a failure carries on. Details go to
  setup.log. It runs exactly the commands README "Step by step" lists.

  Nothing from the game is downloaded or bundled: the files come from your own
  disc, and everything generated from them stays in work\ and build\.

    -GameDir <drive or folder>   the CD (E:\), its MARIO folder, or a copy of it
    -Yes                         answer yes to every install question

  Under recomp-launcher (RECOMP_LAUNCHER=1) it never waits for Enter.
#>
param([string]$GameDir = "", [switch]$Yes, [switch]$Force)
$ErrorActionPreference = "Stop"
$Root = Split-Path $PSScriptRoot -Parent
Set-Location $Root
$Log = Join-Path $Root "setup.log"
"=== setup $(Get-Date -Format s)" | Out-File $Log -Encoding utf8

# The toolkit commit this game was last lifted, built and run against
# (README, "Building from source"). A commit, not a branch: main moves.
$PcrecompUrl = "https://github.com/sp00nznet/pcrecomp.git"
$PcrecompRef = "ef3f0da6e08a8eb7a3f869273f3df071ca8d7373"

function Say($m) { Write-Host $m; $m | Out-File $Log -Append -Encoding utf8 }
function Fail($m) {
    Write-Host ""
    Write-Host "Setup stopped: $m" -ForegroundColor Red
    Write-Host "Details are in $Log. Fix that and run Setup.cmd again; finished steps are skipped."
    if (-not $Yes -and $env:RECOMP_LAUNCHER -ne "1") { Read-Host "Press Enter to close" | Out-Null }
    exit 1
}
trap { Fail "$_" }
function Run($what, [scriptblock]$cmd) {
    Say "  $what"
    # native tools write progress to stderr; under "Stop" PowerShell 5.1 would
    # turn every such line into a terminating error
    $ErrorActionPreference = "Continue"
    $out = & $cmd 2>&1
    $code = $LASTEXITCODE
    $ErrorActionPreference = "Stop"
    $out | Out-File $Log -Append -Encoding utf8
    if ($code -ne 0) { Fail "$what failed (exit code $code)." }
}
function Ask($q) {
    if ($Yes) { Say "$q yes"; return $true }
    $a = Read-Host "$q [y/N]"
    return $a -match '^(y|yes)$'
}
function Have($exe) { return [bool](Get-Command $exe -ErrorAction SilentlyContinue) }

Say "Mario Is Missing! CD-ROM Deluxe (DOS): static recompilation setup"
Say "You need your own copy of the CD-ROM Deluxe disc (or a copy of its MARIO folder) and about 1 GB free."

# ---- 1. tools ---------------------------------------------------------------
Say "[1/6] Checking the tools"
# `python` may be the Microsoft Store alias that only opens the Store; the py
# launcher is what a python.org install puts on PATH.
function Find-Py {
    if (Have "py") { return "py" }
    if ((Have "python") -and ((& python --version 2>&1) -match "Python 3")) { return "python" }
    return $null
}
$py = Find-Py
$need = @()
if (-not $py) { $need += @{ name = "Python 3"; id = "Python.Python.3.12"; size = "about 30 MB"; why = "runs the lifter (tools\lift.py)" } }
if (-not (Have "cmake")) { $need += @{ name = "CMake"; id = "Kitware.CMake"; size = "about 35 MB"; why = "configures the build" } }
if (-not (Have "git")) { $need += @{ name = "Git"; id = "Git.Git"; size = "about 60 MB"; why = "fetches the pcrecomp toolkit" } }
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vs = if (Test-Path $vswhere) { & $vswhere -latest -version "[17.0,18.0)" -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath } else { $null }
if (-not $vs) { $need += @{ name = "Visual Studio 2022 Build Tools (C++)"; id = "Microsoft.VisualStudio.2022.BuildTools"; size = "about 2 GB"; why = "compiles the lifted C"; args = "--override `"--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended`"" } }

foreach ($n in $need) {
    Say "Missing: $($n.name), needed because it $($n.why). Download: $($n.size)."
    if (-not (Have "winget")) { Fail "Install $($n.name) yourself (winget is not available), then run Setup again." }
    if (-not (Ask "Install $($n.name) now with winget?")) { Fail "Setup needs $($n.name). Install it and run Setup again." }
    $wargs = @("install", "--id", $n.id, "-e", "--accept-package-agreements", "--accept-source-agreements")
    if ($n.args) { $wargs += $n.args }
    Run "installing $($n.name)" { winget @wargs }
}
if ($need.Count) {
    # a fresh install is on the machine PATH but not in this window's
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
    $py = Find-Py
    if (-not $py) { Fail "Python installed, but this window can't see it. Close it and run Setup.cmd again." }
}
Say "  Python: $py"

# ---- 2. the game ------------------------------------------------------------------
Say "[2/6] Copying your game into original\mim"
$dest = Join-Path $Root "original\mim"
# A folder is the game when MARIO.BIN is in it; the CD keeps it in \MARIO.
function Game-Folder($p) {
    if (-not $p) { return $null }
    foreach ($c in @($p, (Join-Path $p "MARIO"))) { if (Test-Path (Join-Path $c "MARIO.BIN")) { return $c } }
    return $null
}
if (Test-Path (Join-Path $dest "MARIO.BIN")) {
    Say "  already copied."
} else {
    $src = Game-Folder $GameDir
    if (-not $src) {
        # every drive's \MARIO: the disc, or a mounted image
        foreach ($d in (Get-PSDrive -PSProvider FileSystem)) { $src = Game-Folder $d.Root; if ($src) { break } }
    }
    if (-not $src -and -not $Yes -and $env:RECOMP_LAUNCHER -ne "1") {
        $src = Game-Folder (Read-Host "Where is the game? (the CD's drive, or the folder holding MARIO.BIN)")
    }
    if (-not $src) { Fail "MARIO.BIN was not found. Insert the CD-ROM Deluxe disc (or mount its image) and run Setup again, or give -GameDir <folder holding MARIO.BIN>." }
    Say "  copying from $src"
    New-Item -ItemType Directory -Force $dest | Out-Null
    # all of it: the data files, the voices and the VIDEO folder
    Copy-Item -Path (Join-Path $src "*") -Destination $dest -Recurse -Force
}

# ---- 3. the toolkit ----------------------------------------------------------------
Say "[3/6] Fetching the pcrecomp toolkit"
if ($env:PCRECOMP_HOME -and (Test-Path "$env:PCRECOMP_HOME\tools\lift\lift16.py")) {
    $pcr = $env:PCRECOMP_HOME
} else {
    $pcr = Join-Path (Split-Path $Root -Parent) "pcrecomp"
    if (-not (Test-Path "$pcr\tools\lift\lift16.py")) {
        Run "fetching pcrecomp into $pcr (about 20 MB)" { git clone --quiet $PcrecompUrl $pcr }
        Run "checking out pcrecomp $($PcrecompRef.Substring(0, 7))" { git -C $pcr checkout --quiet $PcrecompRef }
    } else {
        # someone's existing checkout: used as it is, never switched
        Say "  using your checkout at $pcr (tested with $($PcrecompRef.Substring(0, 7)))"
    }
}
$pcr = (Resolve-Path $pcr).Path
$env:PCRECOMP_HOME = $pcr

# ---- 4. lift ---------------------------------------------------------------------
Say "[4/6] Lifting MARIO.BIN to C"
if ((Test-Path "work\mim\gen\recomp_dispatch.c") -and -not $Force) {
    Say "  already lifted (work\mim\gen)."
} else {
    Run "py tools\lift.py mim" { & $py tools\lift.py mim }
}

# ---- 5. build ----------------------------------------------------------------------
Say "[5/6] Building (a few minutes)"
Run "configuring" { cmake -B build -A Win32 "-DPCRECOMP_HOME=$pcr" }
Run "compiling" { cmake --build build --config Release -- -m }
$exe = Join-Path $Root "build\Release\marioismissing.exe"
if (-not (Test-Path $exe)) { Fail "The build finished but $exe is missing." }
Run "self-test (the hardware models, no game data)" { & build\Release\selftest.exe }

# ---- 6. shortcut -------------------------------------------------------------------
Say "[6/6] Making the shortcut"
$lnk = (New-Object -ComObject WScript.Shell).CreateShortcut((Join-Path $Root "Mario Is Missing.lnk"))
$lnk.TargetPath = $exe
$lnk.WorkingDirectory = $Root   # it finds original\mim and saves\mim from here
$lnk.Save()
Say "Done. Double-click 'Mario Is Missing' in this folder to play (with the mouse). Alt+Enter toggles fullscreen."
if (-not $Yes -and $env:RECOMP_LAUNCHER -ne "1") { Read-Host "Press Enter to close" | Out-Null }
