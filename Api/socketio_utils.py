"""
Utilidades para SocketIO
"""

from datetime import datetime
from flask import current_app
import json

def get_socketio():
    """Obtener la instancia de SocketIO de forma segura"""
    try:
        from app import socketio
        return socketio
    except ImportError:
        current_app.logger.warning("No se pudo importar socketio")
        return None

def emit_to_admin(event, data, room=None):
    """
    Emitir evento a todos los admins conectados
    
    Args:
        event (str): Nombre del evento
        data (dict): Datos a enviar
        room (str, optional): Sala específica (por defecto todos los admins)
    """
    socketio = get_socketio()
    if socketio:
        try:
            # Agregar timestamp automáticamente
            if isinstance(data, dict):
                data['timestamp'] = datetime.utcnow().isoformat()
            
            if room:
                socketio.emit(event, data, room=room, namespace='/admin')
            else:
                socketio.emit(event, data, namespace='/admin')
                
            current_app.logger.info(f"SocketIO: Evento '{event}' emitido a /admin")
        except Exception as e:
            current_app.logger.error(f"Error emitiendo evento SocketIO: {e}")
    else:
        current_app.logger.warning("SocketIO no disponible")

def notify_admin(message, type='info', data=None):
    """
    Enviar notificación a administradores
    
    Args:
        message (str): Mensaje de la notificación
        type (str): Tipo de notificación (success, info, warning, danger)
        data (dict, optional): Datos adicionales
    """
    emit_to_admin('notification', {
        'type': type,
        'message': message,
        'data': data or {}
    })

def broadcast_stats_update():
    """Enviar actualización de estadísticas a todos los admins"""
    try:
        from models import DownloadLog, GameVersion, GameFile, UpdatePackage, NewsMessage
        
        stats = {
            'total_downloads': DownloadLog.query.count(),
            'total_versions': GameVersion.query.count(),
            'total_files': GameFile.query.count(),
            'total_updates': UpdatePackage.query.count(),
            'active_messages': NewsMessage.query.filter_by(is_active=True).count(),
        }
        
        latest_version = GameVersion.get_latest()
        if latest_version:
            stats['latest_version'] = latest_version.version
        
        emit_to_admin('stats_update', stats)
        
    except Exception as e:
        current_app.logger.error(f"Error obteniendo estadísticas: {e}")

def notify_version_created(version, is_latest=False):
    """Notificar creación de nueva versión"""
    notify_admin(
        f"Nueva versión {version} creada" + (" (establecida como actual)" if is_latest else ""),
        'success',
        {
            'action': 'version_created',
            'version': version,
            'is_latest': is_latest
        }
    )

def notify_files_uploaded(count, version_id):
    """Notificar subida de archivos"""
    notify_admin(
        f"{count} archivo(s) subido(s) correctamente",
        'success',
        {
            'action': 'files_uploaded',
            'count': count,
            'version_id': version_id
        }
    )

def notify_update_created(version, filename):
    """Notificar creación de paquete de actualización"""
    notify_admin(
        f"Paquete de actualización creado para versión {version}",
        'success',
        {
            'action': 'update_created',
            'version': version,
            'filename': filename
        }
    )

def notify_message_created(message_type, is_active):
    """Notificar creación de mensaje"""
    status = "activo" if is_active else "inactivo"
    notify_admin(
        f"Nuevo mensaje {message_type} creado ({status})",
        'success',
        {
            'action': 'message_created',
            'type': message_type,
            'is_active': is_active
        }
    )

def notify_launcher_uploaded(version, is_current):
    """Notificar subida de nuevo launcher"""
    status = "establecida como actual" if is_current else "subida"
    notify_admin(
        f"Nueva versión del launcher {version} {status}",
        'success',
        {
            'action': 'launcher_uploaded',
            'version': version,
            'is_current': is_current
        }
    )

def notify_system_error(error_message, context=None):
    """Notificar error del sistema"""
    notify_admin(
        f"Error del sistema: {error_message}",
        'danger',
        {
            'action': 'system_error',
            'error': error_message,
            'context': context or {}
        }
    )

