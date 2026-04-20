Write-Host "================================="
Write-Host " RD SOLUTEC - INSTALADOR"
Write-Host "================================="

$base = "$env:ProgramData\RDSolutec"
if (!(Test-Path $base)) {
    New-Item -ItemType Directory -Path $base -Force | Out-Null
}

# LISTA DE PROGRAMAS
$programas = @(
    @{ id=1; nome="AnyDesk"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/AnyDesk.exe"; arquivo="AnyDesk.exe"; tipo="exe" },
    @{ id=2; nome="Google Chrome"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/ChromeSetup.exe"; arquivo="ChromeSetup.exe"; tipo="exe" },
    @{ id=3; nome="Componente CTE"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/componente_cte_5.00b.exe"; arquivo="cte.exe"; tipo="exe" },
    @{ id=4; nome="Instalador Genérico"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/instalador.exe"; arquivo="instalador.exe"; tipo="exe" },
    @{ id=5; nome="LibreOffice"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/LibreOffice_24.8.4_Win_x86-64.msi"; arquivo="libreoffice.msi"; tipo="msi" },
    @{ id=6; nome="Microsoft Office 2024"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/microsoft-office-2024-16-0-18025-20140.exe"; arquivo="office.exe"; tipo="exe" },
    @{ id=7; nome="Panda Free Antivirus"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/PANDAFREEAV.exe"; arquivo="panda.exe"; tipo="exe" },
    @{ id=8; nome="Adobe Reader"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/Reader_br_install.exe"; arquivo="reader.exe"; tipo="exe" },
    @{ id=9; nome="Zoom"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/ZoomInstallerFull.exe"; arquivo="zoom.exe"; tipo="exe" }
)

# MENU
Write-Host ""
Write-Host "Selecione os programas para instalar:"
Write-Host "(Ex: 1,3,5 ou 0 para TODOS)"
Write-Host ""

foreach ($p in $programas) {
    Write-Host "$($p.id) - $($p.nome)"
}

Write-Host "0 - Instalar TODOS"
Write-Host ""

$escolha = Read-Host "Digite sua opção"

# PROCESSAR ESCOLHA
if ($escolha -eq "0") {
    $selecionados = $programas
} else {
    $ids = $escolha -split "," | ForEach-Object { $_.Trim() }
    $selecionados = $programas | Where-Object { $ids -contains $_.id.ToString() }
}

# INSTALAÇÃO
foreach ($prog in $selecionados) {
    $caminho = Join-Path $base $prog.arquivo
    
    Write-Host ""
    Write-Host "---------------------------------"
    Write-Host "Baixando $($prog.nome)..."

    try {
        Invoke-WebRequest -Uri $prog.url -OutFile $caminho -ErrorAction Stop
        
        if (Test-Path $caminho) {
            Write-Host "Abrindo instalador de $($prog.nome)..."
            
            if ($prog.tipo -eq "msi") {
                Start-Process "msiexec.exe" -ArgumentList "/i `"$caminho`" /passive" -Wait
            } else {
                Start-Process $caminho -Wait
            }
            Write-Host "✔ $($prog.nome) finalizado!"
        } else {
            Write-Host "❌ Erro: Arquivo não encontrado."
        }
    } catch {
        Write-Host "❌ Falha em $($prog.nome): $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "================================="
Write-Host "✔ Processo finalizado!"
Write-Host "================================="

Read-Host "Pressione ENTER para sair"
