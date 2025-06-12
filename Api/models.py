from flask import current_app
from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin
from datetime import datetime
import json

db = SQLAlchemy()

class User(UserMixin, db.Model):
    __tablename__ = 'launcher_user'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    is_admin = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    last_login = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f'<User {self.username}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'is_admin':self.is_admin,
            'created_at':self.created_at,
            'last_login': self.updated_at
        }

class launcher_ban(db.Model):
    __tablename__ = 'launcher_ban'
    id = db.Column(db.Integer, primary_key=True)
    hwid = db.Column(db.String(255), unique=True, nullable=False)
    serial_number = db.Column(db.String(255), nullable=True)
    reason = db.Column(db.String(255), nullable=True)
    mac_address = db.Column(db.String(255), nullable=True)
    is_banned = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f'<Blacklist {self.hwid}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'hwid': self.hwid,
            'serial_number': self.serial_number,
            'reason': self.reason,
            'mac_address': self.mac_address,
            'is_banned': self.is_banned,
            'created_at': self.created_at.strftime('%Y-%m-%d %H:%M:%S')
        }


class GameVersion(db.Model):
    __tablename__ = 'launcher_game_version'
    id = db.Column(db.Integer, primary_key=True)
    version = db.Column(db.String(20), unique=True, nullable=False)
    is_latest = db.Column(db.Boolean, default=False)
    release_notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    created_by = db.Column(db.Integer, db.ForeignKey('launcher_user.id'))
    
    # Relaciones
    update_packages = db.relationship('UpdatePackage', backref='version', lazy=True)
    files = db.relationship('GameFile', backref='version', lazy=True)

    def __repr__(self):
        return f'<GameVersion {self.version}>'

    @staticmethod
    def get_latest():
        return GameVersion.query.filter_by(is_latest=True).first()

    def set_as_latest(self):
        try:
            current_latest = GameVersion.get_latest()

            # Paso 1: desactivar la anterior
            if current_latest and current_latest.id != self.id:
                current_latest.is_latest = False
                db.session.flush()  # 👈 Aplica cambios a DB sin cerrar la transacción

            # Paso 2: activar la nueva
            self.is_latest = True

            db.session.commit()
            
        except Exception as e:
            db.session.rollback()
            raise RuntimeError(f"No se pudo establecer la versión como última: {e}")

        
    def to_dict(self):
        return {
            'id': self.id,
            'version': self.version,
            'is_latest': self.is_latest,
            'release_notes': self.release_notes,
            'created_at': self.created_at.strftime('%Y-%m-%d %H:%M:%S'),
            'created_by': self.created_by,
            'files': [f.to_dict() for f in self.files],
            'update_packages': [u.id for u in self.update_packages]
        }

class UpdatePackage(db.Model):
    __tablename__ = 'launcher_update_package'
    id = db.Column(db.Integer, primary_key=True)
    filename = db.Column(db.String(255), nullable=False)
    version_id = db.Column(db.Integer, db.ForeignKey('launcher_game_version.id'), nullable=False)
    file_path = db.Column(db.String(500), nullable=False)
    file_size = db.Column(db.Integer)
    md5_hash = db.Column(db.String(32))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    uploaded_by = db.Column(db.Integer, db.ForeignKey('launcher_user.id'))

    def __repr__(self):
        return f'<UpdatePackage {self.filename}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'filename': self.filename,
            'version_id': self.version_id,
            'file_path': self.file_path,
            'file_size': self.file_size,
            'md5_hash': self.md5_hash,
            'created_at': self.created_at.strftime('%Y-%m-%d %H:%M:%S'),
            'uploaded_by': self.uploaded_by
        }


class GameFile(db.Model):
    __tablename__ = 'launcher_game_file'
    id = db.Column(db.Integer, primary_key=True)
    filename = db.Column(db.String(255), nullable=False)
    relative_path = db.Column(db.String(500), nullable=False)
    md5_hash = db.Column(db.String(32), nullable=False)
    file_size = db.Column(db.Integer)
    version_id = db.Column(db.Integer, db.ForeignKey('launcher_game_version.id'))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self):
        return f'<GameFile {self.filename}>'

    def to_dict(self):
        return {
            'FileName': self.filename,
            'RelativePath': self.relative_path,
            'MD5Hash': self.md5_hash
        }