# Decorador para funciones que deben notificar via SocketIO
def socket_notify(success_message=None, error_message=None):
    """
    Decorador para notificar automáticamente el resultado de una función
    
    Usage:
        @socket_notify("Operación completada", "Error en operación")
        def my_function():
            # tu código aquí
            pass
    """
    def decorator(func):
        def wrapper(*args, **kwargs):
            try:
                result = func(*args, **kwargs)
                if success_message:
                    notify_admin(success_message, 'success')
                return result
            except Exception as e:
                if error_message:
                    notify_admin(f"{error_message}: {str(e)}", 'danger')
                raise
        return wrapper
    return decorator

# Clase para manejar eventos personalizados
class SocketIOEventHandler:
    """Manejador de eventos SocketIO personalizados"""
    
    @staticmethod
    def handle_download_activity():
        """Manejar actividad de descarga en tiempo real"""
        # Esta función se puede llamar desde api_routes.py cuando hay descargas
        try:
            from datetime import datetime, timedelta
            from models import DownloadLog
            
            # Obtener descargas de la última hora
            one_hour_ago = datetime.utcnow() - timedelta(hours=1)
            recent_downloads = DownloadLog.query.filter(
                DownloadLog.created_at >= one_hour_ago
            ).count()
            
            emit_to_admin('download_activity', {
                'recent_downloads': recent_downloads,
                'timestamp': datetime.utcnow().isoformat()
            })
            
        except Exception as e:
            current_app.logger.error(f"Error en handle_download_activity: {e}")
    
    @staticmethod
    def handle_user_activity(ip_address, action, details=None):
        """Manejar actividad de usuario"""
        emit_to_admin('user_activity', {
            'ip_address': ip_address,
            'action': action,
            'details': details or {},
            'timestamp': datetime.utcnow().isoformat()
        })

# Función para testing
def test_socketio_connection():
    """Función de prueba para SocketIO"""
    notify_admin("🧪 Prueba de SocketIO - Conexión funcionando correctamente", 'info', {
        'test': True,
        'timestamp': datetime.utcnow().isoformat()
    })

# ==================== NOTIFICACIONES SOCKETIO PARA HWID ====================

def notify_device_added(hwid, is_banned=False):
    """Notificar nuevo dispositivo agregado"""
    status = "baneado" if is_banned else "permitido"
    notify_admin(
        f"Nuevo dispositivo {status}: {hwid[:12]}...",
        'success' if not is_banned else 'warning',
        {
            'action': 'device_added',
            'hwid': hwid,
            'is_banned': is_banned
        }
    )

def notify_device_banned(hwid, reason):
    """Notificar dispositivo baneado"""
    notify_admin(
        f"Dispositivo baneado: {hwid[:12]}...",
        'warning',
        {
            'action': 'device_banned',
            'hwid': hwid,
            'reason': reason
        }
    )

def notify_device_unbanned(hwid):
    """Notificar dispositivo desbaneado"""
    notify_admin(
        f"Dispositivo desbaneado: {hwid[:12]}...",
        'success',
        {
            'action': 'device_unbanned',
            'hwid': hwid
        }
    )

def notify_device_deleted(hwid):
    """Notificar dispositivo eliminado"""
    notify_admin(
        f"Dispositivo eliminado: {hwid[:12]}...",
        'info',
        {
            'action': 'device_deleted',
            'hwid': hwid
        }
    )

def notify_bulk_device_action(action, count):
    """Notificar acción en lote sobre dispositivos"""
    action_text = {
        'ban': 'baneados',
        'unban': 'desbaneados',
        'delete': 'eliminados'
    }
    
    notify_admin(
        f"{count} dispositivos {action_text.get(action, action)}",
        'success' if action in ['unban', 'delete'] else 'warning',
        {
            'action': f'bulk_{action}',
            'count': count,
            'bulk_action': action
        }
    )

def notify_hwid_system_alert(message, hwid=None, context=None):
    """Notificar alerta del sistema relacionada con HWID"""
    notify_admin(
        f"Alerta HWID: {message}",
        'danger',
        {
            'action': 'hwid_system_alert',
            'hwid': hwid,
            'context': context or {}
        }
    )

