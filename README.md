# 🎮 Sistema de Gestión de Launcher de Juegos

## 📋 Descripción General

Sistema completo para la gestión, distribución y actualización de un launcher de juegos. Incluye un panel de administración web moderno y un launcher desktop para Windows que se comunican entre sí para proporcionar actualizaciones automáticas, gestión de versiones y distribución de contenido.

## 🏗️ Arquitectura del Sistema

### Componentes Principales

```
┌─────────────────────────────────────────────────────────────────┐
│                    ARQUITECTURA DEL SISTEMA                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐    ┌──────────────────┐    ┌─────────────┐ │
│  │   Launcher      │◄──►│   API Backend    │◄──►│  Base de    │ │
│  │   Desktop       │    │   (Flask/Python) │    │  Datos      │ │
│  │   (C#/.NET)     │    │                  │    │ PostgreSQL  │ │
│  └─────────────────┘    └──────────────────┘    └─────────────┘ │
│           │                       │                             │
│           │              ┌──────────────────┐                   │
│           │              │   Frontend Web   │                   │
│           │              │   (Vue.js +      │                   │
│           │              │   Bootstrap)     │                   │
│           │              └──────────────────┘                   │
│           │                       │                             │
│           └───────────────────────┼─────────────────────────────┘
│                                   │
│           ┌───────────────────────▼─────────────────────────────┐
│           │             SocketIO - Comunicación                 │
│           │              Tiempo Real                            │
│           └─────────────────────────────────────────────────────┘
└─────────────────────────────────────────────────────────────────┘
```

### 🔧 Stack Tecnológico

**Backend:**
- **Python 3.11+** con Framework Flask
- **PostgreSQL** como base de datos principal
- **SQLAlchemy** ORM para gestión de datos
- **Flask-SocketIO** para comunicación en tiempo real
- **Flask-Login** para autenticación
- **Gunicorn** para servidor de producción

**Frontend Web:**
- **Vue.js 2** como framework JavaScript
- **Bootstrap 5** para interfaz responsiva
- **Socket.IO Client** para comunicación en tiempo real
- **Bootstrap Icons** para iconografía

**Launcher Desktop:**
- **C# .NET Framework** para aplicación Windows
- **Windows Forms** para interfaz gráfica
- **HttpClient** para comunicación con API
- **JSON.NET** para serialización
- **SocketIO Client .NET** para comunicación en tiempo real

**DevOps:**
- **Docker** con soporte completo
- **Nginx** para proxy reverso (opcional)
- **Shell Scripts** para automatización

## 🚀 Características Principales

### 📊 Panel de Administración Web
- **Dashboard en tiempo real** con métricas del sistema
- **Gestión de versiones** de juegos y launcher
- **Subida y gestión de archivos** con validación MD5
- **Sistema de usuarios y autenticación**
- **Monitoreo de descargas y conexiones**
- **Gestión de banners y contenido dinámico**
- **Logs detallados y auditoría**

### 🖥️ Launcher Desktop
- **Actualizaciones automáticas** del juego y launcher
- **Interfaz moderna** con progreso en tiempo real
- **Verificación de integridad** de archivos (MD5)
- **Gestión de múltiples versiones**
- **Detección de herramientas de debugging** para seguridad
- **Configuración flexible** via JSON
- **Comunicación en tiempo real** con el servidor

### 🔄 Sistema de Actualizaciones
- **Distribución inteligente** de parches
- **Compresión automática** en formato ZIP
- **Versionado semántico** (X.Y.Z.W)
- **Rollback automático** en caso de error
- **Bandwidth monitoring** y control de carga
- **Actualizaciones incrementales**

### 🛡️ Seguridad
- **Autenticación robusta** con protección contra brute force
- **Validación de integridad** con checksums MD5
- **Rate limiting** en endpoints críticos
- **Protección CSRF** en formularios
- **Logs de seguridad** detallados
- **Detección de herramientas de debugging**

## 📁 Estructura del Proyecto

```
Game-Launcher-System/
├── Api/                              # Backend API (Python/Flask)
│   ├── app.py                       # Aplicación principal
│   ├── models.py                    # Modelos de base de datos
│   ├── config.py                    # Configuración
│   ├── utils.py                     # Utilidades generales
│   ├── api_routes.py                # Rutas de API
│   ├── admin_routes.py              # Rutas de administración
│   ├── public_socketio_utils.py     # SocketIO público
│   ├── requirements.txt             # Dependencias Python
│   ├── dockerfile.txt               # Configuración Docker
│   ├── setup_script.sh              # Script de instalación
│   ├── templates/                   # Templates HTML
│   │   └── admin/                   # Templates del panel admin
│   └── static/                      # Archivos estáticos
│       ├── css/                     # Estilos CSS
│       ├── js/                      # JavaScript/Vue.js
│       └── downloads/               # Archivos de descarga
├── PBLauncher/                      # Launcher Desktop (C#)
│   └── Launcher/                    # Proyecto principal
│       ├── LauncherForm.cs          # Formulario principal
│       ├── LauncherForm.Designer.cs # Diseñador de formulario
│       ├── Services/                # Servicios del launcher
│       │   └── SocketIOService.cs   # Servicio SocketIO
│       └── HttpDebuggerDetector.cs  # Detector de debugging
├── uploads/                         # Archivos subidos
│   ├── files/                       # Archivos del juego
│   └── updates/                     # Paquetes de actualización
├── logs/                           # Logs del sistema
├── backups/                        # Respaldos automáticos
└── web_shop.sql                    # Base de datos de ejemplo
```

