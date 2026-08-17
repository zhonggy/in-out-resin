@echo off
chcp 936 >nul
title OutlookRegister + Resin 安装启动脚本
cd /d "%~dp0"
setlocal enabledelayedexpansion
set "BASE=D:\out"

echo ============================================
echo   OutlookRegister 注册机 + Resin 代理池
echo   新电脑一键安装启动脚本
echo ============================================
echo.

rem ========== 0. 管理员权限提示 ==========
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [提示] 建议以管理员身份运行本脚本。
    echo        按任意键继续，或关闭窗口后右键"以管理员身份运行"。
    pause >nul
)

rem ========== 1. 检查前置依赖 ==========
echo [1/7] 检查前置依赖 ...
echo.

where python >nul 2>nul
if %errorlevel% neq 0 (
    echo [缺少] 未找到 Python，请先安装 Python 3.10+
    echo   下载：https://www.python.org/downloads/
    echo   安装时务必勾选 "Add python.exe to PATH"
    echo.
    echo   安装完成后重新运行本脚本。
    pause
    exit /b 1
)
echo   Python:
python --version

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [缺少] 未找到 Git，请先安装 Git
    echo   下载：https://git-scm.com/download/win
    echo.
    echo   安装完成后重新运行本脚本。
    pause
    exit /b 1
)
echo   Git:
git --version

where curl >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未找到 curl（Windows 10 及以上系统自带）。
    pause
    exit /b 1
)

echo.
echo [依赖检查] 全部就绪。
echo.

rem ========== 2. 创建目录 ==========
echo [2/7] 创建目录结构 ...
if not exist "%BASE%" mkdir "%BASE%"
if not exist "%BASE%\resin" mkdir "%BASE%\resin"
if not exist "%BASE%\resin\data" mkdir "%BASE%\resin\data"
if not exist "%BASE%\resin\data\state" mkdir "%BASE%\resin\data\state"
if not exist "%BASE%\resin\data\cache" mkdir "%BASE%\resin\data\cache"
if not exist "%BASE%\resin\data\log" mkdir "%BASE%\resin\data\log"
if not exist "%BASE%\easy_proxies" mkdir "%BASE%\easy_proxies"
if not exist "%BASE%\easy_proxies\logs" mkdir "%BASE%\easy_proxies\logs"
echo [目录] 创建完成。
echo.

rem ========== 3. easy_proxies 代理池 ==========
echo [3/7] 安装 easy_proxies 代理池 ...
echo.
if not exist "%BASE%\easy_proxies\easy_proxies.exe" (
    echo   正在下载 easy_proxies v2.3.0 ...
    curl -L -o "%BASE%\easy_proxies\easy_proxies.exe" ^
        "https://github.com/daimon3332/easy-proxies/releases/download/v2.3.0/easy_proxies-v2.3.0-windows-amd64.exe"
    if !errorlevel! neq 0 (
        echo   [下载失败] 请手动下载：
        echo   https://github.com/daimon3332/easy-proxies/releases/tag/v2.3.0
        echo   将 easy_proxies-v2.3.0-windows-amd64.exe 放到 %BASE%\easy_proxies\ 并改名为 easy_proxies.exe
        pause
        exit /b 1
    )
    echo   下载完成。
) else (
    echo   easy_proxies.exe 已存在，跳过下载。
)

if not exist "%BASE%\easy_proxies\config.yaml" (
    echo   生成 config.yaml ...
    (
      echo mode: multi-port
      echo listener:
      echo   address: 127.0.0.1
      echo   port: 2323
      echo   username: ""
      echo   password: ""
      echo multi_port:
      echo   address: 127.0.0.1
      echo   base_port: 24000
      echo   username: ""
      echo   password: ""
      echo pool:
      echo   mode: rotate
      echo   failure_threshold: 2
      echo   blacklist_duration: 10m0s
      echo   rotation_interval: 2m0s
      echo management:
      echo   enabled: true
      echo   listen: 127.0.0.1:9091
      echo   probe_target: https://www.gstatic.com/generate_204
      echo   password: ""
      echo subscription_refresh:
      echo   enabled: true
      echo   interval: 1h0m0s
      echo   timeout: 30s
      echo   health_check_timeout: 5s
      echo   drain_timeout: 30s
      echo   min_available_nodes: 1
      echo   test_204: true
      echo log:
      echo   output: stdout
      echo   file: %BASE%\easy_proxies\logs\easy_proxies.log
      echo   max_size: 50
      echo   max_backups: 3
      echo   max_age: 7
      echo   compress: false
      echo subscriptions: []
      echo nodes: []
      echo nodes_file: ""
      echo skip_cert_verify: false
    ) > "%BASE%\easy_proxies\config.yaml"
    echo   已生成。
    echo   [重要] 请编辑 %BASE%\easy_proxies\config.yaml，在 subscriptions 中添加代理订阅链接。
) else (
    echo   config.yaml 已存在，跳过生成。
)
echo [easy_proxies] 安装完成。
echo.

