@echo off
chcp 65001 >nul
title OutlookRegister + Resin 代理池 - 一键安装启动脚本
cd /d "%~dp0"
setlocal enabledelayedexpansion

echo ============================================
echo   OutlookRegister 注册机 + Resin 代理池
echo   新电脑一键安装启动脚本
echo ============================================
echo.

rem ============================================
rem 0. 检测管理员权限（可选，部分操作需要）
rem ============================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [警告] 建议以管理员身份运行本脚本，否则某些操作可能失败。
    echo        按任意键继续，或关闭窗口重新以管理员身份运行。
    pause >nul
)

rem ============================================
rem 1. 检测前置依赖
rem ============================================
echo [1/7] 检测前置依赖 ...
echo.

where python >nul 2>nul
if %errorlevel% neq 0 (
    echo [需要操作] 未检测到 Python，请安装 Python 3.10+
    echo   下载地址：https://www.python.org/downloads/
    echo   安装时务必勾选 "Add python.exe to PATH"
    echo.
    echo 安装完成后请重新运行本脚本。
    pause
    exit /b 1
)
python --version

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [需要操作] 未检测到 Git，请安装 Git
    echo   下载地址：https://git-scm.com/download/win
    echo.
    echo 安装完成后请重新运行本脚本。
    pause
    exit /b 1
)
git --version

where curl >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未检测到 curl，Windows 10+ 应自带 curl。
    pause
    exit /b 1
)

echo.
echo [前置依赖] 全部就绪。
echo.

rem ============================================
rem 2. 创建目录结构
rem ============================================
echo [2/7] 创建目录结构 ...
if not exist "D:\out" mkdir D:\out
if not exist "D:\out\resin" mkdir D:\out\resin
if not exist "D:\out\resin\data" mkdir D:\out\resin\data
if not exist "D:\out\resin\data\state" mkdir D:\out\resin\data\state
if not exist "D:\out\resin\data\cache" mkdir D:\out\resin\data\cache
if not exist "D:\out\resin\data\log" mkdir D:\out\resin\data\log
if not exist "D:\out\easy_proxies" mkdir D:\out\easy_proxies
if not exist "D:\out\easy_proxies\logs" mkdir D:\out\easy_proxies\logs
echo [目录] 创建完成。
echo.

rem ============================================
rem 3. 安装 easy_proxies 代理池
rem ============================================
echo [3/7] 安装 easy_proxies 代理池 ...
echo.

if not exist "D:\out\easy_proxies\easy_proxies.exe" (
    echo   正在下载 easy_proxies v2.3.0 ...
    curl -L -o "D:\out\easy_proxies\easy_proxies.exe" ^
        "https://github.com/daimon3332/easy-proxies/releases/download/v2.3.0/easy_proxies-v2.3.0-windows-amd64.exe"
    if !errorlevel! neq 0 (
        echo   [下载失败] 请手动下载：
        echo   https://github.com/daimon3332/easy-proxies/releases/tag/v2.3.0
        echo   下载后放入 D:\out\easy_proxies\easy_proxies.exe
        pause
        exit /b 1
    )
    echo   下载完成。
) else (
    echo   easy_proxies.exe 已存在，跳过下载。
)

if not exist "D:\out\easy_proxies\config.yaml" (
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
        echo geoip:
        echo   enabled: false
        echo   database_path: ./GeoLite2-Country.mmdb
        echo   listen: ""
        echo   port: 0
        echo   auto_update_enabled: true
        echo   auto_update_interval: 24h0m0s
        echo log:
        echo   output: stdout
        echo   file: D:\out\easy_proxies\logs\easy_proxies.log
        echo   max_size: 50
        echo   max_backups: 3
        echo   max_age: 7
        echo   compress: false
        echo webdav:
        echo   address: ""
        echo   username: ""
        echo   password: ""
        echo   folder: /easy_proxies
        echo subscriptions: []
        echo nodes: []
        echo nodes_file: ""
        echo external_ip: ""
        echo log_level: ""
        echo skip_cert_verify: false
    ) > "D:\out\easy_proxies\config.yaml"
    echo   生成完成。
    echo   [重要] 请编辑 D:\out\easy_proxies\config.yaml，在 subscriptions 中添加你的代理订阅链接。
) else (
    echo   config.yaml 已存在，跳过生成。
)

echo [easy_proxies] 安装完成。
echo.

rem ============================================
rem 4. 安装 resin 代理池
rem ============================================
echo [4/7] 安装 resin 代理池 ...
echo.

if not exist "D:\out\resin\resin.exe" (
    echo   正在下载 resin v1.2.0 ...
    curl -L -o "D:\out\resin\resin.zip" ^
        "https://github.com/Resinat/Resin/releases/download/v1.2.0/resin-windows-amd64.zip"
    if !errorlevel! neq 0 (
        echo   [下载失败] 请手动下载：
        echo   https://github.com/Resinat/Resin/releases/tag/v1.2.0
        echo   下载 resin-windows-amd64.zip 并解压到 D:\out\resin\
        pause
        exit /b 1
    )
    echo   正在解压 ...
    powershell -Command "Expand-Archive -Path 'D:\out\resin\resin.zip' -DestinationPath 'D:\out\resin\' -Force"
    del "D:\out\resin\resin.zip"
    if exist "D:\out\resin\resin.exe" (
        echo   解压完成。
    ) else (
        echo   [解压失败] 请手动解压 resin-windows-amd64.zip 到 D:\out\resin\
        pause
        exit /b 1
    )
) else (
    echo   resin.exe 已存在，跳过下载。
)

