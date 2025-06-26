@echo off
cd /d "%~dp0"
call launcher_env\Scripts\activate.bat
echo 🚀 Iniciando Launcher Server...
echo 🌐 URL: http://localhost:5000
echo ⏹️  Presiona Ctrl+C para detener
echo.
python app.py
pause
