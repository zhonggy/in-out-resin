@echo off
chcp 936 >nul
title 重启注册机控制台
cd /d "%~dp0"
setlocal enabledelayedexpansion
set "BASE=D:\out"

echo ============================================
echo   重启 OutlookRegister 注册机控制台 (9090)
echo ============================================
echo.

rem ---- 1. 停掉占用 9090 的旧进程 ----
echo [1/2] 停止旧控制台 ...
set "FOUND="
for /f "tokens=5" %%p in ('netstat -ano ^| findstr ":9090" ^| findstr LISTENING') do (
    if not defined FOUND (
        set "FOUND=1"
        echo   发现 PID %%p，正在结束 ...
        taskkill /F /PID %%p >nul 2>nul
        echo   已结束 PID %%p
    )
)
if not defined FOUND (
    echo   9090 没有在监听（控制台未运行），直接启动。
)
timeout /t 2 /nobreak >nul

rem ---- 2. 选择 python 并启动 ----
echo [2/2] 启动控制台 ...
set "PY="
if exist "%BASE%\OutlookRegister\.venv\Scripts\python.exe" (
    set "PY=%BASE%\OutlookRegister\.venv\Scripts\python.exe"
) else (
    where python >nul 2>nul && set "PY=python"
)
if not defined PY (
    echo [错误] 找不到 python，请先安装 Python 并加入 PATH。
    pause
    exit /b 1
)

start "web_console" /D "%BASE%\OutlookRegister" "%PY%" "%BASE%\OutlookRegister\web_console.py" --port 9090
echo   已启动：%PY%

rem ---- 3. 等待端口就绪 ----
set /a wait=0
:wait_loop
if !wait! geq 15 goto wait_done
netstat -ano | findstr ":9090" | findstr LISTENING >nul 2>nul
if !errorlevel!==0 goto wait_done
set /a wait+=1
timeout /t 1 /nobreak >nul
goto wait_loop
:wait_done

netstat -ano | findstr ":9090" | findstr LISTENING >nul 2>nul
if !errorlevel!==0 (
    echo.
    echo [OK] 控制台已重启： http://127.0.0.1:9090
) else (
    echo.
    echo [错误] 15 秒内未检测到 9090 监听，请检查依赖是否安装：
    echo   cd /d %BASE%\OutlookRegister
    echo   .venv\Scripts\pip install -r requirements.txt
    echo   .venv\Scripts\patchright install chromium
)
echo.
pause