## 🛠️ Instalación y Configuración

### Prerrequisitos

**Para el Backend:**
- Python 3.11 o superior
- PostgreSQL 13+ (o SQLite para desarrollo)
- pip (gestor de paquetes Python)

**Para el Launcher:**
- Visual Studio 2019+ o VS Code con extensiones C#
- .NET Framework 4.7.2+
- Windows 10/11

### 🐳 Instalación con Docker (Recomendado)

```bash
# Clonar el repositorio
git clone <repository-url>
cd Game-Launcher-System

# Construir imagen Docker
docker build -f Api/dockerfile.txt -t launcher-admin .

# Ejecutar contenedor
docker run -d \
  --name launcher-admin \
  -p 5000:5000 \
  -v launcher-uploads:/app/uploads \
  -v launcher-logs:/app/logs \
  -e SECRET_KEY="your-secret-key-here" \
  -e DATABASE_URL="postgresql://user:pass@host:port/db" \
  launcher-admin
```

### 📋 Instalación Manual

#### Backend (API)

```bash
# Navegar al directorio de la API
cd Api/

# Ejecutar script de instalación automática
chmod +x setup_script.sh
./setup_script.sh

# O instalación manual:
python3 -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
pip install -r requirements.txt
```

#### Configuración de Base de Datos

```bash
# Crear archivo .env
cp .env.example .env
# Editar .env con tus configuraciones

# Inicializar base de datos
python install.py

# Iniciar servidor
python run.py
```

#### Launcher Desktop

```bash
# Abrir proyecto en Visual Studio
cd PBLauncher/
# Abrir Launcher.sln
# Compilar proyecto (Ctrl+Shift+B)
```

## ⚙️ Configuración

### Variables de Entorno (.env)

```env
# Flask Configuration
FLASK_ENV=production
SECRET_KEY=your-super-secret-key-change-this-in-production
DEBUG=False

# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/launcher_db
SQLALCHEMY_TRACK_MODIFICATIONS=False

# Upload Configuration
UPLOAD_FOLDER=uploads
MAX_CONTENT_LENGTH=524288000  # 500MB

# Security Configuration
SESSION_COOKIE_SECURE=True
FORCE_HTTPS=True
API_RATE_LIMIT=100 per hour

# Launcher Configuration
LAUNCHER_URL_BASE=https://yourdomain.com/Launcher
LAUNCHER_CHECK_INTERVAL=300

# Backup Configuration
BACKUP_ENABLED=True
BACKUP_INTERVAL=3600
BACKUP_RETENTION_DAYS=30

# Notification Configuration
NOTIFICATION_ENABLED=True
NOTIFICATION_WEBHOOK_URL=https://your-webhook-url.com
```

### Configuración del Launcher (config.json)

```json
{
  "ServerUrl": "https://yourdomain.com",
  "ProxyIp": "127.0.0.1",
  "ProxyPort": 39191,
  "CheckInterval": 300,
  "AutoUpdate": true,
  "DebugMode": false,
  "UpdateOnStartup": true,
  "CloseAfterLaunch": false
}
```

## 🎯 Uso del Sistema

### Panel de Administración

1. **Acceso:** `http://localhost:5000/admin/login`
2. **Credenciales por defecto:** admin / admin123
3. **Funcionalidades:**
   - Subir nuevas versiones del juego
   - Gestionar archivos y versiones
   - Monitorear descargas y conexiones
   - Configurar banners y mensajes
   - Ver estadísticas en tiempo real

### Launcher Desktop

1. **Primera ejecución:** Configurar servidor en settings
2. **Actualización automática:** Se verifica al iniciar
3. **Lanzamiento:** Click en "Play" para iniciar juego
4. **Configuración:** Botón settings para opciones avanzadas

## 🔌 API Endpoints

### Endpoints Públicos

```http
# Estado del sistema
GET /api/status

# Información de versiones
GET /api/versions

# Descarga de archivos
GET /api/download/{filename}

# Verificación de launcher
GET /api/launcher/check

# Autenticación de jugadores
POST /api/auth/login
```

### Endpoints de Administración

```http
# Dashboard
GET /admin/

# Gestión de archivos
GET /admin/files
POST /admin/files/upload
DELETE /admin/files/{id}

# Gestión de versiones
GET /admin/versions
POST /admin/versions/create
PUT /admin/versions/{id}

# Gestión de launcher
GET /admin/launcher
POST /admin/launcher/upload
```