class LauncherVersion(db.Model):
    __tablename__ = 'launcher_version'
    id = db.Column(db.Integer, primary_key=True)
    version = db.Column(db.String(20), nullable=False)
    filename = db.Column(db.String(255), nullable=False)
    file_path = db.Column(db.String(500), nullable=False)
    is_current = db.Column(db.Boolean, default=False)
    release_notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    created_by = db.Column(db.Integer, db.ForeignKey('launcher_user.id'))

    def __repr__(self):
        return f'<LauncherVersion {self.version}>'

    @staticmethod
    def get_current():
        return LauncherVersion.query.filter_by(is_current=True).first()

    def set_as_current(self):
        # Desmarcar la versión actual
        current = LauncherVersion.get_current()
        if current:
            current.is_current = False
        
        # Marcar esta versión como actual
        self.is_current = True
        db.session.commit()
    
    def to_dict(self):
        return {
            'id': self.id,
            'version': self.version,
            'filename': self.filename,
            'file_path': self.file_path,
            'is_current': self.is_current,
            'release_notes': self.release_notes,
            'created_at': self.created_at.strftime('%Y-%m-%d %H:%M:%S'),
            'created_by': self.created_by
        }


class NewsMessage(db.Model):
    __tablename__ = 'launcher_news_message'
    id = db.Column(db.Integer, primary_key=True)
    type = db.Column(db.String(50), nullable=False)  # 'Actualización', 'Noticia', etc.
    message = db.Column(db.Text, nullable=False)
    is_active = db.Column(db.Boolean, default=True)
    priority = db.Column(db.Integer, default=0)  # Para ordenamiento
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    created_by = db.Column(db.Integer, db.ForeignKey('launcher_user.id'))

    def __repr__(self):
        return f'<NewsMessage {self.type}: {self.message[:50]}>'

    def to_dict(self):
        return {
            'type': self.type,
            'message': self.message
        }

class ServerSettings(db.Model):
    __tablename__ = 'launcher_server_settings'
    id = db.Column(db.Integer, primary_key=True)
    key = db.Column(db.String(100), unique=True, nullable=False)
    value = db.Column(db.Text, nullable=False)
    description = db.Column(db.String(255))
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    updated_by = db.Column(db.Integer, db.ForeignKey('launcher_user.id'))

    def __repr__(self):
        return f'<ServerSettings {self.key}: {self.value}>'

    @staticmethod
    def get_value(key, default=None):
        setting = ServerSettings.query.filter_by(key=key).first()
        return setting.value if setting else default

    @staticmethod
    def set_value(key, value, description=None):
        setting = ServerSettings.query.filter_by(key=key).first()
        if setting:
            setting.value = value
            if description:
                setting.description = description
        else:
            setting = ServerSettings(key=key, value=value, description=description)
            db.session.add(setting)
        
        db.session.commit()
        return setting

class DownloadLog(db.Model):
    __tablename__ = 'launcher_download_log'
    id = db.Column(db.Integer, primary_key=True)
    ip_address = db.Column(db.String(45), nullable=False)
    user_agent = db.Column(db.String(500))
    file_requested = db.Column(db.String(255), nullable=False)
    file_type = db.Column(db.String(50))  # 'update', 'launcher', 'game_file'
    success = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f'<DownloadLog {self.ip_address}: {self.file_requested}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'ip_address': self.ip_address,
            'user_agent': self.user_agent,
            'file_requested': self.file_requested,
            'file_type': self.file_type,
            'success': self.success,
            'created_at': self.created_at.strftime('%Y-%m-%d %H:%M:%S')
        }

# Agregar estos modelos a models.py

