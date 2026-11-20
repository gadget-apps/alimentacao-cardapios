param([Parameter(Mandatory=$true)][ValidateRange(1,4)][int]$Semana)
$src = Join-Path $PSScriptRoot "listas\compras-semana-$Semana-keep.txt"
if (-not (Test-Path $src)) { throw "Arquivo nao encontrado: $src" }
$destRoot = $null
Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Removable' } | ForEach-Object {
  $c = "$($_.DriveLetter):\Download"
  if (-not (Test-Path $c)) { $c = "$($_.DriveLetter):\" }
  if (Test-Path $c) { $destRoot = $c }
}
if (-not $destRoot) {
  Write-Host "Celular nao montado como pasta. Use MTP (Transferencia de arquivos) ou cole no Keep."
  Write-Host $src
  exit 1
}
Copy-Item -Force $src (Join-Path $destRoot (Split-Path $src -Leaf))
Write-Host "OK"