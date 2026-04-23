Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===== CONFIG =====
$base = "$env:ProgramData\RDSolutec"
$logFile = "$base\install.log"

New-Item -ItemType Directory -Path $base -Force | Out-Null

# ===== LOG =====
function Write-Log($msg) {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time - $msg" | Out-File -Append -FilePath $logFile
}

# ===== PROGRAMAS =====
$programas = @(
    @{ nome="AnyDesk"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/AnyDesk.exe"; arquivo="AnyDesk.exe"; tipo="exe" },
    @{ nome="Google Chrome"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/ChromeSetup.exe"; arquivo="ChromeSetup.exe"; tipo="exe" },
    @{ nome="CTE"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/componente_cte_5.00b.exe"; arquivo="cte.exe"; tipo="exe" },
    @{ nome="NFA SOFT"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/instalador.exe"; arquivo="instalador.exe"; tipo="exe" },
    @{ nome="LibreOffice"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/LibreOffice_24.8.4_Win_x86-64.msi"; arquivo="libreoffice.msi"; tipo="msi" },
    @{ nome="Office 2024"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/microsoft-office-2024-16-0-18025-20140.exe"; arquivo="office.exe"; tipo="exe" },
    @{ nome="Panda AV"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/PANDAFREEAV.exe"; arquivo="panda.exe"; tipo="exe" },
    @{ nome="Adobe Reader"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/Reader_br_install.exe"; arquivo="reader.exe"; tipo="exe" },
    @{ nome="Zoom"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/ZoomInstallerFull.exe"; arquivo="zoom.exe"; tipo="exe" }
)

# ===== FORM =====
$form = New-Object System.Windows.Forms.Form
$form.Text = "RD Solutec - Instalador Profissional"
$form.Size = New-Object System.Drawing.Size(520,600)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#1E1E1E"
$form.ForeColor = "White"

# ===== LISTA =====
$checkList = New-Object System.Windows.Forms.CheckedListBox
$checkList.Size = New-Object System.Drawing.Size(460,250)
$checkList.Location = New-Object System.Drawing.Point(20,20)
$checkList.BackColor = "#2D2D30"
$checkList.ForeColor = "White"

foreach ($p in $programas) {
    $checkList.Items.Add($p.nome)
}

$form.Controls.Add($checkList)

# ===== BOTÕES =====
function CriarBotao($texto, $x, $y) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $texto
    $btn.Size = New-Object System.Drawing.Size(200,40)
    $btn.Location = New-Object System.Drawing.Point($x,$y)
    $btn.BackColor = "#007ACC"
    $btn.ForeColor = "White"
    return $btn
}

$btnInstalar = CriarBotao "Instalar Selecionados" 20 300
$btnTodos = CriarBotao "Instalar TODOS" 270 300

$form.Controls.Add($btnInstalar)
$form.Controls.Add($btnTodos)

# ===== STATUS =====
$status = New-Object System.Windows.Forms.Label
$status.Size = New-Object System.Drawing.Size(460,30)
$status.Location = New-Object System.Drawing.Point(20,360)
$status.Text = "Status: Aguardando..."
$form.Controls.Add($status)

# ===== PROGRESS =====
$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Size = New-Object System.Drawing.Size(460,30)
$progress.Location = New-Object System.Drawing.Point(20,400)
$form.Controls.Add($progress)

# ===== FUNÇÃO DOWNLOAD =====
function Baixar-Arquivo($url, $destino) {
    try {
        Invoke-WebRequest -Uri $url -OutFile $destino -UseBasicParsing
        return $true
    } catch {
        Write-Log "Erro ao baixar: $url"
        return $false
    }
}

# ===== FUNÇÃO INSTALAR =====
function Instalar($lista) {

    $total = $lista.Count
    $count = 0

    foreach ($item in $lista) {

        $prog = $programas | Where-Object { $_.nome -eq $item }
        if ($null -eq $prog) { continue }

        $caminho = "$base\$($prog.arquivo)"

        $status.Text = "Baixando $($prog.nome)..."
        $form.Refresh()
        Write-Log "Baixando $($prog.nome)"

        if (-not (Test-Path $caminho)) {
            $ok = Baixar-Arquivo $prog.url $caminho
            if (-not $ok) {
                $status.Text = "Erro no download: $($prog.nome)"
                continue
            }
        }

        $status.Text = "Instalando $($prog.nome)..."
        $form.Refresh()
        Write-Log "Instalando $($prog.nome)"

        try {
            if ($prog.tipo -eq "msi") {
                Start-Process "msiexec.exe" -ArgumentList "/i `"$caminho`" $($prog.args)" -Wait
            } else {
                Start-Process $caminho -ArgumentList $prog.args -Wait
            }
        } catch {
            Write-Log "Erro na instalação: $($prog.nome)"
            $status.Text = "Erro: $($prog.nome)"
        }

        $count++
        $progress.Value = [int](($count / $total) * 100)
    }

    $status.Text = "Finalizado!"
    Write-Log "Processo finalizado"
}

# ===== EVENTOS =====
$btnInstalar.Add_Click({
    $selecionados = $checkList.CheckedItems

    if ($selecionados.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Selecione pelo menos um programa")
        return
    }

    Instalar $selecionados
})

$btnTodos.Add_Click({
    Instalar ($programas.nome)
})

# ===== EXECUTAR =====
$form.ShowDialog()