class SystemConfig(db.Model):
    """Configuración general del sistema"""
    __tablename__ = 'launcher_system_config'
    
    id = db.Column(db.Integer, primary_key=True)
    
    # Configuración General
    system_name = db.Column(db.String(255), default='Launcher Admin Panel')
    admin_email = db.Column(db.String(255), default='admin@localhost')
    timezone = db.Column(db.String(100), default='America/Mexico_City')
    language = db.Column(db.String(10), default='es')
    
    # Estados del sistema
    maintenance_mode = db.Column(db.Boolean, default=False)
    maintenance_message = db.Column(db.Text, default='Sistema en mantenimiento')
    debug_mode = db.Column(db.Boolean, default=False)
    
    # Configuración del Launcher
    launcher_base_url = db.Column(db.String(500), default='http://localhost:5000/Launcher')
    update_check_interval = db.Column(db.Integer, default=300)  # segundos
    max_download_retries = db.Column(db.Integer, default=3)
    connection_timeout = db.Column(db.Integer, default=30)  # segundos
    
    # Configuración de Actualizaciones
    auto_update_enabled = db.Column(db.Boolean, default=True)
    force_ssl = db.Column(db.Boolean, default=False)
    
    proxy_enabled = db.Column(db.Boolean, default=False)
    proxy_port = db.Column(db.Integer, default=8080)
    proxy_ip = db.Column(db.String(255), default='127.0.0.1')
    
    # Configuración de Seguridad
    session_duration_hours = db.Column(db.Integer, default=24)
    max_login_attempts = db.Column(db.Integer, default=5)
    download_rate_limit = db.Column(db.Integer, default=100)  # por hora
    ip_ban_duration_minutes = db.Column(db.Integer, default=60)
    rate_limiting_enabled = db.Column(db.Boolean, default=True)
    log_all_requests = db.Column(db.Boolean, default=True)
    
    # Lista blanca de IPs (JSON)
    ip_whitelist = db.Column(db.Text)  # JSON array
    
    # Configuración de Notificaciones
    webhook_url = db.Column(db.String(500))
    notification_email = db.Column(db.String(255))
    alert_level = db.Column(db.String(50), default='errors_only')  # all, warnings, errors_only
    
    # Tipos de notificación
    notify_new_versions = db.Column(db.Boolean, default=True)
    notify_system_errors = db.Column(db.Boolean, default=True)
    notify_high_traffic = db.Column(db.Boolean, default=False)
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    updated_by = db.Column(db.Integer, db.ForeignKey('launcher_user.id'))

    def __repr__(self):
        return f'<SystemConfig {self.system_name}>'

    @staticmethod
    def get_config():
        """Obtener configuración actual del sistema"""
        config = SystemConfig.query.first()
        if not config:
            # Crear configuración por defecto
            config = SystemConfig()
            db.session.add(config)
            db.session.commit()
        return config

    def to_dict(self):
        """Convertir a diccionario para API"""
        return {
            'id': self.id,
            'system_name': self.system_name,
            'admin_email': self.admin_email,
            'timezone': self.timezone,
            'language': self.language,
            'maintenance_mode': self.maintenance_mode,
            'maintenance_message': self.maintenance_message,
            'debug_mode': self.debug_mode,
            'launcher_base_url': self.launcher_base_url,
            'update_check_interval': self.update_check_interval,
            'max_download_retries': self.max_download_retries,
            'connection_timeout': self.connection_timeout,
            'auto_update_enabled': self.auto_update_enabled,
            'force_ssl': self.force_ssl,
            'proxy_enabled': self.proxy_enabled,
            'proxy_port': self.proxy_port,
            'proxy_ip': self.proxy_ip,
            'session_duration_hours': self.session_duration_hours,
            'max_login_attempts': self.max_login_attempts,
            'download_rate_limit': self.download_rate_limit,
            'ip_ban_duration_minutes': self.ip_ban_duration_minutes,
            'rate_limiting_enabled': self.rate_limiting_enabled,
            'log_all_requests': self.log_all_requests,
            'ip_whitelist': json.loads(self.ip_whitelist) if self.ip_whitelist else [],
            'webhook_url': self.webhook_url,
            'notification_email': self.notification_email,
            'alert_level': self.alert_level,
            'notify_new_versions': self.notify_new_versions,
            'notify_system_errors': self.notify_system_errors,
            'notify_high_traffic': self.notify_high_traffic,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

    def update_from_dict(self, data):
        """Actualizar configuración desde diccionario"""
        allowed_fields = [
            'system_name', 'admin_email', 'timezone', 'language',
            'maintenance_mode', 'maintenance_message', 'debug_mode',
            'launcher_base_url', 'update_check_interval', 'max_download_retries',
            'connection_timeout', 'auto_update_enabled', 'force_ssl',
            'proxy_enabled', 'proxy_port', 'proxy_ip',
            'session_duration_hours', 'max_login_attempts', 'download_rate_limit',
            'ip_ban_duration_minutes', 'rate_limiting_enabled', 'log_all_requests',
            'webhook_url', 'notification_email', 'alert_level',
            'notify_new_versions', 'notify_system_errors', 'notify_high_traffic'
        ]
        
        for field in allowed_fields:
            if field in data:
                setattr(self, field, data[field])
        
        # Manejar IP whitelist especialmente
        if 'ip_whitelist' in data:
            self.ip_whitelist = json.dumps(data['ip_whitelist'])
        
        self.updated_at = datetime.utcnow()

class SystemStatus(db.Model):
    """Estado actual del sistema para monitoreo"""
    __tablename__ = 'launcher_system_status'
    
    id = db.Column(db.Integer, primary_key=True)
    
    # Estado general
    is_online = db.Column(db.Boolean, default=True)
    is_maintenance = db.Column(db.Boolean, default=False)
    
    # Métricas del sistema
    cpu_usage = db.Column(db.Float, default=0.0)
    memory_usage = db.Column(db.Float, default=0.0)
    disk_usage = db.Column(db.Float, default=0.0)
    
    # Estadísticas de tráfico
    active_downloads = db.Column(db.Integer, default=0)
    total_connections = db.Column(db.Integer, default=0)
    bandwidth_usage = db.Column(db.Float, default=0.0)  # MB/s
    
    # Contadores
    total_requests_today = db.Column(db.Integer, default=0)
    failed_requests_today = db.Column(db.Integer, default=0)
    
    # Timestamps
    last_updated = db.Column(db.DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<SystemStatus {self.last_updated}>'
    
    @staticmethod
    def get_current():
        """Obtener estado actual del sistema"""
        status = SystemStatus.query.order_by(SystemStatus.last_updated.desc()).first()
        if not status:
            status = SystemStatus()
            db.session.add(status)
            db.session.commit()
        return status
    
    def to_dict(self):
        return {
            'is_online': self.is_online,
            'is_maintenance': self.is_maintenance,
            'cpu_usage': self.cpu_usage,
            'memory_usage': self.memory_usage,
            'disk_usage': self.disk_usage,
            'active_downloads': self.active_downloads,
            'total_connections': self.total_connections,
            'bandwidth_usage': self.bandwidth_usage,
            'total_requests_today': self.total_requests_today,
            'failed_requests_today': self.failed_requests_today,
            'last_updated': self.last_updated.isoformat() if self.last_updated else None
        }

class NotificationLog(db.Model):
    """Log de notificaciones enviadas"""
    __tablename__ = 'launcher_notification_log'
    
    id = db.Column(db.Integer, primary_key=True)
    notification_type = db.Column(db.String(100), nullable=False)
    title = db.Column(db.String(255), nullable=False)
    message = db.Column(db.Text, nullable=False)
    recipient = db.Column(db.String(255))  # email or webhook URL
    status = db.Column(db.String(50), default='pending')  # pending, sent, failed
    error_message = db.Column(db.Text)
    sent_at = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<NotificationLog {self.notification_type}: {self.title}>'
    
# ==================== AGREGAR AL ARCHIVO models.py ====================

class Account(db.Model):
    """Modelo para la tabla de cuentas de jugadores"""
    __tablename__ = 'accounts'
    
    player_id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), unique=True, nullable=False, index=True)
    password = db.Column(db.String(64), nullable=False)
    token = db.Column(db.String(32), unique=True, nullable=True)
    
    # Campos adicionales que podrían existir en la tabla (opcional)
    # Puedes agregar más campos según tu esquema real
    
    def __repr__(self):
        return f'<Account {self.username}>'
    
    @staticmethod
    def authenticate(username, password):
        """
        Autenticar usuario con protección contra SQL injection
        
        Args:
            username (str): Nombre de usuario
            password (str): Contraseña en texto plano
            
        Returns:
            Account: Objeto Account si las credenciales son válidas, None si no
        """
        try:
            # Usar ORM para prevenir SQL injection
            account = Account.query.filter_by(username=username).first()
            
            if account and account.password == password:
                # Actualizar último login
                db.session.commit()
                return account
            
            return None
            
        except Exception as e:
            current_app.logger.error(f"Error en autenticación: {e}")
            db.session.rollback()
            return None
    
    def to_dict(self, include_sensitive=False):
        """
        Convertir a diccionario para API responses
        
        Args:
            include_sensitive (bool): Si incluir datos sensibles como password
            
        Returns:
            dict: Datos del usuario
        """
        data = {
            'player_id': self.player_id,
            'username': self.username,
            'token': self.token
        }
        
        # Solo incluir password si se solicita explícitamente (no recomendado)
        if include_sensitive:
            data['password'] = self.password
            
        return data
    

