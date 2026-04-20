Write-Host "================================="
Write-Host " RD SOLUTEC - INSTALAÇÃO AUTOMÁTICA"
Write-Host "================================="

$base = "$env:ProgramData\RDSolutec"
New-Item -ItemType Directory -Path $base -Force | Out-Null

$programas = @(
    @{ nome="AnyDesk"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/AnyDesk.exe"; arquivo="AnyDesk.exe"; tipo="exe" },
    @{ nome="Google Chrome"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/ChromeSetup.exe"; arquivo="ChromeSetup.exe"; tipo="exe" },
    @{ nome="CTE"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/componente_cte_5.00b.exe"; arquivo="cte.exe"; tipo="exe" },
    @{ nome="Instalador Genérico"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/instalador.exe"; arquivo="instalador.exe"; tipo="exe" },
    @{ nome="LibreOffice"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/LibreOffice_24.8.4_Win_x86-64.msi"; arquivo="libreoffice.msi"; tipo="msi" },
    @{ nome="Office 2024"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/microsoft-office-2024-16-0-18025-20140.exe"; arquivo="office.exe"; tipo="exe" },
    @{ nome="Panda AV"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/PANDAFREEAV.exe"; arquivo="panda.exe"; tipo="exe" },
    @{ nome="Adobe Reader"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/Reader_br_install.exe"; arquivo="reader.exe"; tipo="exe" },
    @{ nome="Zoom"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/ZoomInstallerFull.exe"; arquivo="zoom.exe"; tipo="exe" }
)

$total = $programas.Count
$contador = 1

foreach ($prog in $programas) {

    $caminho = "$base\$($prog.arquivo)"

    Write-Host ""
    Write-Host "[$contador/$total] Baixando $($prog.nome)..."

    try {
        Invoke-WebRequest -Uri $prog.url -OutFile $caminho -ErrorAction Stop

        if (Test-Path $caminho) {

            Write-Host "Instalando $($prog.nome)..."

            if ($prog.tipo -eq "msi") {
                Start-Process "msiexec.exe" -ArgumentList "/i `"$caminho`"" -Wait
            } else {
                Start-Process $caminho -Wait
            }

            Write-Host "✔ $($prog.nome) finalizado!"
        }
        else {
            Write-Host "❌ Falha no download: $($prog.nome)"
        }

    }
    catch {
        Write-Host "❌ Erro em $($prog.nome): $_"
    }

    $contador++
}

Write-Host ""
Write-Host "================================="
Write-Host "✔ INSTALAÇÃO COMPLETA FINALIZADA"
Write-Host "================================="

Read-Host "Pressione ENTER para sair"
