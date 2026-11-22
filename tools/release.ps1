# 릴리즈 묶음 만들기(로컬만). GitHub에 올리는 일은 하지 않는다.
#
#   powershell -ExecutionPolicy Bypass -File tools/release.ps1 [-SkipBuild]
#
# 만드는 것(dist/):
#   WXCore/                 클라이언트 폴더(Release exe·DLL·동봉 코어, config/, formats/)
#   WXCore-<버전>.zip        업데이트용(사용자 덱 폴더 없음). update.json이 가리킨다
#   WXCore-<버전>-full.zip   처음 설치용(예시 덱 포함)
#   update.json             {"version", "files":[{name,url,md5}]}  → 릴리즈 자산으로 올린다
#   repo_core/bin/          코어 저장소(WXCore_Core)에 올릴 wxcore.dll
#   repo_carddb/            카드 DB 저장소(WXCore_CardDB)에 올릴 wixoss.db·script/·formats/
# 버전은 CMakeLists.txt의 project(VERSION)
param([switch]$SkipBuild)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = Split-Path $PSScriptRoot -Parent
$owner = 'pendulums58'
$ver = (Select-String -Path "$root\CMakeLists.txt" -Pattern 'project\(wxcore VERSION ([0-9.]+)').Matches[0].Groups[1].Value
Write-Host "버전 $ver"

if (-not $SkipBuild) {
  $vs = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath
  $cm = (Get-ChildItem "$vs\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe").FullName
  & $cm --preset msvc
  if ($LASTEXITCODE -ne 0) { throw 'configure 실패' }
  & $cm --build --preset release
  if ($LASTEXITCODE -ne 0) { throw '빌드 실패' }
}
$bin = "$root\build\msvc\frame\Release"
if (-not (Test-Path "$bin\wx_frame.exe")) { throw "Release 빌드가 없다: $bin" }

$dist = "$root\dist"
if (Test-Path $dist) { Remove-Item -Recurse -Force $dist }
New-Item -ItemType Directory -Force $dist | Out-Null

# ── 클라이언트 ──
$client = "$dist\WXCore"
New-Item -ItemType Directory -Force "$client\config", "$client\formats" | Out-Null
Copy-Item "$bin\wx_frame.exe", "$bin\*.dll" $client
Copy-Item "$root\formats\*.lua" "$client\formats"
# 업데이트 주소를 채운다(최신 릴리즈의 update.json)
$cfg = Get-Content "$root\config\configs.json" -Raw -Encoding UTF8
$cfg = $cfg -replace '"update_url":\s*"[^"]*"', ('"update_url": "https://github.com/' + $owner + '/WXCore/releases/latest/download/update.json"')
[IO.File]::WriteAllText("$client\config\configs.json", $cfg, (New-Object Text.UTF8Encoding $false))

$zip = "WXCore-$ver.zip"
[IO.Compression.ZipFile]::CreateFromDirectory($client, "$dist\$zip")
# 처음 설치용: 예시 덱 포함
New-Item -ItemType Directory -Force "$client\decks" | Out-Null
Copy-Item "$root\decks\*.json" "$client\decks"
[IO.Compression.ZipFile]::CreateFromDirectory($client, "$dist\WXCore-$ver-full.zip")

$md5 = (Get-FileHash -Algorithm MD5 "$dist\$zip").Hash.ToLower()
$update = @{
  version = $ver
  files = @(@{ name = $zip; url = "https://github.com/$owner/WXCore/releases/download/v$ver/$zip"; md5 = $md5 })
} | ConvertTo-Json -Depth 4
[IO.File]::WriteAllText("$dist\update.json", $update, (New-Object Text.UTF8Encoding $false))

# ── 코어 저장소 ──
New-Item -ItemType Directory -Force "$dist\repo_core\bin" | Out-Null
Copy-Item "$bin\wxcore.dll" "$dist\repo_core\bin"

# ── 카드 DB 저장소 ──
$db = "$dist\repo_carddb"
New-Item -ItemType Directory -Force "$db\script", "$db\formats" | Out-Null
Copy-Item "$root\wixoss.db" $db
Copy-Item "$root\script\*.lua" "$db\script"
Copy-Item "$root\formats\*.lua" "$db\formats"

Write-Host "완료: $dist"
Write-Host "  $zip (md5 $md5)"
Write-Host "  WXCore-$ver-full.zip, update.json, repo_core\, repo_carddb\"
