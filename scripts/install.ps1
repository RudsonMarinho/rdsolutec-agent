Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Janela
$form = New-Object System.Windows.Forms.Form
$form.Text = "RD Solutec - Instalador"
$form.Size = New-Object System.Drawing.Size(500,550)
$form.StartPosition = "CenterScreen"

# Lista de programas
$programas = @(
    @{ nome="AnyDesk"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/AnyDesk.exe"; arquivo="AnyDesk.exe"; tipo="exe" },
    @{ nome="Google Chrome"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/ChromeSetup.exe"; arquivo="ChromeSetup.exe"; tipo="exe" },
    @{ nome="CTE"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/componente_cte_5.00b.exe"; arquivo="cte.exe"; tipo="exe" },
    @{ nome="Instalador Genérico"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/instalador.exe"; arquivo="instalador.exe"; tipo="exe" },
    @{ nome="LibreOffice"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/LibreOffice_24.8.4_Win_x86-64.msi"; arquivo="libreoffice.msi"; tipo="msi" },
    @{ nome="Office 2024"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/microsoft-office-2024-16-0-18025-20140.exe"; arquivo="office.exe"; tipo="exe" },
    @{ nome="Panda AV"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/PANDAFREEAV.exe"; arquivo="panda.exe"; tipo="exe" },
    @{ nome="Adobe Reader"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/Reader_br_install.exe"; arquivo="reader.exe"; tipo="exe" },
    @{ nome="Zoom"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/ZoomInstallerFull.exe"; arquivo="zoom.exe"; tipo="exe" }
)

$base = "$env:ProgramData\RDSolutec"
New-Item -ItemType Directory -Path $base -Force | Out-Null

# Checklist
$checkList = New-Object System.Windows.Forms.CheckedListBox
$checkList.Size = New-Object System.Drawing.Size(450,250)
$checkList.Location = New-Object System.Drawing.Point(20,20)

foreach ($p in $programas) {
    $checkList.Items.Add($p.nome) | Out-Null
}

$form.Controls.Add($checkList)

# Botão instalar
$btnInstalar = New-Object System.Windows.Forms.Button
$btnInstalar.Text = "Instalar Selecionados"
$btnInstalar.Size = New-Object System.Drawing.Size(200,40)
$btnInstalar.Location = New-Object System.Drawing.Point(20,290)

$form.Controls.Add($btnInstalar)

# Barra de progresso
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(450,25)
$progressBar.Location = New-Object System.Drawing.Point(20,350)
$form.Controls.Add($progressBar)

# Log
$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.Size = New-Object System.Drawing.Size(450,120)
$logBox.Location = New-Object System.Drawing.Point(20,390)
$form.Controls.Add($logBox)

# Função de log
function Log($msg) {
    $logBox.AppendText("$msg`r`n")
}

# Ação do botão
$btnInstalar.Add_Click({

    $selecionados = $checkList.CheckedItems
    $total = $selecionados.Count

    if ($total -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Selecione pelo menos um programa")
        return
    }

    $progressBar.Maximum = $total
    $progressBar.Value = 0

    foreach ($item in $selecionados) {

        $prog = $programas | Where-Object { $_.nome -eq $item }

        $caminho = "$base\$($prog.arquivo)"

        Log "Baixando $($prog.nome)..."

        try {
            Invoke-WebRequest -Uri $prog.url -OutFile $caminho -ErrorAction Stop

            if (Test-Path $caminho) {

                Log "Executando $($prog.nome)..."

                if ($prog.tipo -eq "msi") {
                    Start-Process "msiexec.exe" -ArgumentList "/i `"$caminho`"" -Wait
                } else {
                    Start-Process $caminho -Wait
                }

                Log "OK - $($prog.nome)"
            }
        }
        catch {
            Log "ERRO - $($prog.nome)"
        }

        $progressBar.Value++
    }

    Log "FINALIZADO"
})

# Executar
$form.ShowDialog()
