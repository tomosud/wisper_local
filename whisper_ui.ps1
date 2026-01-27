Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pythonExe = Join-Path $scriptDir "python\python.exe"
$transcriber = Join-Path $scriptDir "whisper_transcriber.py"
$soundDir = Join-Path $env:USERPROFILE "Documents"
$soundDir = Join-Path $soundDir ([char]0x30B5 + [char]0x30A6 + [char]0x30F3 + [char]0x30C9 + " " + [char]0x30EC + [char]0x30B3 + [char]0x30FC + [char]0x30C7 + [char]0x30A3 + [char]0x30F3 + [char]0x30B0)

$form = New-Object System.Windows.Forms.Form
$form.Text = "Whisper"
$form.Size = New-Object System.Drawing.Size(340, 380)
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
        $proc = Start-Process -FilePath $pythonExe -ArgumentList $quotedArgs -WorkingDirectory $scriptDir -Wait -PassThru
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

# D - Drop area
$dropPanel = New-Object System.Windows.Forms.Panel
$dropPanel.Location = New-Object System.Drawing.Point($x, $y)
$dropPanel.Size = New-Object System.Drawing.Size($btnWidth, 100)
$dropPanel.BorderStyle = "FixedSingle"
$dropPanel.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$dropPanel.AllowDrop = $true

$dropLabel = New-Object System.Windows.Forms.Label
$dropLabel.Text = "D  Drop File Here > Transcribe"
$dropLabel.TextAlign = "MiddleCenter"
$dropLabel.Dock = "Fill"
$dropLabel.Font = New-Object System.Drawing.Font("Yu Gothic UI", 11)
$dropLabel.ForeColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
$dropPanel.Controls.Add($dropLabel)

$dropPanel.Add_DragEnter({
    param($sender, $e)
    if ($e.Data.GetDataPresent([System.Windows.Forms.DataFormats]::FileDrop)) {
        $e.Effect = [System.Windows.Forms.DragDropEffects]::Copy
        $sender.BackColor = [System.Drawing.Color]::FromArgb(200, 220, 255)
    }
})

$dropPanel.Add_DragLeave({
    param($sender, $e)
    $sender.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
})

$dropPanel.Add_DragDrop({
    param($sender, $e)
    $sender.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
    $droppedFiles = $e.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop)
    if ($droppedFiles.Count -gt 0) {
        $dropLabel.Text = "Processing..."
        $dropLabel.ForeColor = [System.Drawing.Color]::Blue
        $form.Refresh()

        $quotedArgs = @("`"$transcriber`"")
        foreach ($f in $droppedFiles) { $quotedArgs += "`"$f`"" }
        $proc = Start-Process -FilePath $pythonExe -ArgumentList $quotedArgs -WorkingDirectory $scriptDir -Wait -PassThru

        $dropLabel.Text = "D  Drop File Here > Transcribe"
        $dropLabel.ForeColor = [System.Drawing.Color]::FromArgb(100, 100, 100)

        if ($proc.ExitCode -eq 0) {
            $outputDir = Split-Path -Parent $droppedFiles[0]
            Start-Process "explorer.exe" -ArgumentList $outputDir
        } else {
            [System.Windows.Forms.MessageBox]::Show("Failed", "Error", "OK", "Error")
        }
    }
})

$form.Controls.Add($dropPanel)

[void]$form.ShowDialog()
