@echo off
chcp 936 >nul
echo ==================== 诊断 ====================
echo.

echo [1] 服务端口：
netstat -ano | findstr ":9090" | findstr LISTENING
netstat -ano | findstr ":2260" | findstr LISTENING

echo.
echo [2] 头一次测试直接用 curl（不加 auth，应返回 401 JSON）：
curl -s -X POST http://127.0.0.1:9090/api/resin/check
echo.

echo [3] 看注册机控制台 admin.json 是否存在：
if exist D:\out\OutlookRegister\admin.json (
    echo admin.json 存在
) else (
    echo admin.json 不存在（需要先设置管理员）
)

echo [4] 看控制台日志：
if exist D:\out\OutlookRegister\log\console.stderr.log (
    type D:\out\OutlookRegister\log\console.stderr.log
) else (
    echo 无 console.stderr.log
)

echo.
echo [5] 看 Clash 是否在运行：
tasklist | findstr /I "clash"
echo.
echo ==================== 完 ====================
pause