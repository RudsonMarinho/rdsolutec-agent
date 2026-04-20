Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===== CONFIG =====
$base = "$env:ProgramData\RDSolutec"
New-Item -ItemType Directory -Path $base -Force | Out-Null

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
$form.Text = "RD Solutec - Instalador"
$form.Size = New-Object System.Drawing.Size(500,550)
$form.StartPosition = "CenterScreen"

# ===== LISTA =====
$checkList = New-Object System.Windows.Forms.CheckedListBox
$checkList.Size = New-Object System.Drawing.Size(450,250)
$checkList.Location = New-Object System.Drawing.Point(20,20)

foreach ($p in $programas) {
    $checkList.Items.Add($p.nome)
}

$form.Controls.Add($checkList)

# ===== BOTÃO INSTALAR =====
$btnInstalar = New-Object System.Windows.Forms.Button
$btnInstalar.Text = "Instalar Selecionados"
$btnInstalar.Size = New-Object System.Drawing.Size(200,40)
$btnInstalar.Location = New-Object System.Drawing.Point(20,300)

$form.Controls.Add($btnInstalar)

# ===== BOTÃO TODOS =====
$btnTodos = New-Object System.Windows.Forms.Button
$btnTodos.Text = "Instalar TODOS"
$btnTodos.Size = New-Object System.Drawing.Size(200,40)
$btnTodos.Location = New-Object System.Drawing.Point(270,300)

$form.Controls.Add($btnTodos)

# ===== STATUS =====
$status = New-Object System.Windows.Forms.Label
$status.Size = New-Object System.Drawing.Size(450,30)
$status.Location = New-Object System.Drawing.Point(20,360)
$status.Text = "Status: Aguardando..."

$form.Controls.Add($status)

# ===== PROGRESS BAR =====
$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Size = New-Object System.Drawing.Size(450,30)
$progress.Location = New-Object System.Drawing.Point(20,400)

$form.Controls.Add($progress)

# ===== FUNÇÃO INSTALAR =====
function Instalar($lista) {

    $total = $lista.Count
    $count = 0

    foreach ($item in $lista) {

        $prog = $programas | Where-Object { $_.nome -eq $item }

        if ($null -eq $prog) { continue }

        $status.Text = "Baixando $($prog.nome)..."
        $form.Refresh()

        $caminho = "$base\$($prog.arquivo)"

        try {
            Invoke-WebRequest -Uri $prog.url -OutFile $caminho -UseBasicParsing

            $status.Text = "Instalando $($prog.nome)..."
            $form.Refresh()

            if ($prog.tipo -eq "msi") {
                Start-Process "msiexec.exe" -ArgumentList "/i `"$caminho`"" -Wait
            } else {
                Start-Process $caminho -Wait
            }

        } catch {
            $status.Text = "Erro em $($prog.nome)"
        }

        $count++
        $progress.Value = ($count / $total) * 100
    }

    $status.Text = "Finalizado!"
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