rem ========== 4. resin 代理池 ==========
echo [4/7] 安装 resin 代理池 ...
echo.
if not exist "%BASE%\resin\resin.exe" (
    echo   正在下载 resin v1.2.0 ...
    curl -L -o "%BASE%\resin\resin.zip" ^
        "https://github.com/Resinat/Resin/releases/download/v1.2.0/resin-windows-amd64.zip"
    if !errorlevel! neq 0 (
        echo   [下载失败] 请手动下载：
        echo   https://github.com/Resinat/Resin/releases/tag/v1.2.0
        echo   下载 resin-windows-amd64.zip 后解压到 %BASE%\resin\
        pause
        exit /b 1
    )
    echo   正在解压 ...
    powershell -Command "Expand-Archive -Path '%BASE%\resin\resin.zip' -DestinationPath '%BASE%\resin\' -Force"
    del "%BASE%\resin\resin.zip" >nul 2>nul
    if exist "%BASE%\resin\resin.exe" (
        echo   解压完成。
    ) else (
        echo   [解压失败] 请手动解压 resin-windows-amd64.zip 到 %BASE%\resin\
        pause
        exit /b 1
    )
) else (
    echo   resin.exe 已存在，跳过下载。
)

if not exist "%BASE%\resin\.env" (
    echo   生成 .env 配置 ...
    (
        echo # 后台管理密钥
        echo RESIN_ADMIN_TOKEN=zgy2322317886
        echo RESIN_PROXY_TOKEN="zgy2322317886"
        echo.
        echo # 数据存储目录
        echo RESIN_STATE_DIR=./data/state
        echo RESIN_CACHE_DIR=./data/cache
        echo RESIN_LOG_DIR=./data/log
        echo.
        echo # 服务监听端口
        echo RESIN_LISTEN_ADDRESS=0.0.0.0
        echo RESIN_PORT=2260
        echo.
        echo # 走本地 Clash 代理（按实际端口修改）
        echo HTTP_PROXY=http://127.0.0.1:7897
        echo HTTPS_PROXY=http://127.0.0.1:7897
        echo ALL_PROXY=socks5://127.0.0.1:7897
        echo.
        echo # 本地地址跳过代理
        echo NO_PROXY=127.0.0.1,localhost
    ) > "%BASE%\resin\.env"
    echo   已生成。
) else (
    echo   .env 已存在，跳过生成。
)
echo [resin] 安装完成。
echo.

rem ========== 5. OutlookRegister 注册机 ==========
echo [5/7] 安装 OutlookRegister 注册机 ...
echo.
if not exist "%BASE%\OutlookRegister\.git" (
    echo   正在从 GitHub 克隆 ...
    git clone https://github.com/zhonggy/OutlookRegister.git "%BASE%\OutlookRegister"
    if !errorlevel! neq 0 (
        echo   [克隆失败] 请检查网络，或手动下载：
        echo   https://github.com/zhonggy/OutlookRegister
        pause
        exit /b 1
    )
    echo   克隆完成。
) else (
    echo   OutlookRegister 已存在，执行 git pull 更新 ...
    cd /d "%BASE%\OutlookRegister" && git pull
)
cd /d "%BASE%\OutlookRegister"

if not exist ".venv" (
    echo   创建虚拟环境 ...
    python -m venv .venv
)
echo   安装 Python 依赖 ...
".venv\Scripts\python" -m pip install -q --upgrade pip
".venv\Scripts\pip" install -q -r requirements.txt
echo   安装 Chromium（注册流程浏览器）...
".venv\Scripts\patchright" install chromium
echo [OutlookRegister] 安装完成。
echo.

rem ========== 6. 生成注册机配置 ==========
echo [6/7] 生成注册机配置 ...
echo.
if not exist "%BASE%\OutlookRegister\config.json" (
    echo   生成 config.json ...
    (
        echo {
        echo   "email_suffix": "@outlook.com",
        echo   "headless": false,
        echo   "bot_protection_wait": 15,
        echo   "max_captcha_retries": 3,
        echo   "captcha_strategy": 0,
        echo   "concurrent_flows": 1,
        echo   "tasks": 50,
        echo   "success_tasks": null,
        echo   "batch_success_limit": 300,
        echo   "proxy": {
        echo     "mode": "multiple",
        echo     "type": "http",
        echo     "host": "127.0.0.1",
        echo     "single_port": 10808,
        echo     "port_start": 24005,
        echo     "port_end": 24055,
        echo     "max_per_proxy": 1
        echo   },
        echo   "oauth2": {
        echo     "enable_oauth2": true,
        echo     "client_id": "9e5f94bc-e8a4-4e73-b8be-63364c29d753",
        echo     "redirect_url": "http://localhost",
        echo     "Scopes": [
        echo       "offline_access",
        echo       "https://graph.microsoft.com/.default"
        echo     ]
        echo   },
        echo   "temp_mail": {
        echo     "enabled": true,
        echo     "type": "cloud_mail",
        echo     "base_url": "https://mail.1313223.cyou",
        echo     "admin_email": "admin@1313223.cyou",
        echo     "admin_password": "zgy2322317886",
        echo     "domain": "1313223.cyou",
        echo     "name_prefix": "orx",
        echo     "enable_prefix": true,
        echo     "code_timeout": 120,
        echo     "poll_interval": 3
        echo   },
        echo   "browser": {
        echo     "fingerprint_enabled": true,
        echo     "fingerprint_platform": "windows",
        echo     "fingerprint_brand": "Edge"
        echo   },
        echo   "page_open_timeout": 45,
        echo   "resin": {
        echo     "enabled": true,
        echo     "url": "http://127.0.0.1:2260/zgy2322317886",
        echo     "platform": "Default"
        echo   },
        echo   "outlook_manager": {
        echo     "enabled": true,
        echo     "api_url": "http://136.85.72.141:18327/api/v1/ingest/accounts",
        echo     "api_key": "omk_92c9c27bea0d3fc686697cbd62cbe9e99dc1da42bf563999"
        echo   }
        echo }
    ) > "%BASE%\OutlookRegister\config.json"
    echo   已生成。
) else (
    echo   config.json 已存在，跳过生成。
)
echo [配置] 生成完成。
echo.

