$downloadUrl = https://github.com/RudsonMarinho/rdsolutec-agent/releases/latest/download/agent.exe
$destino = "$env:ProgramData\RDSolutec\agent.exe"

Invoke-WebRequest -Uri $downloadUrl -OutFile $destino

Start-Process -FilePath $arquivo -Wait


Write-Host "================================="
Write-Host " RD SOLUTEC - INSTALADOR"
Write-Host "================================="

$destino = "$env:ProgramData\RDSolutec"
$arquivo = "$destino\agent.exe"
$url = https://github.com/RudsonMarinho/rdsolutec-agent/releases/latest/download/agent.exe

# Criar pasta
if (!(Test-Path $destino)) {
    New-Item -ItemType Directory -Path $destino | Out-Null
}

# LOG
$log = "$destino\install.log"
"Inicio: $(Get-Date)" | Out-File $log -Append

Write-Host "[1/3] Baixando agente..."
Invoke-WebRequest -Uri $url -OutFile $arquivo

"Download concluído: $(Get-Date)" | Out-File $log -Append

if (Test-Path $arquivo) {

    Write-Host "[2/3] Instalando..."
    
    $processo = Start-Process -FilePath $arquivo -ArgumentList "/silent" -PassThru

    while (!$processo.HasExited) {
        Write-Host "Instalando..." -NoNewline "`r"
        Start-Sleep -Seconds 2
    }

    "Instalação concluída: $(Get-Date)" | Out-File $log -Append

    Write-Host "`n[3/3] Finalizado!"
    Write-Host "✔ Instalação concluída com sucesso!"

} else {
    Write-Host "❌ Erro ao baixar o agente"
    "Erro no download: $(Get-Date)" | Out-File $log -Append
}
