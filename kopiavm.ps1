# SprawdÅº czy 7-Zip jest dostÄ™pny
function Check-7Zip {
    return (Get-Command "7z.exe" -ErrorAction SilentlyContinue) -ne $null
}

$has7zip = Check-7Zip

if (-not $has7zip) {
    Write-Host "  7-Zip (7z.exe) nie jest dostepny w PATH. Kompresja zostanie pominieta." -ForegroundColor Yellow
}

# Pobierz wszystkie maszyny wirtualne
$allVMs = Get-VM
$selectedVMs = $allVMs | Out-GridView -Title "Wybierz maszyny do eksportu" -PassThru

if (-not $selectedVMs) {
    Write-Host "Nie wybrano zadnych maszyn. Zakonczono." -ForegroundColor Yellow
    exit
}

# ÅšcieÅ¼ka docelowa
$destinationPath = Read-Host "Podaj sciezka docelowa dla eksportu (np. D:\VMExport)"
if (-not (Test-Path $destinationPath)) {
    Write-Host "Tworze katalog $destinationPath" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
}

# Eksport i kompresja
foreach ($vm in $selectedVMs) {
    $vmExportPath = Join-Path -Path $destinationPath -ChildPath $vm.Name
    Write-Host "Eksportuję: $($vm.Name) -> $vmExportPath" -ForegroundColor Green
    Export-VM -Name $vm.Name -Path $vmExportPath

    if ($has7zip) {
        $zipPath = "$vmExportPath.7z"
        Write-Host "Kompresuje do: $zipPath" -ForegroundColor Cyan
        & 7z a -t7z -mx=9 $zipPath "$vmExportPath\*" | Out-Null
        Write-Host "Skompresowano do $zipPath" -ForegroundColor Green

        # (Opcjonalnie) usuÅ„ oryginalny folder po kompresji
        # Remove-Item -Path $vmExportPath -Recurse -Force
    }
}