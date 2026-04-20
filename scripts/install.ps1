Write-Host "RD SOLUTEC - INSTALADOR"

$base = "$env:ProgramData\RDSolutec"
New-Item -ItemType Directory -Path $base -Force | Out-Null

$programas = @(
    @{ id=1; nome="AnyDesk"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/AnyDesk.exe"; arquivo="AnyDesk.exe"; tipo="exe" },
    @{ id=2; nome="Google Chrome"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/ChromeSetup.exe"; arquivo="ChromeSetup.exe"; tipo="exe" },
    @{ id=3; nome="CTE"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/componente_cte_5.00b.exe"; arquivo="cte.exe"; tipo="exe" },
    @{ id=4; nome="LibreOffice"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/LibreOffice_24.8.4_Win_x86-64.msi"; arquivo="libreoffice.msi"; tipo="msi" },
    @{ id=5; nome="Office 2024"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/microsoft-office-2024-16-0-18025-20140.exe"; arquivo="office.exe"; tipo="exe" },
    @{ id=6; nome="Panda AV"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/PANDAFREEAV.exe"; arquivo="panda.exe"; tipo="exe" },
    @{ id=7; nome="Adobe Reader"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/Reader_br_install.exe"; arquivo="reader.exe"; tipo="exe" },
    @{ id=8; nome="Zoom"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/ZoomInstallerFull.exe"; arquivo="zoom.exe"; tipo="exe" }
)

Write-Host ""
Write-Host "Escolha os programas (ex: 1,3,5 ou 0 para todos):"

foreach ($p in $programas) {
    Write-Host "$($p.id) - $($p.nome)"
}

Write-Host "0 - Todos"
$input = Read-Host "Opção"

if ($input -eq "0") {
    $selecionados = $programas
} else {
    $ids = $input -split "," | ForEach-Object { $_.Trim() }
    $selecionados = $programas | Where-Object { $ids -contains $_.id.ToString() }
}

foreach ($prog in $selecionados) {

    $caminho = "$base\$($prog.arquivo)"

    Write-Host "Baixando $($prog.nome)..."

    try {
        Invoke-WebRequest -Uri $prog.url -OutFile $caminho

        if (Test-Path $caminho) {

            Write-Host "Executando $($prog.nome)..."

            if ($prog.tipo -eq "msi") {
                Start-Process "msiexec.exe" -ArgumentList "/i `"$caminho`"" -Wait
            } else {
                Start-Process $caminho -Wait
            }

            Write-Host "OK - $($prog.nome)"
        }

    } catch {
        Write-Host "ERRO - $($prog.nome)"
    }
}

Write-Host "FINALIZADO"
Read-Host "Pressione ENTER"
