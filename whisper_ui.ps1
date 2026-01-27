Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pythonExe = Join-Path $scriptDir "python\python.exe"
$transcriber = Join-Path $scriptDir "whisper_transcriber.py"
$soundDir = Join-Path $env:USERPROFILE "Documents"
$soundDir = Join-Path $soundDir ([char]0x30B5 + [char]0x30A6 + [char]0x30F3 + [char]0x30C9 + " " + [char]0x30EC + [char]0x30B3 + [char]0x30FC + [char]0x30C7 + [char]0x30A3 + [char]0x30F3 + [char]0x30B0)

$form = New-Object System.Windows.Forms.Form
$form.Text = "Whisper"
$form.Size = New-Object System.Drawing.Size(340, 280)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font("Yu Gothic UI", 10)

$btnWidth = 290
$btnHeight = 42
$x = 15
$y = 15

# A
$btnA = New-Object System.Windows.Forms.Button
$btnA.Text = "A  Record Tool"
$btnA.Location = New-Object System.Drawing.Point($x, $y)
$btnA.Size = New-Object System.Drawing.Size($btnWidth, $btnHeight)
$btnA.Add_Click({
    Start-Process "explorer.exe" -ArgumentList "shell:appsFolder\Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe!App"
})
$form.Controls.Add($btnA)

$y += 50

# B
$btnB = New-Object System.Windows.Forms.Button
$btnB.Text = "B  Select File > Transcribe"
$btnB.Location = New-Object System.Drawing.Point($x, $y)
$btnB.Size = New-Object System.Drawing.Size($btnWidth, $btnHeight)
$btnB.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title = "Select files"
    if (Test-Path $soundDir) {
        $dlg.InitialDirectory = $soundDir
    }
    $dlg.Filter = "Audio/Video|*.mp3;*.wav;*.m4a;*.mp4;*.mov;*.avi;*.flv;*.webm|All|*.*"
    $dlg.Multiselect = $true

    if ($dlg.ShowDialog() -eq "OK") {
        $files = $dlg.FileNames
        $statusLabel.Text = "Processing..."
        $form.Refresh()

        $btnB.Enabled = $false
        $quotedArgs = @("`"$transcriber`"")
        foreach ($f in $files) { $quotedArgs += "`"$f`"" }
        $proc = Start-Process -FilePath $pythonExe -ArgumentList $quotedArgs -WorkingDirectory $scriptDir -NoNewWindow -Wait -PassThru
        $btnB.Enabled = $true
        $statusLabel.Text = ""

        if ($proc.ExitCode -eq 0) {
            $outputDir = Split-Path -Parent $files[0]
            Start-Process "explorer.exe" -ArgumentList $outputDir
        } else {
            [System.Windows.Forms.MessageBox]::Show("Failed", "Error", "OK", "Error")
        }
    }
})
$form.Controls.Add($btnB)

$y += 50

# C
$btnC = New-Object System.Windows.Forms.Button
$btnC.Text = "C  Recording Folder"
$btnC.Location = New-Object System.Drawing.Point($x, $y)
$btnC.Size = New-Object System.Drawing.Size($btnWidth, $btnHeight)
$btnC.Add_Click({
    if (-not (Test-Path $soundDir)) {
        New-Item -ItemType Directory -Path $soundDir -Force | Out-Null
    }
    Start-Process "explorer.exe" -ArgumentList $soundDir
})
$form.Controls.Add($btnC)

$y += 50

# D
$btnD = New-Object System.Windows.Forms.Button
$btnD.Text = "D  Drop File > Transcribe"
$btnD.Location = New-Object System.Drawing.Point($x, $y)
$btnD.Size = New-Object System.Drawing.Size($btnWidth, $btnHeight)
$btnD.Add_Click({
    Start-Process "explorer.exe" -ArgumentList $scriptDir
})
$form.Controls.Add($btnD)

$y += 48

# Status
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = ""
$statusLabel.ForeColor = [System.Drawing.Color]::Blue
$statusLabel.Location = New-Object System.Drawing.Point($x, $y)
$statusLabel.Size = New-Object System.Drawing.Size($btnWidth, 20)
$form.Controls.Add($statusLabel)

[void]$form.ShowDialog()
