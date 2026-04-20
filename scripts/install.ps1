Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===== ADMIN CHECK =====
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# ===== CONFIG =====
$base = "$env:ProgramData\RDSolutec"
New-Item -ItemType Directory -Path $base -Force | Out-Null
$log = "$base\install.log"

$programas = @(
    @{ nome="AnyDesk"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/AnyDesk.exe"; arquivo="AnyDesk.exe"; tipo="exe" },
    @{ nome="Google Chrome"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/ChromeSetup.exe"; arquivo="ChromeSetup.exe"; tipo="exe" },
    @{ nome="Componente de CTE"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/componente_cte_5.00b.exe"; arquivo="cte.exe"; tipo="exe" },
    @{ nome="NFA SOFT"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/instalador.exe"; arquivo="instalador.exe"; tipo="exe" },
    @{ nome="Libre Office"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/LibreOffice_24.8.4_Win_x86-64.msi"; arquivo="libreoffice.msi"; tipo="msi" },
    @{ nome="Office 2024"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/microsoft-office-2024-16-0-18025-20140.exe"; arquivo="office.exe"; tipo="exe" },
    @{ nome="Panda AV"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/PANDAFREEAV.exe"; arquivo="panda.exe"; tipo="exe" },
    @{ nome="Adobe Reader"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/Reader_br_install.exe"; arquivo="reader.exe"; tipo="exe" },
    @{ nome="Zoom"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/ZoomInstallerFull.exe"; arquivo="zoom.exe"; tipo="exe" },
    @{ nome="WINRAR"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/winrar-x64-701br.exe"; arquivo="WINRAR.exe"; tipo="exe" },
    @{ nome="Whatsapp"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/WhatsApp.exe"; arquivo="Whatsapp.exe"; tipo="exe" }
)

# ===== FORM =====
$form = New-Object System.Windows.Forms.Form
$form.Text = "RD Solutec - Instalador"
$form.Size = New-Object System.Drawing.Size(600,520)
$form.StartPosition = "CenterScreen"
$form.BackColor = "White"

# ===== LISTA =====
$checkList = New-Object System.Windows.Forms.CheckedListBox
$checkList.Size = New-Object System.Drawing.Size(550,200)
$checkList.Location = New-Object System.Drawing.Point(20,20)

foreach ($p in $programas) { $checkList.Items.Add($p.nome) }
$form.Controls.Add($checkList)

# ===== BOTÕES =====
$btnSelecionar = New-Object System.Windows.Forms.Button
$btnSelecionar.Text = "Selecionar Todos"
$btnSelecionar.BackColor = "#0078D7"
$btnSelecionar.ForeColor = "White"
$btnSelecionar.Location = New-Object System.Drawing.Point(20,240)
$btnSelecionar.Size = New-Object System.Drawing.Size(170,40)

$btnSelecionar.Add_Click({
    for ($i=0; $i -lt $checkList.Items.Count; $i++) {
        $checkList.SetItemChecked($i,$true)
    }
})
$form.Controls.Add($btnSelecionar)

$btnInstalar = New-Object System.Windows.Forms.Button
$btnInstalar.Text = "Instalar Selecionados"
$btnInstalar.BackColor = "#28A745"
$btnInstalar.ForeColor = "White"
$btnInstalar.Location = New-Object System.Drawing.Point(210,240)
$btnInstalar.Size = New-Object System.Drawing.Size(170,40)
$form.Controls.Add($btnInstalar)

$btnTodos = New-Object System.Windows.Forms.Button
$btnTodos.Text = "Instalar Todos"
$btnTodos.BackColor = "#28A745"
$btnTodos.ForeColor = "White"
$btnTodos.Location = New-Object System.Drawing.Point(400,240)
$btnTodos.Size = New-Object System.Drawing.Size(170,40)
$form.Controls.Add($btnTodos)

# ===== STATUS =====
$status = New-Object System.Windows.Forms.Label
$status.Location = New-Object System.Drawing.Point(20,290)
$status.Size = New-Object System.Drawing.Size(550,25)
$status.Text = "Aguardando..."
$form.Controls.Add($status)

# ===== PROGRESS =====
$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Location = New-Object System.Drawing.Point(20,320)
$progress.Size = New-Object System.Drawing.Size(550,20)
$form.Controls.Add($progress)

$progressDownload = New-Object System.Windows.Forms.ProgressBar
$progressDownload.Location = New-Object System.Drawing.Point(20,350)
$progressDownload.Size = New-Object System.Drawing.Size(550,20)
$form.Controls.Add($progressDownload)

$info = New-Object System.Windows.Forms.Label
$info.Location = New-Object System.Drawing.Point(20,380)
$info.Size = New-Object System.Drawing.Size(550,20)
$form.Controls.Add($info)

# ===== DOWNLOAD =====
function Download-File($url,$destino){

    $wc = New-Object System.Net.WebClient
    $lastBytes = 0
    $lastTime = Get-Date

    $wc.DownloadProgressChanged += {
        $progressDownload.Value = $_.ProgressPercentage

        $now = Get-Date
        $elapsed = ($now - $lastTime).TotalSeconds

        if($elapsed -gt 0){
            $bytes = $_.BytesReceived
            $speed = ($bytes - $lastBytes)/$elapsed
            $speedKB = [math]::Round($speed/1KB,2)

            if($speed -gt 0){
                $remaining = ($_.TotalBytesToReceive - $bytes)/$speed
                $eta = [TimeSpan]::FromSeconds($remaining).ToString("mm\:ss")
            } else { $eta = "--:--" }

            $info.Text = "$speedKB KB/s | ETA: $eta"

            $lastBytes = $bytes
            $lastTime = $now
        }

        $form.Refresh()
    }

    $wc.DownloadFileAsync($url,$destino)

    while($wc.IsBusy){
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 100
    }

    $progressDownload.Value = 0
    $info.Text = ""
}

# ===== INSTALAR =====
function Instalar($lista){

    $btnInstalar.Enabled = $false
    $btnTodos.Enabled = $false

    $total = $lista.Count
    $i = 0

    foreach($item in $lista){
        $i++
        $prog = $programas | Where-Object { $_.nome -eq $item }
        if(!$prog){continue}

        $path = "$base\$($prog.arquivo)"

        try{
            $status.Text = "[$i/$total] Baixando $($prog.nome)"
            $form.Refresh()

            if(!(Test-Path $path)){
                Download-File $prog.url $path
            }

            $status.Text = "[$i/$total] Instalando $($prog.nome)"
            $form.Refresh()

            if($prog.tipo -eq "msi"){
                Start-Process msiexec.exe -ArgumentList "/i `"$path`" /qn" -Wait
            } else {
                Start-Process $path -ArgumentList "/S" -Wait
            }

            Remove-Item $path -Force -ErrorAction SilentlyContinue

        } catch {
            $status.Text = "Erro em $($prog.nome)"
        }

        $progress.Value = [int](($i/$total)*100)
    }

    $status.Text = "Concluído!"
    $btnInstalar.Enabled = $true
    $btnTodos.Enabled = $true
}

# ===== EVENTOS =====
$btnInstalar.Add_Click({
    if($checkList.CheckedItems.Count -eq 0){
        [System.Windows.Forms.MessageBox]::Show("Selecione ao menos um programa")
        return
    }
    Instalar $checkList.CheckedItems
})

$btnTodos.Add_Click({
    Instalar ($programas.nome)
})

# ===== EXEC =====
$form.ShowDialog()
