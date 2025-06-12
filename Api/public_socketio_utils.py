# ==================== public_socketio_utils.py CORREGIDO ====================

"""
Utilidades para SocketIO público - eventos para launchers
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

def emit_to_public(event, data, room=None):
    """
    Emitir evento a todos los launchers conectados al namespace público - VERSIÓN MEJORADA
    """
    socketio = get_socketio()
    if socketio:
        try:
            # Agregar timestamp automáticamente
            if isinstance(data, dict):
                data['timestamp'] = datetime.now().isoformat()
            
            if room:
                socketio.emit(event, data, room=room, namespace='/public')
                print(f"✅ SocketIO: Evento '{event}' emitido a room {room} en /public")
            else:
                socketio.emit(event, data, namespace='/public')
                print(f"✅ SocketIO: Evento '{event}' emitido a /public")
                
            current_app.logger.info(f"SocketIO: Evento '{event}' emitido a /public")
        except Exception as e:
            error_msg = f"Error emitiendo evento SocketIO público: {e}"
            print(f"❌ {error_msg}")
            current_app.logger.error(error_msg)
    else:
        warning_msg = "SocketIO no disponible"
        print(f"⚠️ {warning_msg}")
        current_app.logger.warning(warning_msg)

def emit_to_both_namespaces(event, admin_data, public_data=None):
    """
    Emitir evento tanto a admins como a launchers públicos
    
    Args:
        event (str): Nombre del evento
        admin_data (dict): Datos para admins
        public_data (dict, optional): Datos para público, usa admin_data si es None
    """
    try:
        # Emitir a admins
        try:
            from socketio_utils import emit_to_admin
            emit_to_admin(event, admin_data)
        except ImportError:
            print("⚠️ socketio_utils no disponible para admin")
        
        # Emitir a launchers públicos
        public_payload = public_data if public_data is not None else admin_data
        emit_to_public(event, public_payload)
        
        current_app.logger.info(f"Evento '{event}' emitido a ambos namespaces")
    except Exception as e:
        current_app.logger.error(f"Error emitiendo a ambos namespaces: {e}")

# ==================== EVENTOS ESPECÍFICOS PARA LAUNCHERS ====================

def notify_maintenance_mode_changed(enabled, message="Sistema en mantenimiento"):
    """Notificar cambio en modo mantenimiento a launchers"""
    public_data = {
        'enabled': enabled,
        'message': message,
        'status': 'maintenance' if enabled else 'online'
    }
    
    admin_data = {
        'maintenance_mode': enabled,
        'message': message,
        'action': 'maintenance_mode_changed'
    }
    
    emit_to_both_namespaces('maintenance_mode_changed', admin_data, public_data)

def notify_new_game_version_available(version, is_latest=True):
    """Notificar nueva versión del juego disponible"""
    public_data = {
        'version': version,
        'is_latest': is_latest,
        'type': 'game_update'
    }
    
    admin_data = {
        'version': version,
        'is_latest': is_latest,
        'action': 'new_game_version'
    }
    
    emit_to_both_namespaces('new_version_available', admin_data, public_data)

def notify_launcher_update_available(version, filename, is_current=True):
    """Notificar nueva versión del launcher disponible"""
    public_data = {
        'version': version,
        'file_name': filename,
        'is_current': is_current,
        'type': 'launcher_update'
    }
    
    admin_data = {
        'version': version,
        'filename': filename,
        'is_current': is_current,
        'action': 'launcher_update_available'
    }
    
    emit_to_both_namespaces('launcher_update_available', admin_data, public_data)

def notify_news_updated(news_messages):
    """Notificar actualización de noticias/mensajes - VERSIÓN MEJORADA"""
    try:
        print(f"📰 NOTIFY_NEWS_UPDATED - Procesando {len(news_messages)} mensajes...")
        
        # Formatear noticias para launchers
        public_news = []
        for msg in news_messages:
            if msg.is_active:  # Solo noticias activas
                news_item = {
                    'id': msg.id,
                    'type': msg.type,
                    'message': msg.message,
                    'priority': msg.priority,
                    'created_at': msg.created_at.isoformat() if msg.created_at else None
                }
                public_news.append(news_item)
                print(f"  ✅ Noticia activa: {msg.type} - {msg.message[:50]}...")
        
        print(f"📊 Total noticias activas para enviar: {len(public_news)}")
        
        # Datos para launchers públicos
        public_data = {
            'news': public_news,
            'count': len(public_news),
            'timestamp': datetime.utcnow().isoformat(),
            'action': 'news_updated'
        }
        
        # Datos para admins
        admin_data = {
            'action': 'news_updated',
            'count': len(public_news),
            'active_messages': len(public_news),
            'timestamp': datetime.utcnow().isoformat()
        }
        
        # Método 1: Usar función de emisión estándar
        try:
            emit_to_both_namespaces('news_updated', admin_data, public_data)
            print("✅ emit_to_both_namespaces ejecutado")
        except Exception as e:
            print(f"❌ Error en emit_to_both_namespaces: {e}")
        
        # Método 2: Envío directo como backup
        try:
            socketio = get_socketio()
            if socketio:
                # Enviar a namespace público
                socketio.emit('news_updated', public_data, namespace='/public')
                print(f"✅ Evento directo enviado a /public: {len(public_news)} noticias")
                
                # También enviar a admin
                socketio.emit('news_updated', admin_data, namespace='/admin')
                print("✅ Evento enviado a /admin")
                
            else:
                print("❌ SocketIO no disponible")
        except Exception as e:
            print(f"❌ Error en envío directo: {e}")
            current_app.logger.error(f"Error en envío directo de noticias: {e}")
        
        print(f"✅ notify_news_updated completado")
        
    except Exception as e:
        error_msg = f"Error notificando actualización de noticias: {e}"
        print(f"❌ {error_msg}")
        current_app.logger.error(error_msg)

def notify_system_status_changed(status_data):
    """Notificar cambio en el estado del sistema"""
    try:
        # Datos para launchers (más simples)
        public_data = {
            'status': status_data.get('status', 'unknown'),
            'maintenance_mode': status_data.get('maintenance_mode', False),
            'maintenance_message': status_data.get('maintenance_message'),
            'latest_game_version': status_data.get('latest_game_version'),
            'current_launcher_version': status_data.get('current_launcher_version'),
            'system_online': status_data.get('status') == 'online'
        }
        
        # Datos para admins (completos)
        admin_data = status_data.copy()
        admin_data['action'] = 'system_status_changed'
        
        emit_to_both_namespaces('system_status_changed', admin_data, public_data)
        
    except Exception as e:
        current_app.logger.error(f"Error notificando cambio de estado del sistema: {e}")

def broadcast_initial_data_to_banner(session_id=None):
    """Enviar datos iniciales a banner(es) específico(s) o todos - VERSIÓN MEJORADA"""
    try:
        print(f"📤 BROADCAST_INITIAL_DATA - Session: {session_id or 'ALL'}")
        
        from models import GameVersion, LauncherVersion, NewsMessage
        
        # Obtener datos actuales
        latest_version = GameVersion.get_latest()
        current_launcher = LauncherVersion.get_current()
        active_messages = NewsMessage.query.filter_by(is_active=True).order_by(
            NewsMessage.priority.desc(), NewsMessage.created_at.desc()
        ).all()
        
        print(f"📊 Datos obtenidos:")
        print(f"  - Game version: {latest_version.version if latest_version else 'N/A'}")
        print(f"  - Launcher version: {current_launcher.version if current_launcher else 'N/A'}")
        print(f"  - Mensajes activos: {len(active_messages)}")
        
        # Formatear noticias
        news_data = []
        for msg in active_messages:
            news_item = {
                'id': msg.id,
                'type': msg.type,
                'message': msg.message,
                'priority': msg.priority,
                'created_at': msg.created_at.isoformat() if msg.created_at else None
            }
            news_data.append(news_item)
            print(f"  📰 {msg.type}: {msg.message[:50]}...")
        
        # Datos iniciales
        initial_data = {
            'system_status': {
                'status': 'online',
                'latest_game_version': latest_version.version if latest_version else 'N/A',
                'current_launcher_version': current_launcher.version if current_launcher else 'N/A',
                'maintenance_mode': False  # Esto debería venir de SystemConfig
            },
            'news': news_data,
            'stats': {
                'players': 500,  # Conectar con datos reales
                'servers': '3/3',
                'status': 'online'
            },
            'timestamp': datetime.utcnow().isoformat(),
            'source': 'broadcast_initial_data'
        }
        
        socketio = get_socketio()
        if socketio:
            if session_id:
                # Enviar a session específica
                socketio.emit('initial_data', initial_data, room=session_id, namespace='/public')
                print(f"✅ Datos iniciales enviados a session {session_id}")
                current_app.logger.info(f"Datos iniciales enviados a session {session_id}")
            else:
                # Enviar a todos
                socketio.emit('initial_data', initial_data, namespace='/public')
                print(f"✅ Datos iniciales enviados a todos los banners")
                current_app.logger.info("Datos iniciales enviados a todos los banners")
        else:
            print("❌ SocketIO no disponible para broadcast_initial_data")
        
    except Exception as e:
        error_msg = f"Error enviando datos iniciales: {e}"
        print(f"❌ {error_msg}")
        current_app.logger.error(error_msg)

def notify_stats_update(players=None, servers=None, bandwidth=None):
    """Notificar actualización de estadísticas en tiempo real"""
    try:
        stats_data = {}
        
        if players is not None:
            stats_data['players'] = players
        if servers is not None:
            stats_data['servers'] = servers
        if bandwidth is not None:
            stats_data['bandwidth'] = bandwidth
            
        stats_data['updated_at'] = datetime.utcnow().isoformat()
        
        emit_to_public('stats_update', stats_data)
        
    except Exception as e:
        current_app.logger.error(f"Error notificando actualización de estadísticas: {e}")

def test_public_socketio():
    """Función de prueba para SocketIO público"""
    test_data = {
        'test': True,
        'message': 'Prueba de SocketIO público desde servidor',
        'timestamp': datetime.utcnow().isoformat()
    }
    
    emit_to_public('test_event', test_data)
    current_app.logger.info("Evento de prueba enviado a namespace público")

# ==================== CLASE PARA MANEJAR EVENTOS PÚBLICOS (CORREGIDA) ====================

class PublicSocketIOEventHandler:
    """Manejador de eventos SocketIO para el namespace público"""
    
    @staticmethod
    def handle_banner_connect(session_id):
        """Manejar conexión de banner"""
        try:
            current_app.logger.info(f"Banner conectado: {session_id}")
            print(f"📱 PublicSocketIOEventHandler: Banner conectado {session_id}")
            
            # Enviar datos iniciales al banner recién conectado
            broadcast_initial_data_to_banner(session_id)
            
        except Exception as e:
            current_app.logger.error(f"Error manejando conexión de banner: {e}")
            print(f"❌ Error en handle_banner_connect: {e}")
    
    @staticmethod
    def handle_banner_disconnect(session_id):
        """Manejar desconexión de banner"""
        try:
            current_app.logger.info(f"Banner desconectado: {session_id}")
            print(f"📱 PublicSocketIOEventHandler: Banner desconectado {session_id}")
            
        except Exception as e:
            current_app.logger.error(f"Error manejando desconexión de banner: {e}")
            print(f"❌ Error en handle_banner_disconnect: {e}")
    
    @staticmethod
    def handle_request_initial_data(session_id):
        """Manejar solicitud de datos iniciales"""
        try:
            current_app.logger.info(f"Solicitud de datos iniciales de: {session_id}")
            print(f"📱 PublicSocketIOEventHandler: Solicitud de datos de {session_id}")
            broadcast_initial_data_to_banner(session_id)
            
        except Exception as e:
            current_app.logger.error(f"Error manejando solicitud de datos iniciales: {e}")
            print(f"❌ Error en handle_request_initial_data: {e}")

    @staticmethod
    def handle_launcher_heartbeat(session_id, data=None):
        """Manejar heartbeat del launcher"""
        try:
            print(f"💓 PublicSocketIOEventHandler: Heartbeat de {session_id}")
            
            # Si solicita estadísticas, enviarlas
            if data and data.get('request_stats'):
                stats_data = {
                    'players': 500,
                    'servers': '3/3',
                    'status': 'online',
                    'timestamp': datetime.utcnow().isoformat()
                }
                
                socketio = get_socketio()
                if socketio:
                    socketio.emit('stats_update', stats_data, room=session_id, namespace='/public')
                    print(f"📊 Estadísticas enviadas a {session_id}")
            
        except Exception as e:
            current_app.logger.error(f"Error manejando heartbeat: {e}")
            print(f"❌ Error en handle_launcher_heartbeat: {e}")

    @staticmethod
    def handle_test_connection(session_id):
        """Manejar test de conexión"""
        try:
            print(f"🧪 PublicSocketIOEventHandler: Test de conexión de {session_id}")
            
            test_response = {
                'status': 'ok',
                'message': 'Conexión establecida correctamente',
                'server_time': datetime.utcnow().isoformat(),
                'session_id': session_id
            }
            
            socketio = get_socketio()
            if socketio:
                socketio.emit('test_response', test_response, room=session_id, namespace='/public')
                print(f"✅ Respuesta de test enviada a {session_id}")
                
        except Exception as e:
            current_app.logger.error(f"Error manejando test de conexión: {e}")
            print(f"❌ Error en handle_test_connection: {e}")

# ==================== FUNCIONES DE INTEGRACIÓN ====================

def integrate_with_admin_events():
    """Integrar eventos públicos con eventos de admin existentes"""
    
    def on_version_created(version, is_latest=False):
        """Cuando se crea una nueva versión"""
        if is_latest:
            notify_new_game_version_available(version, is_latest)
    
    def on_launcher_uploaded(version, filename, is_current=False):
        """Cuando se sube una nueva versión del launcher"""
        if is_current:
            notify_launcher_update_available(version, filename, is_current)
    
    def on_message_created(messages):
        """Cuando se crean/actualizan mensajes"""
        notify_news_updated(messages)
    
    def on_maintenance_toggled(enabled, message):
        """Cuando cambia el modo mantenimiento"""
        notify_maintenance_mode_changed(enabled, message)
    
    # Estas funciones pueden ser llamadas desde admin_routes.py
    return {
        'version_created': on_version_created,
        'launcher_uploaded': on_launcher_uploaded,
        'message_created': on_message_created,
        'maintenance_toggled': on_maintenance_toggled
    }

# ==================== FUNCIONES DE TESTING ====================

def test_all_public_events():
    """Función para probar todos los eventos públicos"""
    try:
        print("🧪 Iniciando tests de eventos públicos...")
        
        # Test 1: Broadcast inicial
        print("Test 1: Broadcast inicial")
        broadcast_initial_data_to_banner()
        
        # Test 2: Actualización de estadísticas
        print("Test 2: Actualización de estadísticas")
        notify_stats_update(players=750, servers='4/4')
        
        # Test 3: Evento de prueba
        print("Test 3: Evento de prueba")
        test_public_socketio()
        
        print("✅ Todos los tests de eventos públicos completados")
        
    except Exception as e:
        print(f"❌ Error en tests de eventos públicos: {e}")

# ==================== INICIALIZACIÓN ====================

def initialize_public_socketio():
    """Inicializar sistema de SocketIO público"""
    try:
        print("🔌 Inicializando sistema SocketIO público...")
        
        # Verificar que SocketIO esté disponible
        socketio = get_socketio()
        if socketio:
            print("✅ SocketIO disponible para eventos públicos")
            
            # Registrar manejadores de eventos si es necesario
            # (esto se hace en app.py)
            
            print("✅ Sistema SocketIO público inicializado correctamente")
            return True
        else:
            print("❌ SocketIO no disponible")
            return False
            
    except Exception as e:
        print(f"❌ Error inicializando SocketIO público: {e}")
        return False

# ==================== MENSAJE DE ESTADO ====================

print("✅ public_socketio_utils.py cargado correctamente con PublicSocketIOEventHandler")

# ==================== FUNCIONES AUXILIARES PARA TESTING ====================

def debug_socketio_state():
    """Obtener información de debug sobre el estado de SocketIO"""
    try:
        socketio = get_socketio()
        
        debug_info = {
            'socketio_available': socketio is not None,
            'socketio_type': str(type(socketio)) if socketio else None,
            'current_time': datetime.utcnow().isoformat(),
            'flask_app_context': False,
            'total_connected_clients': 0
        }
        
        # Verificar contexto de Flask
        try:
            from flask import has_app_context
            debug_info['flask_app_context'] = has_app_context()
        except:
            debug_info['flask_app_context'] = 'unknown'
        
        # Intentar obtener información de SocketIO
        if socketio:
            try:
                # Obtener número de clientes conectados en namespace público
                manager = getattr(socketio, 'server', None)
                if manager:
                    namespace_info = getattr(manager, 'manager', None)
                    if namespace_info:
                        rooms = getattr(namespace_info, 'rooms', {})
                        debug_info['total_connected_clients'] = len(rooms.get('/public', {}))
                
                debug_info['socketio_server_available'] = True
            except Exception as e:
                debug_info['socketio_error'] = str(e)
                debug_info['socketio_server_available'] = False
        
        print(f"🔍 SocketIO Debug Info: {debug_info}")
        return debug_info
        
    except Exception as e:
        error_info = {
            'error': str(e),
            'socketio_available': False,
            'timestamp': datetime.utcnow().isoformat()
        }
        print(f"❌ Error en debug_socketio_state: {e}")
        return error_info

def safe_execute_with_context(func, *args, **kwargs):
    """
    Ejecutar función de SocketIO de forma segura con manejo de contexto
    
    Args:
        func: Función a ejecutar
        *args: Argumentos posicionales
        **kwargs: Argumentos con nombre
        
    Returns:
        bool: True si se ejecutó exitosamente, False si hubo error
    """
    try:
        # Verificar que la función sea callable
        if not callable(func):
            print(f"❌ safe_execute_with_context: {func} no es una función")
            return False
        
        # Verificar que SocketIO esté disponible
        socketio = get_socketio()
        if not socketio:
            print(f"⚠️ safe_execute_with_context: SocketIO no disponible para {func.__name__}")
            return False
        
        # Ejecutar la función con manejo de errores
        print(f"🔧 safe_execute_with_context: Ejecutando {func.__name__} con args: {args}")
        
        # Verificar contexto de Flask
        try:
            from flask import has_app_context
            if not has_app_context():
                print(f"⚠️ safe_execute_with_context: Sin contexto de Flask para {func.__name__}")
                # Intentar ejecutar de todos modos
        except ImportError:
            pass
        
        # Llamar a la función
        result = func(*args, **kwargs)
        print(f"✅ safe_execute_with_context: {func.__name__} ejecutado exitosamente")
        return True
        
    except Exception as e:
        print(f"❌ safe_execute_with_context: Error ejecutando {func.__name__}: {e}")
        current_app.logger.error(f"Error en safe_execute_with_context para {func.__name__}: {e}")
        return False

def emit_to_public_safe(event, data, room=None):
    """
    Versión segura de emit_to_public con más logging
    """
    try:
        print(f"📡 emit_to_public_safe: {event} -> {type(data)} (room: {room})")
        
        socketio = get_socketio()
        if not socketio:
            print("❌ emit_to_public_safe: SocketIO no disponible")
            return False
        
        # Agregar timestamp si los datos son un diccionario
        if isinstance(data, dict) and 'timestamp' not in data:
            data['timestamp'] = datetime.utcnow().isoformat()
        
        # Emitir evento
        if room:
            socketio.emit(event, data, room=room, namespace='/public')
            print(f"✅ emit_to_public_safe: Evento '{event}' emitido a room {room}")
        else:
            socketio.emit(event, data, namespace='/public')
            print(f"✅ emit_to_public_safe: Evento '{event}' emitido a /public")
        
        return True
        
    except Exception as e:
        print(f"❌ emit_to_public_safe: Error emitiendo {event}: {e}")
        current_app.logger.error(f"Error en emit_to_public_safe: {e}")
        return False

def test_all_public_socketio_functions():
    """Probar todas las funciones de SocketIO público"""
    try:
        print("🧪 INICIANDO TESTS COMPLETOS DE SOCKETIO PÚBLICO...")
        
        results = {}
        
        # Test 1: Debug state
        print("🧪 Test 1: Debug state")
        results['debug_state'] = debug_socketio_state()
        
        # Test 2: Conexión básica
        print("🧪 Test 2: Test básico")
        results['basic_test'] = safe_execute_with_context(test_public_socketio)
        
        # Test 3: Broadcast inicial
        print("🧪 Test 3: Broadcast inicial")
        results['initial_broadcast'] = safe_execute_with_context(broadcast_initial_data_to_banner)
        
        # Test 4: Noticias fake
        print("🧪 Test 4: Noticias fake")
        fake_news = [
            type('obj', (object,), {
                'id': 9999,
                'type': 'Test Completo',
                'message': f'Test completo de SocketIO - {datetime.now().strftime("%H:%M:%S")}',
                'priority': 9,
                'is_active': True,
                'created_at': datetime.now()
            })
        ]
        results['news_test'] = safe_execute_with_context(notify_news_updated, fake_news)
        
        # Test 5: Estado del sistema
        print("🧪 Test 5: Estado del sistema")
        test_status = {
            'status': 'online',
            'maintenance_mode': False,
            'latest_game_version': f'TEST.{datetime.now().strftime("%H%M%S")}',
            'current_launcher_version': f'LAUNCHER.{datetime.now().strftime("%H%M%S")}'
        }
        results['system_status_test'] = safe_execute_with_context(notify_system_status_changed, test_status)
        
        print(f"✅ TESTS COMPLETOS FINALIZADOS: {results}")
        return results
        
    except Exception as e:
        print(f"❌ Error en test completo: {e}")
        return {'error': str(e)}

# ==================== MENSAJE DE ESTADO ====================

print("✅ public_socketio_utils.py cargado correctamente con PublicSocketIOEventHandler")
print("🔧 Funciones auxiliares agregadas: debug_socketio_state, safe_execute_with_context")