# windows10 进程守护

## 简介
通过 Windows PowerShell 脚本实现进程守护，确保指定的进程在意外关闭时能够自动重启。

## 创建配置文件

以谷歌浏览器为例，创建配置文件 `Config.ini`，输入以下内容：

```
; 配置文件说明
; 该文件用于定义进程守护程序的配置参数

[ProcessConfig]
; 监控的进程名称 注意不要添加 exe 后缀
processName=chrome

; 进程的目录绝对路径
processDirectory=C:\Program Files\Google\Chrome\Application

; 进程重启间隔（以秒为单位），设置为 0 将禁用自动重启
restartInterval=0
```

- `processName`: 需要监控的进程名称，不包括 `.exe` 后缀。
- `processDirectory`: 进程的安装目录，确保路径正确。
- `restartInterval`: 进程重启的时间间隔，单位为秒，设置为 0 则不自动重启。


## 创建 PowerShell 文件
新建 PowerShell 格式文件 `ProcessDaemon.ps1`，输入以下内容。

```
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
```

- 注意编码格式，使用 Windows PowerShell ISE 编辑时选择 GB2312 编码。
- 该脚本会持续监控指定的进程，如果进程未运行，则会自动启动。
- 如果设置了重启间隔，脚本会在进程运行时间超过该间隔后自动重启进程。


## 创建运行脚本
创建脚本文件 `StartProcessDaemon.bat`，输入以下内容：

```
@echo off
chcp 65001 > nul

:: 获取当前脚本所在的目录
set "scriptDir=%~dp0"

:: 读取配置文件
for /f "tokens=1,2 delims==" %%A in ('findstr /r "processName= processDirectory= restartInterval=" "%scriptDir%config.ini"') do (
    set "%%A=%%B"
)

echo 正在启动进程守护程序...
echo 守护进程名称 "%processName%"
echo 守护进程目录 "%processDirectory%"
:: Start of Selection
if "%restartInterval%"=="0" (
    echo 守护进程重启间隔为 0 秒，自动重启已禁用。
) else (
    echo 守护进程重启间隔 "%restartInterval%" 秒
)

PowerShell -ExecutionPolicy Bypass -File "%scriptDir%ProcessDaemon.ps1" "%processName%" "%processDirectory%" "%restartInterval%"

echo PowerShell 脚本执行完毕。
pause
```

- 注意路径，使用绝对路径
- 注意编码格式，使用 Windows PowerShell ISE 编辑时选择 GB2312 编码。

## 项目路径
此脚本已上传到github
[https://github.com/DanceMonkey2020/DaemonProcess.git](https://github.com/DanceMonkey2020/DaemonProcess.git)

