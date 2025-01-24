# 设置输出编码为 UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 从参数中获取配置
$processName = $args[0]  # 进程名称
$processDirectory = $args[1]  # 进程目录
$restartInterval = [int]$args[2]  # 重启间隔（以秒为单位）

$processPath = Join-Path -Path $processDirectory -ChildPath "$processName.exe"  # 生成进程的完整路径

# 输出被守护的进程信息
Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') 正在监控进程: $processName"
Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') 进程路径: $processPath"

# 循环监控进程
while ($true) {
    # 检查进程是否在运行
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue

    # 如果进程未运行，则启动它
    if (-not $process) {
        Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $processName 未运行. 正在启动..."
        Start-Process -FilePath $processPath -WorkingDirectory $processDirectory
    } else {
        Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $processName 正在运行."

        # 检查是否需要重新启动进程
        if ($restartInterval -gt 0 -and $process -and (Get-Date).AddSeconds(-$restartInterval) -gt $process.StartTime) {
            Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') 正在重新启动 $processName..."
            Stop-Process -Name $processName -Force
            Start-Process -FilePath $processPath -WorkingDirectory $processDirectory
        }
    }

    # 暂停一段时间再检查
    Start-Sleep -Seconds 5
}
