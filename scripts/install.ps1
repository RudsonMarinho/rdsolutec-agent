Write-Host "================================="
Write-Host " RD SOLUTEC - INSTALADOR"
Write-Host "================================="

$base = "$env:ProgramData\RDSolutec"
New-Item -ItemType Directory -Path $base -Force | Out-Null

$programas = @(
    @{ id=1; nome="AnyDesk"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/AnyDesk.exe"; arquivo="AnyDesk.exe"; tipo="exe" },
    @{ id=2; nome="Google Chrome"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/ChromeSetup.exe"; arquivo="ChromeSetup.exe"; tipo="exe" },
    @{ id=3; nome="CTE"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/componente_cte_5.00b.exe"; arquivo="cte.exe"; tipo="exe" },
    @{ id=4; nome="TMS NFA Soft"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/instalador.exe"; arquivo="instalador.exe"; tipo="exe" },
    @{ id=5; nome="LibreOffice"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/LibreOffice_24.8.4_Win_x86-64.msi"; arquivo="libreoffice.msi"; tipo="msi" },
    @{ id=6; nome="Office 2024"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/microsoft-office-2024-16-0-18025-20140.exe"; arquivo="office.exe"; tipo="exe" },
    @{ id=7; nome="Panda AV"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/PANDAFREEAV.exe"; arquivo="panda.exe"; tipo="exe" },
    @{ id=8; nome="Adobe Reader"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/Reader_br_install.exe"; arquivo="reader.exe"; tipo="exe" },
    @{ id=9; nome="Zoom"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/ZoomInstallerFull.exe"; arquivo="zoom.exe"; tipo="exe" }
)

function MostrarMenu {
    Write-Host ""
    Write-Host "SELECIONE UM PROGRAMA:"
    foreach ($p in $programas) {
        Write-Host "$($p.id) - $($p.nome)"
    }
    Write-Host "0 - Instalar TODOS"
    Write-Host "S - Sair"
}

function InstalarPrograma {
    param ($prog)

    if ($null -eq $prog) {
        Write-Host "Programa inválido"
        return
    }

    $caminho = "$base\$($prog.arquivo)"

    Write-Host ""
    Write-Host "Baixando $($prog.nome)..."

    try {
        Invoke-WebRequest -Uri $prog.url -OutFile $caminho -ErrorAction Stop

        if (Test-Path $caminho) {

            Write-Host "Executando $($prog.nome)..."

            if ($prog.tipo -eq "msi") {
                Start-Process "msiexec.exe" -ArgumentList "/i `"$caminho`"" -Wait
            }
            else {
                Start-Process $caminho -Wait
            }

            Write-Host "OK - $($prog.nome)"
        }
        else {
            Write-Host "Erro no download"
        }
    }
    catch {
        Write-Host "Erro: $_"
    }
}

while ($true) {

    MostrarMenu

    $opcao = Read-Host "SELECIONE UM PROGRAMA"

    if ($opcao -eq "S" -or $opcao -eq "s") {
        break
    }

    if ($opcao -eq "0") {
        foreach ($p in $programas) {
            InstalarPrograma $p
        }
        continue
    }

    $prog = $programas | Where-Object { $_.id -eq [int]$opcao }

    if ($prog) {
        InstalarPrograma $prog
    }
    else {
        Write-Host "ERRO NA ESCOLHA"
    }
}

Write-Host ""
Write-Host "Finalizado"
Read-Host "Pressione ENTER para sair"
