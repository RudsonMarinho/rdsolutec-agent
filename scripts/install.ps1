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

# ===== PROGRAMAS =====
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

# ===== FORM (ESTILO INSTALADOR) =====
$form = New-Object System.Windows.Forms.Form
$form.Text = "RD Solutec - Instalador de Programas"
$form.Size = New-Object System.Drawing.Size(600,500)
$form.StartPosition = "CenterScreen"
$form.BackColor = "White"

# ===== HEADER =====
$header = New-Object System.Windows.Forms.Label
$header.Text = "Instalador de Programas"
$header.Font = New-Object System.Drawing.Font("Segoe UI",14,[System.Drawing.FontStyle]::Bold)
$header.AutoSize = $true
$header.Location = New-Object System.Drawing.Point(20,10)
$form.Controls.Add($header)

# ===== LISTA =====
$checkList = New-Object System.Windows.Forms.CheckedListBox
$checkList.Size = New-Object System.Drawing.Size(550,200)
$checkList.Location = New-Object System.Drawing.Point(20,50)

foreach ($p in $programas) { $checkList.Items.Add($p.nome) }
$form.Controls.Add($checkList)

# ===== BOTÕES COLORIDOS =====
$btnSelecionar = New-Object System.Windows.Forms.Button
$btnSelecionar.Text = "Selecionar Todos"
$btnSelecionar.BackColor = "#0078D7"
$btnSelecionar.ForeColor = "White"
$btnSelecionar.Size = New-Object System.Drawing.Size(180,40)
$btnSelecionar.Location = New-Object System.Drawing.Point(20,270)

$btnSelecionar.Add_Click({
    for ($i=0; $i -lt $checkList.Items.Count; $i++) {
        $checkList.SetItemChecked($i, $true)
    }
})
$form.Controls.Add($btnSelecionar)

$btnInstalar = New-Object System.Windows.Forms.Button
$btnInstalar.Text = "Instalar Selecionados"
$btnInstalar.BackColor = "#28A745"
$btnInstalar.ForeColor = "White"
$btnInstalar.Size = New-Object System.Drawing.Size(180,40)
$btnInstalar.Location = New-Object System.Drawing.Point(210,270)
$form.Controls.Add($btnInstalar)

$btnTodos = New-Object System.Windows.Forms.Button
$btnTodos.Text = "Instalar Todos"
$btnTodos.BackColor = "#28A745"
$btnTodos.ForeColor = "White"
$btnTodos.Size = New-Object System.Drawing.Size(180,40)
$btnTodos.Location = New-Object System.Drawing.Point(400,270)
$form.Controls.Add($btnTodos)

# ===== STATUS =====
$status = New-Object System.Windows.Forms.Label
$status.Size = New-Object System.Drawing.Size(550,30)
$status.Location = New-Object System.Drawing.Point(20,320)
$status.Text = "Aguardando..."
$form.Controls.Add($status)

# ===== PROGRESS REAL =====
$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Size = New-Object System.Drawing.Size(550,30)
$progress.Location = New-Object System.Drawing.Point(20,360)
$form.Controls.Add($progress)

# ===== DOWNLOAD COM PROGRESSO REAL =====
function Download-File($url, $destino) {
    $webClient = New-Object System.Net.WebClient

    $webClient.DownloadProgressChanged += {
        $progress.Value = $_.ProgressPercentage
        $status.Text = "Baixando... $($_.ProgressPercentage)%"
        $form.Refresh()
    }

    $webClient.DownloadFileAsync($url, $destino)

    while ($webClient.IsBusy) {
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 100
    }
}

# ===== INSTALAÇÃO =====
function Instalar($lista) {
    $btnInstalar.Enabled = $false
    $btnTodos.Enabled = $false

    foreach ($item in $lista) {
        $prog = $programas | Where-Object { $_.nome -eq $item }
        if ($null -eq $prog) { continue }

        $caminho = "$base\$($prog.arquivo)"

        try {
            if (-not (Test-Path $caminho)) {
                Download-File $prog.url $caminho
            }

            $status.Text = "Instalando $($prog.nome)..."
            $form.Refresh()

            if ($prog.tipo -eq "msi") {
                Start-Process "msiexec.exe" -ArgumentList "/i `"$caminho`" /qn /norestart" -Wait
            } else {
                Start-Process $caminho -ArgumentList "/S" -Wait
            }

            Remove-Item $caminho -Force -ErrorAction SilentlyContinue

        } catch {
            $status.Text = "Erro: $($_.Exception.Message)"
        }
    }

    $status.Text = "Concluído!"
    $progress.Value = 100

    $btnInstalar.Enabled = $true
    $btnTodos.Enabled = $true
}

# ===== EVENTOS =====
$btnInstalar.Add_Click({
    if ($checkList.CheckedItems.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Selecione pelo menos um programa")
        return
    }
    Instalar $checkList.CheckedItems
})

$btnTodos.Add_Click({ Instalar ($programas.nome) })

# ===== EXEC =====
$form.ShowDialog()
