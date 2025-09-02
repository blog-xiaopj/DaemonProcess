# �����������Ϊ UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# �Ӳ����л�ȡ����
$processName = $args[0]  # ��������
$processDirectory = $args[1]  # ����Ŀ¼
$restartInterval = [int]$args[2]  # �������������Ϊ��λ��
$processArgs = $args[3]  # ������������

$processPath = Join-Path -Path $processDirectory -ChildPath "$processName.exe"  # ���ɽ��̵�����·��

# ������ػ��Ľ�����Ϣ
Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ���ڼ�ؽ���: $processName"
Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ����·��: $processPath"
Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ��������: $processArgs"

# ѭ����ؽ���
while ($true) {
    # �������Ƿ�������
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue

    # �������δ���У���������
    if (-not $process) {
        Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $processName δ����. ��������..."
        if ($processArgs) {
            Start-Process -FilePath $processPath -WorkingDirectory $processDirectory -ArgumentList $processArgs
        } else {
            Start-Process -FilePath $processPath -WorkingDirectory $processDirectory
        }
    } else {
        Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $processName ��������."

        # ����Ƿ���Ҫ������������
        if ($restartInterval -gt 0 -and $process -and (Get-Date).AddSeconds(-$restartInterval) -gt $process.StartTime) {
            Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ������������ $processName..."
            Stop-Process -Name $processName -Force
            if ($processArgs) {
                Start-Process -FilePath $processPath -WorkingDirectory $processDirectory -ArgumentList $processArgs
            } else {
                Start-Process -FilePath $processPath -WorkingDirectory $processDirectory
            }
        }
    }

    # ��ͣһ��ʱ���ټ��
    Start-Sleep -Seconds 5
}
