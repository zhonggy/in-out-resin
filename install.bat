@echo off
rem 脚本使用 ANSI(GBK) 编码保存，Windows 默认代码页即可
title OutlookRegister + Resin ������ - һ����װ�����ű�
cd /d "%~dp0"
setlocal enabledelayedexpansion

echo ============================================
echo   OutlookRegister ע��� + Resin ������
echo   �µ���һ����װ�����ű�
echo ============================================
echo.

rem ============================================
rem 0. ������ԱȨ�ޣ���ѡ�����ֲ�����Ҫ��
rem ============================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [����] �����Թ���Ա�������б��ű�������ĳЩ��������ʧ�ܡ�
    echo        ���������������رմ��������Թ���Ա�������С�
    pause >nul
)

rem ============================================
rem 1. ���ǰ������
rem ============================================
echo [1/7] ���ǰ������ ...
echo.

where python >nul 2>nul
if %errorlevel% neq 0 (
    echo [��Ҫ����] δ��⵽ Python���밲װ Python 3.10+
    echo   ���ص�ַ��https://www.python.org/downloads/
    echo   ��װʱ��ع�ѡ "Add python.exe to PATH"
    echo.
    echo ��װ��ɺ����������б��ű���
    pause
    exit /b 1
)
python --version

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [��Ҫ����] δ��⵽ Git���밲װ Git
    echo   ���ص�ַ��https://git-scm.com/download/win
    echo.
    echo ��װ��ɺ����������б��ű���
    pause
    exit /b 1
)
git --version

where curl >nul 2>nul
if %errorlevel% neq 0 (
    echo [����] δ��⵽ curl��Windows 10+ Ӧ�Դ� curl��
    pause
    exit /b 1
)

echo.
echo [ǰ������] ȫ��������
echo.

rem ============================================
rem 2. ����Ŀ¼�ṹ
rem ============================================
echo [2/7] ����Ŀ¼�ṹ ...
if not exist "D:\out" mkdir D:\out
if not exist "D:\out\resin" mkdir D:\out\resin
if not exist "D:\out\resin\data" mkdir D:\out\resin\data
if not exist "D:\out\resin\data\state" mkdir D:\out\resin\data\state
if not exist "D:\out\resin\data\cache" mkdir D:\out\resin\data\cache
if not exist "D:\out\resin\data\log" mkdir D:\out\resin\data\log
if not exist "D:\out\easy_proxies" mkdir D:\out\easy_proxies
if not exist "D:\out\easy_proxies\logs" mkdir D:\out\easy_proxies\logs
echo [Ŀ¼] ������ɡ�
echo.

rem ============================================
rem 3. ��װ easy_proxies ������
rem ============================================
echo [3/7] ��װ easy_proxies ������ ...
echo.

if not exist "D:\out\easy_proxies\easy_proxies.exe" (
    echo   �������� easy_proxies v2.3.0 ...
    curl -L -o "D:\out\easy_proxies\easy_proxies.exe" ^
        "https://github.com/daimon3332/easy-proxies/releases/download/v2.3.0/easy_proxies-v2.3.0-windows-amd64.exe"
    if !errorlevel! neq 0 (
        echo   [����ʧ��] ���ֶ����أ�
        echo   https://github.com/daimon3332/easy-proxies/releases/tag/v2.3.0
        echo   ���غ���� D:\out\easy_proxies\easy_proxies.exe
        pause
        exit /b 1
    )
    echo   ������ɡ�
) else (
    echo   easy_proxies.exe �Ѵ��ڣ��������ء�
)

if not exist "D:\out\easy_proxies\config.yaml" (
    echo   ���� config.yaml ...
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
    echo   ������ɡ�
    echo   [��Ҫ] ��༭ D:\out\easy_proxies\config.yaml���� subscriptions ��������Ĵ����������ӡ�
) else (
    echo   config.yaml �Ѵ��ڣ��������ɡ�
)

echo [easy_proxies] ��װ��ɡ�
echo.

rem ============================================
rem 4. ��װ resin ������
rem ============================================
echo [4/7] ��װ resin ������ ...
echo.

if not exist "D:\out\resin\resin.exe" (
    echo   �������� resin v1.2.0 ...
    curl -L -o "D:\out\resin\resin.zip" ^
        "https://github.com/Resinat/Resin/releases/download/v1.2.0/resin-windows-amd64.zip"
    if !errorlevel! neq 0 (
        echo   [����ʧ��] ���ֶ����أ�
        echo   https://github.com/Resinat/Resin/releases/tag/v1.2.0
        echo   ���� resin-windows-amd64.zip ����ѹ�� D:\out\resin\
        pause
        exit /b 1
    )
    echo   ���ڽ�ѹ ...
    powershell -Command "Expand-Archive -Path 'D:\out\resin\resin.zip' -DestinationPath 'D:\out\resin\' -Force"
    del "D:\out\resin\resin.zip"
    if exist "D:\out\resin\resin.exe" (
        echo   ��ѹ��ɡ�
    ) else (
        echo   [��ѹʧ��] ���ֶ���ѹ resin-windows-amd64.zip �� D:\out\resin\
        pause
        exit /b 1
    )
) else (
    echo   resin.exe �Ѵ��ڣ��������ء�
)