# ==================== TABLA PARA CONTROL DE INTENTOS DE LOGIN ====================

class LoginAttempt(db.Model):
    """Modelo para controlar intentos de login y mitigar fuerza bruta"""
    __tablename__ = 'login_attempts'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), nullable=False, index=True)
    ip_address = db.Column(db.String(45), nullable=False, index=True)
    success = db.Column(db.Boolean, default=False)
    attempt_time = db.Column(db.DateTime, default=datetime.utcnow, index=True)
    user_agent = db.Column(db.String(500), nullable=True)
    
    def __repr__(self):
        return f'<LoginAttempt {self.username} from {self.ip_address}>'
    
    @staticmethod
    def record_attempt(username, ip_address, success, user_agent=None):
        """
        Registrar intento de login
        
        Args:
            username (str): Nombre de usuario
            ip_address (str): Dirección IP
            success (bool): Si el login fue exitoso
            user_agent (str): User agent del navegador/launcher
        """
        try:
            attempt = LoginAttempt(
                username=username,
                ip_address=ip_address,
                success=success,
                user_agent=user_agent
            )
            db.session.add(attempt)
            db.session.commit()
            return True
        except Exception as e:
            current_app.logger.error(f"Error registrando intento de login: {e}")
            db.session.rollback()
            return False
    
    @staticmethod
    def check_brute_force(username=None, ip_address=None, time_window_minutes=15, max_attempts=5):
        """
        Verificar si hay demasiados intentos fallidos
        
        Args:
            username (str): Nombre de usuario a verificar
            ip_address (str): IP a verificar
            time_window_minutes (int): Ventana de tiempo en minutos
            max_attempts (int): Máximo de intentos permitidos
            
        Returns:
            bool: True si está bloqueado por fuerza bruta, False si puede intentar
        """
        try:
            from datetime import timedelta
            
            time_threshold = datetime.utcnow() - timedelta(minutes=time_window_minutes)
            
            # Construir query base
            query = LoginAttempt.query.filter(
                LoginAttempt.attempt_time >= time_threshold,
                LoginAttempt.success == False
            )
            
            # Filtrar por username o IP
            if username:
                query = query.filter(LoginAttempt.username == username)
            if ip_address:
                query = query.filter(LoginAttempt.ip_address == ip_address)
            
            failed_attempts = query.count()
            
            return failed_attempts >= max_attempts
            
        except Exception as e:
            current_app.logger.error(f"Error verificando fuerza bruta: {e}")
            return False  # En caso de error, permitir el intento
    
    @staticmethod
    def cleanup_old_attempts(days_to_keep=30):
        """
        Limpiar intentos de login antiguos
        
        Args:
            days_to_keep (int): Días de intentos a mantener
            
        Returns:
            int: Número de registros eliminados
        """
        try:
            from datetime import timedelta
            
            cutoff_date = datetime.utcnow() - timedelta(days=days_to_keep)
            
            deleted_count = LoginAttempt.query.filter(
                LoginAttempt.attempt_time < cutoff_date
            ).delete()
            
            db.session.commit()
            return deleted_count
            
        except Exception as e:
            current_app.logger.error(f"Error limpiando intentos antiguos: {e}")
            db.session.rollback()
            return 0
        