## 📊 Base de Datos

### Modelos Principales

- **User**: Usuarios del panel de administración
- **Account**: Cuentas de jugadores
- **GameVersion**: Versiones del juego
- **LauncherVersion**: Versiones del launcher
- **GameFile**: Archivos del juego con metadatos
- **SystemStatus**: Estado del sistema en tiempo real
- **DownloadLog**: Logs de descargas
- **LoginAttempt**: Control de intentos de login
- **NotificationLog**: Logs de notificaciones

### Esquema de Web Shop (Opcional)

- **web_shop**: Productos del juego
- **web_shop_category**: Categorías de productos

## 🔄 SocketIO Events

### Eventos del Cliente (Launcher → Servidor)

```javascript
// Conexión del launcher
launcher_connected

// Solicitud de datos iniciales
request_initial_data

// Reporte de progreso
update_progress

// Estado del launcher
launcher_status
```

### Eventos del Servidor (Servidor → Clientes)

```javascript
// Datos iniciales
initial_data

// Estado del sistema
system_status_changed

// Nueva versión disponible
version_available

// Progreso de descarga
download_progress

// Notificaciones
notification
```

## 🛡️ Seguridad

### Medidas Implementadas

1. **Autenticación robusta** con hash de contraseñas
2. **Rate limiting** en endpoints críticos
3. **Validación de archivos** con checksums MD5
4. **Protección CSRF** en formularios
5. **Sanitización de entradas** para prevenir XSS
6. **Logs de seguridad** detallados
7. **Detección de debugging tools** en el launcher

### Recomendaciones de Seguridad

- Cambiar credenciales por defecto
- Usar HTTPS en producción
- Configurar firewall apropiadamente
- Mantener dependencias actualizadas
- Revisar logs regularmente
- Implementar backup automático

## 🚦 Monitoreo y Logs

### Logs Disponibles

- **Sistema general**: `logs/launcher_admin.log`
- **Descargas**: Tabla `launcher_download_log`
- **Intentos de login**: Tabla `login_attempts`
- **Notificaciones**: Tabla `launcher_notification_log`

### Métricas en Tiempo Real

- CPU y memoria del servidor
- Conexiones activas
- Descargas en progreso
- Uso de bandwidth
- Requests por día

## 🔧 Troubleshooting

### Problemas Comunes

**Error de conexión SocketIO:**
```bash
# Verificar que el servidor esté ejecutándose
curl http://localhost:5000/api/status
```

**Error de base de datos:**
```bash
# Verificar conexión a PostgreSQL
psql -h localhost -U usuario -d launcher_db
```

**Launcher no actualiza:**
```bash
# Verificar configuración de servidor en config.json
# Verificar conectividad de red
# Revisar logs del launcher
```

## 📝 Desarrollo

### Estructura de Desarrollo

```bash
# Instalar dependencias de desarrollo
pip install -r requirements-dev.txt

# Ejecutar en modo desarrollo
export FLASK_ENV=development
python app.py

# Tests
python -m pytest tests/

# Linting
flake8 app.py
pylint *.py
```

### Contribuir

1. Fork del repositorio
2. Crear rama de feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit changes (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push to branch (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🤝 Soporte

Para soporte técnico:
- Crear issue en GitHub
- Revisar documentación en `/docs`
- Contactar: admin@localhost

## 🎯 Roadmap

### Próximas Características

- [ ] **Multi-idioma** en el panel admin
- [ ] **API REST completa** con OpenAPI/Swagger
- [ ] **Dashboard analytics** avanzado
- [ ] **Notificaciones push** en el launcher
- [ ] **Sistema de plugins** extensible
- [ ] **Distribución P2P** para actualizaciones grandes
- [ ] **Integración con Discord** para notificaciones
- [ ] **Auto-scaling** con Kubernetes

### Mejoras Planificadas

- [ ] Migración a **Vue 3** + **Composition API**
- [ ] **TypeScript** para mayor tipado
- [ ] **Redis** para cache y sesiones
- [ ] **Prometheus/Grafana** para métricas avanzadas
- [ ] **CI/CD pipeline** con GitHub Actions
- [ ] **Tests automatizados** completos

---

## 🔥 Características Destacadas

### ⚡ Alto Rendimiento
- Comunicación en tiempo real con SocketIO
- Compresión inteligente de archivos
- Cache optimizado para descargas
- Base de datos indexada apropiadamente

### 🎨 Interfaz Moderna
- Dashboard responsivo con Bootstrap 5
- Componentes Vue.js reutilizables
- Iconografía moderna con Bootstrap Icons
- Experiencia de usuario intuitiva

### 🔐 Seguridad Robusta
- Múltiples capas de validación
- Detección de herramientas de debugging
- Logs de auditoría completos
- Protección contra ataques comunes

### 📈 Escalabilidad
- Arquitectura modular y extensible
- Soporte Docker para deployment
- Base de datos PostgreSQL optimizada
- API REST bien estructurada

---

*Última actualización: Junio 2025*