if not exist "D:\out\resin\.env" (
    echo   生成 .env 配置文件 ...
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
        echo # 核心：走本地Clash代理（根据实际代理端口修改）
        echo HTTP_PROXY=http://127.0.0.1:7897
        echo HTTPS_PROXY=http://127.0.0.1:7897
        echo ALL_PROXY=socks5://127.0.0.1:7897
        echo.
        echo # 本地地址跳过代理，防止死循环
        echo NO_PROXY=127.0.0.1,localhost
    ) > "D:\out\resin\.env"
    echo   生成完成。
    echo   [注意] 如果使用不同的代理端口，请修改 .env 中的 HTTP_PROXY/HTTPS_PROXY。
) else (
    echo   .env 已存在，跳过生成。
)

echo [resin] 安装完成。
echo.

rem ============================================
rem 5. 安装 OutlookRegister
rem ============================================
echo [5/7] 安装 OutlookRegister 注册机 ...
echo.

if not exist "D:\out\OutlookRegister\.git" (
    echo   正在从 GitHub 克隆 OutlookRegister ...
    git clone https://github.com/zhonggy/OutlookRegister.git "D:\out\OutlookRegister"
    if !errorlevel! neq 0 (
        echo   [克隆失败] 请检查网络连接或手动下载：
        echo   https://github.com/zhonggy/OutlookRegister
        pause
        exit /b 1
    )
    echo   克隆完成。
) else (
    echo   OutlookRegister 已存在，执行 git pull 更新 ...
    cd /d "D:\out\OutlookRegister" && git pull
)

cd /d "D:\out\OutlookRegister"

if not exist ".venv" (
    echo   创建 Python 虚拟环境 ...
    python -m venv .venv
)

echo   安装 Python 依赖 ...
".venv\Scripts\python" -m pip install -q --upgrade pip
".venv\Scripts\pip" install -q -r requirements.txt

echo   安装 Chromium 浏览器（用于注册流程）...
".venv\Scripts\patchright" install chromium

echo.
echo [OutlookRegister] 安装完成。
echo.

rem ============================================
rem 6. 生成 config.json
rem ============================================
echo [6/7] 生成配置文件 ...
echo.

if not exist "D:\out\OutlookRegister\config.json" (
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
    ) > "D:\out\OutlookRegister\config.json"
    echo   生成完成。
) else (
    echo   config.json 已存在，跳过生成。
)

echo [配置文件] 生成完成。
echo.

rem ============================================
rem 7. 启动所有服务
rem ============================================
echo [7/7] 启动所有服务 ...
echo.

rem ---- 7a. 启动 resin 代理池 ----
echo   [resin] 正在启动 ...
if exist "D:\out\resin\resin.exe" (
    tasklist /FI "IMAGENAME eq resin.exe" 2>nul | find /I "resin.exe" >nul
    if !errorlevel!==0 (
        echo   [resin] 已在运行中，跳过。
    ) else (
        start "resin" /D "D:\out\resin" "D:\out\resin\resin.exe"
        echo   [resin] 已启动（端口 2260）
    )
) else (
    echo   [resin] resin.exe 不存在，跳过启动。
)

rem ---- 7b. 启动 easy_proxies 代理池 ----
echo   [easy_proxies] 正在启动 ...
if exist "D:\out\easy_proxies\easy_proxies.exe" (
    tasklist /FI "IMAGENAME eq easy_proxies.exe" 2>nul | find /I "easy_proxies.exe" >nul
    if !errorlevel!==0 (
        echo   [easy_proxies] 已在运行中，跳过。
    ) else (
        start "easy_proxies" /D "D:\out\easy_proxies" "D:\out\easy_proxies\easy_proxies.exe" --config "D:\out\easy_proxies\config.yaml"
        echo   [easy_proxies] 已启动（管理端口 9091，代理端口池 24000+）
    )
) else (
    echo   [easy_proxies] easy_proxies.exe 不存在，跳过启动。
)

rem ---- 7c. 启动 OutlookRegister Web 控制台 ----
echo   [OutlookRegister 控制台] 正在启动 ...
if exist "D:\out\OutlookRegister\web_console.py" (
    netstat -ano | findstr ":9090" | findstr LISTENING >nul
    if !errorlevel!==0 (
        echo   [控制台] 已在运行中（9090），跳过。
    ) else (
        start "web_console" /D "D:\out\OutlookRegister" "D:\out\OutlookRegister\.venv\Scripts\python" "D:\out\OutlookRegister\web_console.py" --port 9090
        echo   [控制台] 已启动（端口 9090）
    )
) else (
    echo   [控制台] web_console.py 不存在，跳过启动。
)

echo.
echo ============================================
echo   安装启动完成！
echo ============================================
echo.
echo   服务地址：
echo     Resin 管理面板：   http://127.0.0.1:2260
echo     注册机控制台：     http://127.0.0.1:9090
echo     easy_proxies 管理：http://127.0.0.1:9091
echo.
echo   后续配置：
echo     1. 编辑 D:\out\easy_proxies\config.yaml
echo         - 在 subscriptions 中添加代理订阅链接
echo     2. 编辑 D:\out\resin\.env（如需修改代理端口）
echo     3. 如需调整注册参数，编辑 D:\out\OutlookRegister\config.json
echo.
echo   按任意键打开注册机控制台，或关闭窗口结束。
echo.
pause >nul

start http://127.0.0.1:9090