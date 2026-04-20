$downloadUrl = "https://github.com/RudsonMarinho/rdsolutec-agent/releases/latest/download/agent.exe"
$destino = "$env:ProgramData\RDSolutec\agent.exe"

Invoke-WebRequest -Uri $downloadUrl -OutFile $destino

Start-Process -FilePath $destino -ArgumentList "/silent" -Wait