def broadcast_hwid_stats_update():
    """Enviar actualización de estadísticas de HWID a todos los admins"""
    try:
        from models import launcher_ban
        from datetime import datetime, timedelta
        
        total_devices = launcher_ban.query.count()
        banned_devices = launcher_ban.query.filter_by(is_banned=True).count()
        allowed_devices = launcher_ban.query.filter_by(is_banned=False).count()
        
        # Dispositivos nuevos en las últimas 24 horas
        twenty_four_hours_ago = datetime.utcnow() - timedelta(hours=24)
        new_devices_24h = launcher_ban.query.filter(
            launcher_ban.created_at >= twenty_four_hours_ago
        ).count()
        
        stats = {
            'total_devices': total_devices,
            'banned_devices': banned_devices,
            'allowed_devices': allowed_devices,
            'new_devices_24h': new_devices_24h,
            'ban_rate': round((banned_devices / total_devices * 100), 1) if total_devices > 0 else 0
        }
        
        emit_to_admin('hwid_stats_update', stats)
        
    except Exception as e:
        current_app.logger.error(f"Error obteniendo estadísticas de HWID: {e}")

# Clase para manejar eventos específicos de HWID
class HWIDEventHandler:
    """Manejador de eventos HWID en tiempo real"""
    
    @staticmethod
    def handle_new_device_registration(hwid, serial_number=None, mac_address=None):
        """Manejar registro de nuevo dispositivo en tiempo real"""
        try:
            emit_to_admin('new_device_registered', {
                'hwid': hwid[:12] + '...',  # Solo mostrar parte del HWID por seguridad
                'serial_number': serial_number,
                'mac_address': mac_address,
                'timestamp': datetime.utcnow().isoformat(),
                'requires_review': True
            })
            
            # También enviar notificación estándar
            notify_admin(
                f"🔍 Nuevo dispositivo detectado: {hwid[:12]}...",
                'info',
                {
                    'action': 'new_device_detected',
                    'hwid': hwid,
                    'requires_review': True
                }
            )
            
        except Exception as e:
            current_app.logger.error(f"Error en handle_new_device_registration: {e}")
    
    @staticmethod
    def handle_banned_device_attempt(hwid, reason):
        """Manejar intento de acceso de dispositivo baneado"""
        try:
            emit_to_admin('banned_device_attempt', {
                'hwid': hwid[:12] + '...',
                'reason': reason,
                'timestamp': datetime.utcnow().isoformat(),
                'severity': 'high'
            })
            
            # Notificación de alta prioridad
            notify_admin(
                f"🚨 Intento de acceso baneado: {hwid[:12]}...",
                'danger',
                {
                    'action': 'banned_device_attempt',
                    'hwid': hwid,
                    'reason': reason,
                    'priority': 'high'
                }
            )
            
        except Exception as e:
            current_app.logger.error(f"Error en handle_banned_device_attempt: {e}")
    
    @staticmethod
    def handle_suspicious_activity(hwid, activity_type, details=None):
        """Manejar actividad sospechosa de un dispositivo"""
        try:
            emit_to_admin('suspicious_device_activity', {
                'hwid': hwid[:12] + '...',
                'activity_type': activity_type,
                'details': details or {},
                'timestamp': datetime.utcnow().isoformat()
            })
            
            notify_admin(
                f"⚠️ Actividad sospechosa: {activity_type} - {hwid[:12]}...",
                'warning',
                {
                    'action': 'suspicious_activity',
                    'hwid': hwid,
                    'activity_type': activity_type,
                    'details': details
                }
            )
            
        except Exception as e:
            current_app.logger.error(f"Error en handle_suspicious_activity: {e}")

# Función para testing de HWID SocketIO
def test_hwid_socketio():
    """Función de prueba para SocketIO de HWID"""
    notify_admin("🧪 Prueba HWID SocketIO - Sistema de gestión funcionando", 'info', {
        'test': True,
        'module': 'hwid',
        'timestamp': datetime.utcnow().isoformat()
    })
    