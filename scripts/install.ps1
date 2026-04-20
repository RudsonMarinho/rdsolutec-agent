Write-Host "================================="
Write-Host " RD SOLUTEC - INSTALADOR CTE"
Write-Host "================================="

# CONFIGURAÇÕES
$destino = "$env:ProgramData\RDSolutec"
$arquivo = "$destino\componente_cte_5.00b.exe"

# 🔗 LINK CORRETO (RELEASES)
$url = "https://github.com/RudsonMarinho/rdsolutec-agent/releases/latest/download/componente_cte_5.00b.exe"

# Criar pasta
if (!(Test-Path $destino)) {
    New-Item -ItemType Directory -Path $destino | Out-Null
}

# LOG
$log = "$destino\install.log"
"Inicio: $(Get-Date)" | Out-File $log -Append

try {
    Write-Host "[1/3] Baixando componente CTE..."
    
    Invoke-WebRequest -Uri $url -OutFile $arquivo -ErrorAction Stop

    if (Test-Path $arquivo) {

        Write-Host "[2/3] Executando instalador..."

        # 🔹 MODO VISUAL (SEM /silent)
        $processo = Start-Process -FilePath $arquivo -PassThru

        while (!$processo.HasExited) {
            Write-Host "Instalando componente CTE..." -NoNewline "`r"
            Start-Sleep -Seconds 2
        }

        Write-Host "`n[3/3] Finalizado com sucesso!"
        "Instalação concluída: $(Get-Date)" | Out-File $log -Append

    } else {
        Write-Host "❌ Erro: arquivo não foi baixado"
        "Erro download: $(Get-Date)" | Out-File $log -Append
    }

} catch {
    Write-Host "❌ Erro durante instalação: $_"
    "Erro geral: $(Get-Date)" | Out-File $log -Append
}
