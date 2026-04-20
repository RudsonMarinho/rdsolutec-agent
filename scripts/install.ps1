# ===== CONFIG BASE =====
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ===== ADMIN =====
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===== PROGRAMAS =====
$programas = @(
    @{ nome="Google Chrome"; check="Chrome"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/ChromeSetup.exe"; tipo="exe" },
    @{ nome="AnyDesk"; check="AnyDesk"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/AnyDesk.exe"; tipo="exe" },
    @{ nome="Zoom"; check="Zoom"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/ZoomInstallerFull.exe"; tipo="exe" },
    @{ nome="Adobe Reader"; check="Adobe"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/Reader_br_install.exe"; tipo="exe" },
    @{ nome="WinRAR"; check="WinRAR"; url="https://github.com/RudsonMarinho/rdsolutec-agent/releases/download/v1.0.0/winrar-x64-701br.exe"; tipo="exe" }
)

$base = "$env:TEMP\rdsolutec"

# ===== DETECTAR INSTALADO =====
function JaInstalado($nome) {
    $reg = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    return Get-ItemProperty $reg -ErrorAction SilentlyContinue | Where-Object {
        $_.DisplayName -like "*$nome*"
    }
}

# ===== DOWNLOAD =====
function Download($url, $dest) {
    Invoke-WebRequest $url -OutFile $dest -UseBasicParsing
}

# ===== INSTALAR =====
function Instalar($selecionados, $statusLabel) {

    foreach ($prog in $selecionados) {

        if (JaInstalado $prog.check) {
            $statusLabel.Text = "$($prog.nome) já instalado"
            Start-Sleep 1
            continue
        }

        $file = "$base\$($prog.nome).exe"

        $statusLabel.Text = "Downloading $($prog.nome)..."
        $statusLabel.Refresh()

        try {
            Download $prog.url $file
        } catch {
            $statusLabel.Text = "Erro download $($prog.nome)"
            continue
        }

        $statusLabel.Text = "Installing $($prog.nome)..."
        $statusLabel.Refresh()

        Start-Process $file -ArgumentList "/S" -Wait -ErrorAction SilentlyContinue
    }

    $statusLabel.Text = "All done ✔"
}

# ===== UI =====
$form = New-Object System.Windows.Forms.Form
$form.Text = "RD Solutec Installer"
$form.Size = New-Object System.Drawing.Size(400,400)
$form.BackColor = "White"
$form.StartPosition = "CenterScreen"

$title = New-Object System.Windows.Forms.Label
$title.Text = "Select apps to install"
$title.Font = New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Bold)
$title.Location = "20,20"
$title.Size = "300,30"

$form.Controls.Add($title)

$y = 60
$checks = @()

foreach ($p in $programas) {

    $chk = New-Object System.Windows.Forms.CheckBox
    $chk.Text = $p.nome
    $chk.Location = "20,$y"
    $chk.Size = "300,25"

    if (JaInstalado $p.check) {
        $chk.Checked = $false
        $chk.Enabled = $false
        $chk.Text += " (já instalado)"
    }

    $form.Controls.Add($chk)
    $checks += @{ box=$chk; data=$p }

    $y += 30
}

$btn = New-Object System.Windows.Forms.Button
$btn.Text = "Install"
$btn.BackColor = "#28A745"
$btn.ForeColor = "White"
$btn.Location = "20,$y"
$btn.Size = "340,40"

$form.Controls.Add($btn)

$status = New-Object System.Windows.Forms.Label
$status.Location = "20,$($y+50)"
$status.Size = "340,30"

$form.Controls.Add($status)

# ===== EVENTO =====
$btn.Add_Click({

    $selecionados = @()

    foreach ($c in $checks) {
        if ($c.box.Checked) {
            $selecionados += $c.data
        }
    }

    if ($selecionados.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Select at least one app")
        return
    }

    Instalar $selecionados $status
})

$form.ShowDialog()
