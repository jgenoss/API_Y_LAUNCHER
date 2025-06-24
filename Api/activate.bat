@echo off
cd /d "%~dp0"
call launcher_env\Scripts\activate.bat
echo.
echo ✅ Entorno virtual activado
echo 📁 Directorio: %CD%
echo 🐍 Python: 
python --version
echo 📦 Pip:
pip --version
echo.
echo 💡 Comandos útiles:
echo    python app.py              - Iniciar servidor
echo    pip install paquete        - Instalar nuevo paquete
echo    pip freeze > requirements.txt - Guardar dependencias
echo    pip list                   - Ver paquetes instalados
echo    deactivate                 - Salir del entorno
echo.
cmd /k
