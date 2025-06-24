@echo off
cd /d "%~dp0"
call launcher_env\Scripts\activate.bat
echo 📦 Instalador de paquetes
echo.
if "%1"=="" (
    echo Uso: install_package.bat nombre_del_paquete
    echo Ejemplo: install_package.bat flask-cors
    pause
    exit /B 1
)
pip install %*
echo.
echo ✅ Paquete instalado
pause
