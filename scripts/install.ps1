# ===== SEGURANÇA =====
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {}

# ===== ADMIN =====
function Test-Admin {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch { return $false }
}

if (-not (Test-Admin)) {
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# ===== TESTE GUI =====
$guiOK = $true
try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
} catch {
    $guiOK = $false
}

# ===== CONFIG =====
$base = "$env:ProgramData\RDSolutec"
New-Item -ItemType Directory -Path $base -Force | Out-Null

# ===== LISTA COMPLETA =====
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

# ===== DOWNLOAD ESTÁVEL =====
function Download-File {
    param($url, $destino)

    try {
        $request = [System.Net.HttpWebRequest]::Create($url)
        $response = $request.GetResponse()
    } catch {
        throw "Erro ao baixar: $url"
    }

    $total = $response.ContentLength
    $stream = $response.GetResponseStream()
    $file = [System.IO.File]::Create($destino)

    $buffer = New-Object byte[] 8192
    $totalRead = 0

    while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
        $file.Write($buffer, 0, $read)
        $totalRead += $read

        if ($total -gt 0) {
            $percent = [int](($totalRead / $total) * 100)
            Write-Progress -Activity "Baixando $url" -PercentComplete $percent
        }
    }

    $file.Close()
    $stream.Close()
    $response.Close()
}

# ===== CONSOLE =====
function Instalar-Console {

    $i = 0
    $total = $programas.Count

    foreach ($prog in $programas) {

        $i++
        $path = "$base\$($prog.arquivo)"

        Write-Host "[$i/$total] Baixando $($prog.nome)"

        try {
            Download-File $prog.url $path
        } catch {
            Write-Host "Erro download: $($prog.nome)" -ForegroundColor Red
            continue
        }

        Write-Host "Instalando $($prog.nome)..."

        if ($prog.tipo -eq "msi") {
            Start-Process msiexec.exe -ArgumentList "/i `"$path`" /qn" -Wait
        } else {
            Start-Process $path -ArgumentList "/S" -Wait
        }
    }

    Write-Host "Finalizado!"
    pause
}

# ===== GUI =====
function Instalar-GUI {

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "RD Solutec"
    $form.Size = New-Object System.Drawing.Size(520,420)
    $form.StartPosition = "CenterScreen"

    $list = New-Object System.Windows.Forms.CheckedListBox
    $list.Size = New-Object System.Drawing.Size(470,220)
    $list.Location = New-Object System.Drawing.Point(20,20)

    foreach ($p in $programas) {
        [void]$list.Items.Add($p.nome)
    }

    $form.Controls.Add($list)

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = "Instalar"
    $btn.Location = New-Object System.Drawing.Point(20,260)

    $status = New-Object System.Windows.Forms.Label
    $status.Location = New-Object System.Drawing.Point(20,300)
    $status.Size = New-Object System.Drawing.Size(450,30)

    $form.Controls.Add($btn)
    $form.Controls.Add($status)

    $btn.Add_Click({

        if ($list.CheckedItems.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Selecione ao menos um programa")
            return
        }

        $total = $list.CheckedItems.Count
        $i = 0

        foreach ($item in $list.CheckedItems) {

            $i++
            $prog = $programas | Where-Object { $_.nome -eq $item }
            $path = "$base\$($prog.arquivo)"

            $status.Text = "[$i/$total] Baixando $($prog.nome)"
            $form.Refresh()

            try {
                Download-File $prog.url $path
            } catch {
                $status.Text = "Erro download"
                continue
            }

            $status.Text = "Instalando $($prog.nome)"
            $form.Refresh()

            if ($prog.tipo -eq "msi") {
                Start-Process msiexec.exe -ArgumentList "/i `"$path`" /qn" -Wait
            } else {
                Start-Process $path -ArgumentList "/S" -Wait
            }
        }

        $status.Text = "Concluído!"
    })

    $form.ShowDialog()
}

# ===== EXEC =====
if ($guiOK) {
    Instalar-GUI
} else {
    Instalar-Console
}