if not exist "D:\out\resin\.env" (
    echo   ���� .env �����ļ� ...
    (
        echo # ��̨������Կ
        echo RESIN_ADMIN_TOKEN=zgy2322317886
        echo RESIN_PROXY_TOKEN="zgy2322317886"
        echo.
        echo # ���ݴ洢Ŀ¼
        echo RESIN_STATE_DIR=./data/state
        echo RESIN_CACHE_DIR=./data/cache
        echo RESIN_LOG_DIR=./data/log
        echo.
        echo # ��������˿�
        echo RESIN_LISTEN_ADDRESS=0.0.0.0
        echo RESIN_PORT=2260
        echo.
        echo # ���ģ��߱���Clash����������ʵ�ʴ����˿��޸ģ�
        echo HTTP_PROXY=http://127.0.0.1:7897
        echo HTTPS_PROXY=http://127.0.0.1:7897
        echo ALL_PROXY=socks5://127.0.0.1:7897
        echo.
        echo # ���ص�ַ������������ֹ��ѭ��
        echo NO_PROXY=127.0.0.1,localhost
    ) > "D:\out\resin\.env"
    echo   ������ɡ�
    echo   [ע��] ���ʹ�ò�ͬ�Ĵ����˿ڣ����޸� .env �е� HTTP_PROXY/HTTPS_PROXY��
) else (
    echo   .env �Ѵ��ڣ��������ɡ�
)

echo [resin] ��װ��ɡ�
echo.

rem ============================================
rem 5. ��װ OutlookRegister
rem ============================================
echo [5/7] ��װ OutlookRegister ע��� ...
echo.

if not exist "D:\out\OutlookRegister\.git" (
    echo   ���ڴ� GitHub ��¡ OutlookRegister ...
    git clone https://github.com/zhonggy/OutlookRegister.git "D:\out\OutlookRegister"
    if !errorlevel! neq 0 (
        echo   [��¡ʧ��] �����������ӻ��ֶ����أ�
        echo   https://github.com/zhonggy/OutlookRegister
        pause
        exit /b 1
    )
    echo   ��¡��ɡ�
) else (
    echo   OutlookRegister �Ѵ��ڣ�ִ�� git pull ���� ...
    cd /d "D:\out\OutlookRegister" && git pull
)

cd /d "D:\out\OutlookRegister"

if not exist ".venv" (
    echo   ���� Python ���⻷�� ...
    python -m venv .venv
)

echo   ��װ Python ���� ...
".venv\Scripts\python" -m pip install -q --upgrade pip
".venv\Scripts\pip" install -q -r requirements.txt

echo   ��װ Chromium �����������ע�����̣�...
".venv\Scripts\patchright" install chromium

echo.
echo [OutlookRegister] ��װ��ɡ�
echo.

rem ============================================
rem 6. ���� config.json
rem ============================================
echo [6/7] ���������ļ� ...
echo.

if not exist "D:\out\OutlookRegister\config.json" (
    echo   ���� config.json ...
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
    echo   ������ɡ�
) else (
    echo   config.json �Ѵ��ڣ��������ɡ�
)

echo [�����ļ�] ������ɡ�
echo.

rem ============================================
rem 7. �������з���
rem ============================================
echo [7/7] �������з��� ...
echo.

rem ---- 7a. ���� resin ������ ----
echo   [resin] �������� ...
if exist "D:\out\resin\resin.exe" (
    tasklist /FI "IMAGENAME eq resin.exe" 2>nul | find /I "resin.exe" >nul
    if !errorlevel!==0 (
        echo   [resin] ���������У�������
    ) else (
        start "resin" /D "D:\out\resin" "D:\out\resin\resin.exe"
        echo   [resin] ���������˿� 2260��
    )
) else (
    echo   [resin] resin.exe �����ڣ�����������
)

rem ---- 7b. ���� easy_proxies ������ ----
echo   [easy_proxies] �������� ...
if exist "D:\out\easy_proxies\easy_proxies.exe" (
    tasklist /FI "IMAGENAME eq easy_proxies.exe" 2>nul | find /I "easy_proxies.exe" >nul
    if !errorlevel!==0 (
        echo   [easy_proxies] ���������У�������
    ) else (
        start "easy_proxies" /D "D:\out\easy_proxies" "D:\out\easy_proxies\easy_proxies.exe" --config "D:\out\easy_proxies\config.yaml"
        echo   [easy_proxies] �������������˿� 9091�������˿ڳ� 24000+��
    )
) else (
    echo   [easy_proxies] easy_proxies.exe �����ڣ�����������
)

rem ---- 7c. ���� OutlookRegister Web ����̨ ----
echo   [OutlookRegister ����̨] �������� ...
if exist "D:\out\OutlookRegister\web_console.py" (
    netstat -ano | findstr ":9090" | findstr LISTENING >nul
    if !errorlevel!==0 (
        echo   [����̨] ���������У�9090����������
    ) else (
        start "web_console" /D "D:\out\OutlookRegister" "D:\out\OutlookRegister\.venv\Scripts\python" "D:\out\OutlookRegister\web_console.py" --port 9090
        echo   [����̨] ���������˿� 9090��
    )
) else (
    echo   [����̨] web_console.py �����ڣ�����������
)

echo.
echo ============================================
echo   ��װ������ɣ�
echo ============================================
echo.
echo   �����ַ��
echo     Resin ������壺   http://127.0.0.1:2260
echo     ע�������̨��     http://127.0.0.1:9090
echo     easy_proxies ������http://127.0.0.1:9091
echo.
echo   �������ã�
echo     1. �༭ D:\out\easy_proxies\config.yaml
echo         - �� subscriptions �����Ӵ�����������
echo     2. �༭ D:\out\resin\.env�������޸Ĵ����˿ڣ�
echo     3. �������ע��������༭ D:\out\OutlookRegister\config.json
echo.
echo   ���������ע�������̨����رմ��ڽ�����
echo.
pause >nul

start http://127.0.0.1:9090