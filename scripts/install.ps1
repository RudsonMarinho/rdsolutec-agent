Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===== ADMIN CHECK (CORRIGIDO E LIMPO) =====
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
$form.Text = "Pacote de Programas - RD Solutec"
$form.Size = New-Object System.Drawing.Size(500,600)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#2b2b2b"
$form.ForeColor = "White"

# ===== TITULO =====
$labelTitulo = New-Object System.Windows.Forms.Label
$labelTitulo.Text = "Selecione os programas que deseja instalar:"
$labelTitulo.AutoSize = $true
$labelTitulo.Location = New-Object System.Drawing.Point(20,10)
$form.Controls.Add($labelTitulo)

# ===== LISTA =====
$checkList = New-Object System.Windows.Forms.CheckedListBox
$checkList.Size = New-Object System.Drawing.Size(450,250)
$checkList.Location = New-Object System.Drawing.Point(20,40)
$checkList.BackColor = "#3c3c3c"
$checkList.ForeColor = "White"

foreach ($p in $programas) {
    $checkList.Items.Add($p.nome)
}

$form.Controls.Add($checkList)

# ===== BOTÃO SELECIONAR TODOS =====
$btnSelecionarTodos = New-Object System.Windows.Forms.Button
$btnSelecionarTodos.Text = "Selecionar Todos"
$btnSelecionarTodos.Size = New-Object System.Drawing.Size(200,30)
$btnSelecionarTodos.Location = New-Object System.Drawing.Point(20,300)

$btnSelecionarTodos.Add_Click({
    for ($i=0; $i -lt $checkList.Items.Count; $i++) {
        $checkList.SetItemChecked($i, $true)
    }
})

$form.Controls.Add($btnSelecionarTodos)

# ===== BOTÕES =====
$btnInstalar = New-Object System.Windows.Forms.Button
$btnInstalar.Text = "Instalar Selecionados"
$btnInstalar.Size = New-Object System.Drawing.Size(200,40)
$btnInstalar.Location = New-Object System.Drawing.Point(20,340)
$form.Controls.Add($btnInstalar)

$btnTodos = New-Object System.Windows.Forms.Button
$btnTodos.Text = "Instalar TODOS"
$btnTodos.Size = New-Object System.Drawing.Size(200,40)
$btnTodos.Location = New-Object System.Drawing.Point(270,340)
$form.Controls.Add($btnTodos)

# ===== STATUS =====
$status = New-Object System.Windows.Forms.Label
$status.Size = New-Object System.Drawing.Size(450,30)
$status.Location = New-Object System.Drawing.Point(20,390)
$status.Text = "Status: Aguardando..."
$form.Controls.Add($status)

# ===== PROGRESS =====
$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Size = New-Object System.Drawing.Size(450,30)
$progress.Location = New-Object System.Drawing.Point(20,430)
$form.Controls.Add($progress)

# ===== FUNÇÃO =====
function Instalar($lista) {

    $btnInstalar.Enabled = $false
    $btnTodos.Enabled = $false

    $total = $lista.Count
    $count = 0

    foreach ($item in $lista) {

        $prog = $programas | Where-Object { $_.nome -eq $item }
        if ($null -eq $prog) { continue }

        $caminho = "$base\$($prog.arquivo)"

        try {
            if (-Not (Test-Path $caminho)) {
                $status.Text = "Baixando $($prog.nome)..."
                $form.Refresh()
                Invoke-WebRequest -Uri $prog.url -OutFile $caminho
            }

            Add-Content $log "Instalando $($prog.nome) - $(Get-Date)"

            $status.Text = "Instalando $($prog.nome)... ($($count+1) de $total)"
            $form.Refresh()

            if ($prog.tipo -eq "msi") {
                Start-Process "msiexec.exe" -ArgumentList "/i `"$caminho`" /qn /norestart" -Wait
            } else {
                Start-Process $caminho -ArgumentList "/S" -Wait
            }

            Remove-Item $caminho -Force -ErrorAction SilentlyContinue

        } catch {
            $status.Text = "Erro em $($prog.nome): $($_.Exception.Message)"
            Add-Content $log "Erro em $($prog.nome): $($_.Exception.Message)"
        }

        $count++
        $progress.Value = [int](($count / $total) * 100)
    }

    $status.Text = "Programa(s) instalado(s)!"
    $btnInstalar.Enabled = $true
    $btnTodos.Enabled = $true
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

# ===== EXEC =====
$form.ShowDialog()