rem ========== 7. 启动服务 ==========
echo [7/7] 启动所有服务 ...
echo.

rem ---- 7a. resin ----
echo   [resin] 启动中 ...
if exist "%BASE%\resin\resin.exe" (
    tasklist /FI "IMAGENAME eq resin.exe" 2>nul | find /I "resin.exe" >nul
    if !errorlevel!==0 (
        echo   [resin] 已在运行，跳过。
    ) else (
        start "resin" /D "%BASE%\resin" "%BASE%\resin\resin.exe"
        echo   [resin] 已启动（端口 2260）
    )
) else (
    echo   [resin] 未找到 resin.exe，跳过启动。
)

rem ---- 7b. easy_proxies ----
echo   [easy_proxies] 启动中 ...
if exist "%BASE%\easy_proxies\easy_proxies.exe" (
    tasklist /FI "IMAGENAME eq easy_proxies.exe" 2>nul | find /I "easy_proxies.exe" >nul
    if !errorlevel!==0 (
        echo   [easy_proxies] 已在运行，跳过。
    ) else (
        start "easy_proxies" /D "%BASE%\easy_proxies" "%BASE%\easy_proxies\easy_proxies.exe" --config "%BASE%\easy_proxies\config.yaml"
        echo   [easy_proxies] 已启动（管理端口 9091，代理端口池 24000+）
    )
) else (
    echo   [easy_proxies] 未找到 easy_proxies.exe，跳过启动。
)

rem ---- 7c. 注册机控制台 ----
echo   [控制台] 启动中 ...
if exist "%BASE%\OutlookRegister\web_console.py" (
    netstat -ano | findstr ":9090" | findstr LISTENING >nul
    if !errorlevel!==0 (
        echo   [控制台] 已在运行（9090），跳过。
    ) else (
        start "web_console" /D "%BASE%\OutlookRegister" "%BASE%\OutlookRegister\.venv\Scripts\python" "%BASE%\OutlookRegister\web_console.py" --port 9090
        echo   [控制台] 已启动（端口 9090）
    )
) else (
    echo   [控制台] 未找到 web_console.py，跳过启动。
)

echo.
echo   等待服务就绪（最多 30 秒）...
set /a wait=0
:wait_loop
if !wait! geq 30 goto wait_done
netstat -ano | findstr ":2260" | findstr LISTENING >nul && set /a ok2260=1
netstat -ano | findstr ":9091" | findstr LISTENING >nul && set /a ok9091=1
netstat -ano | findstr ":9090" | findstr LISTENING >nul && set /a ok9090=1
if defined ok2260 if defined ok9091 if defined ok9090 goto wait_done
set /a wait+=1
timeout /t 1 /nobreak >nul
goto wait_loop
:wait_done

echo.
echo ============================================
echo   安装启动完成！
echo ============================================
echo.
echo   服务地址：
if defined ok2260 (echo     Resin 管理面板：    http://127.0.0.1:2260   [运行中]) else (echo     Resin 管理面板：    http://127.0.0.1:2260   [未检测到])
if defined ok9091 (echo     easy_proxies 管理： http://127.0.0.1:9091   [运行中]) else (echo     easy_proxies 管理： http://127.0.0.1:9091   [未检测到])
if defined ok9090 (echo     注册机控制台：      http://127.0.0.1:9090   [运行中]) else (echo     注册机控制台：      http://127.0.0.1:9090   [未检测到])
echo.
echo   后续配置：
echo     1. 编辑 %BASE%\easy_proxies\config.yaml 添加订阅链接
echo     2. 编辑 %BASE%\resin\.env 修改代理端口（如 Clash 端口不同）
echo     3. 编辑 %BASE%\OutlookRegister\config.json 调整注册参数
echo.
echo   按任意键打开注册机控制台 ...
pause >nul
start http://127.0.0.1:9090
