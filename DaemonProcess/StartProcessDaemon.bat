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