class BannerConfig(db.Model):
    """Configuración de banners del launcher"""
    __tablename__ = 'launcher_banner_config'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text)
    is_active = db.Column(db.Boolean, default=False)
    is_default = db.Column(db.Boolean, default=False)
    
    # Configuración del banner
    auto_rotate = db.Column(db.Boolean, default=True)
    rotation_interval = db.Column(db.Integer, default=6000)  # milliseconds
    responsive = db.Column(db.Boolean, default=True)
    show_controller = db.Column(db.Boolean, default=True)
    
    # Dimensiones
    width = db.Column(db.Integer, default=775)
    height = db.Column(db.Integer, default=394)
    
    # API Integration
    enable_socketio = db.Column(db.Boolean, default=True)
    enable_real_time = db.Column(db.Boolean, default=True)
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    created_by = db.Column(db.Integer, db.ForeignKey('launcher_user.id'))
    
    def __repr__(self):
        return f'<BannerConfig {self.name}>'
    
    @staticmethod
    def get_active():
        """Obtener banner activo"""
        return BannerConfig.query.filter_by(is_active=True).first()
    
    @staticmethod
    def get_default():
        """Obtener banner por defecto"""
        return BannerConfig.query.filter_by(is_default=True).first()
    
    def set_as_active(self):
        """Establecer como banner activo"""
        try:
            # Desactivar otros banners
            BannerConfig.query.update({'is_active': False})
            # Activar este banner
            self.is_active = True
            db.session.commit()
        except Exception as e:
            db.session.rollback()
            raise RuntimeError(f"No se pudo establecer banner activo: {e}")
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'is_active': self.is_active,
            'is_default': self.is_default,
            'auto_rotate': self.auto_rotate,
            'rotation_interval': self.rotation_interval,
            'responsive': self.responsive,
            'show_controller': self.show_controller,
            'width': self.width,
            'height': self.height,
            'enable_socketio': self.enable_socketio,
            'enable_real_time': self.enable_real_time,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class BannerSlide(db.Model):
    """Slides individuales del banner"""
    __tablename__ = 'launcher_banner_slide'
    
    id = db.Column(db.Integer, primary_key=True)
    banner_id = db.Column(db.Integer, db.ForeignKey('launcher_banner_config.id'), nullable=False)
    
    # Contenido del slide
    title = db.Column(db.String(255))
    content = db.Column(db.Text)
    image_url = db.Column(db.String(500))
    link_url = db.Column(db.String(500))
    
    # Configuración
    order_index = db.Column(db.Integer, default=0)
    is_active = db.Column(db.Boolean, default=True)
    duration = db.Column(db.Integer, default=6000)  # milliseconds para este slide específico
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relación
    banner = db.relationship('BannerConfig', backref=db.backref('slides', lazy=True, order_by='BannerSlide.order_index'))
    
    def __repr__(self):
        return f'<BannerSlide {self.title}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'banner_id': self.banner_id,
            'title': self.title,
            'content': self.content,
            'image_url': self.image_url,
            'link_url': self.link_url,
            'order_index': self.order_index,
            'is_active': self.is_active,
            'duration': self.duration,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }        