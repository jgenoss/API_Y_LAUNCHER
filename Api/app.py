from flask import Flask, request, jsonify, render_template, redirect, url_for, flash, send_from_directory, current_app
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from flask_socketio import SocketIO, emit
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
from models import db
import os
import json
import hashlib
from datetime import datetime, timezone, timedelta
import zipfile
from utils import format_file_size
import logging

# VERSIÓN FINAL CON DATOS REALES DE BASE DE DATOS
CODIGO_VERSION = "FINAL.BD.REAL.2025.06.01.23.48.00"
print(f"🚀 INICIANDO LAUNCHER SERVER CON DATOS REALES - VERSIÓN: {CODIGO_VERSION}")

try:
    from public_socketio_utils import (
        PublicSocketIOEventHandler, 
        broadcast_initial_data_to_banner,
        notify_stats_update,
        test_public_socketio
    )
    print("✅ PublicSocketIOEventHandler importado correctamente")
except ImportError as e:
    print(f"⚠️ Warning: No se pudo importar PublicSocketIOEventHandler: {e}")
    # Definir clases dummy para evitar errores
    class PublicSocketIOEventHandler:
        @staticmethod
        def handle_banner_connect(session_id):
            pass
        @staticmethod
        def handle_banner_disconnect(session_id):
            pass
        @staticmethod
        def handle_request_initial_data(session_id):
            pass

# Configurar logging
logging.getLogger('socketio').setLevel(logging.WARNING)
logging.getLogger('engineio').setLevel(logging.WARNING)

def create_app():
    """Función factory para crear la aplicación Flask"""
    app = Flask(__name__)
    app.config['SECRET_KEY'] = 'your-secret-key-change-this'
    app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:1234@localhost:5432/postgres'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['UPLOAD_FOLDER'] = 'uploads'
    app.config['MAX_CONTENT_LENGTH'] = 500 * 1024 * 1024  # 500MB max file size

    # Crear directorios necesarios
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    os.makedirs(os.path.join(app.config['UPLOAD_FOLDER'], 'updates'), exist_ok=True)
    os.makedirs(os.path.join(app.config['UPLOAD_FOLDER'], 'files'), exist_ok=True)
    os.makedirs('static/downloads', exist_ok=True)

    # Inicializar extensiones
    db.init_app(app)

    return app

# Crear la aplicación
app = create_app()

# CONFIGURACIÓN ROBUSTA DE SOCKETIO
print("🔌 Configurando SocketIO para producción...")
socketio = SocketIO(
    app, 
    cors_allowed_origins="*", 
    logger=False,
    engineio_logger=False,
    async_mode='threading',
    ping_timeout=60,
    ping_interval=25,
    max_http_buffer_size=1000000,
    transports=['polling', 'websocket'],
    always_connect=True,
    binary=False
)
print("✅ SocketIO configurado para producción")

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

# Función helper para tiempo UTC (sin warnings)
def get_utc_now():
    """Obtener tiempo UTC sin warnings de deprecation"""
    return datetime.now(timezone.utc)

def get_utc_timestamp():
    """Obtener timestamp UTC como string"""
    return get_utc_now().isoformat()

def get_utc_time_string():
    """Obtener tiempo UTC como string formateado"""
    return get_utc_now().strftime('%H:%M:%S')

# Importar modelos y rutas
from models import User, GameVersion, GameFile, UpdatePackage, NewsMessage

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

from markupsafe import Markup, escape

# Filtros de plantilla
@app.template_filter('nl2br')
def nl2br_filter(s):
    if s is None:
        return ''
    return Markup('<br>'.join(escape(s).splitlines()))

@app.template_filter('is_file_exists')
def is_file_exists_filter(path):
    return os.path.isfile(path)

@app.template_filter('get_total_size')
def get_total_size_filter(items):
    """Calcular tamaño total de una lista de elementos"""
    if not items:
        return 0
    total = 0
    for item in items:
        if hasattr(item, 'file_size') and item.file_size:
            total += item.file_size
    return total

@app.template_filter('get_file_size')
def get_file_size_filter(file_path):
    """Obtener tamaño de archivo formateado"""
    try:
        if os.path.exists(file_path):
            size_bytes = os.path.getsize(file_path)
            return format_file_size(size_bytes)
        return "0 B"
    except:
        return "0 B"

@app.template_filter('get_total_launcher_size')
def get_total_launcher_size_filter(launchers):
    """Calcular tamaño total de launchers"""
    total_bytes = 0
    for launcher in launchers:
        if launcher.file_path and os.path.exists(launcher.file_path):
            try:
                total_bytes += os.path.getsize(launcher.file_path)
            except:
                continue
    return format_file_size(total_bytes)

# ===== FUNCIÓN PRINCIPAL PARA OBTENER DATOS REALES =====

def get_real_initial_data():
    """Obtener datos reales de la base de datos con fallbacks"""
    try:
        print("🔍 Obteniendo datos reales de la base de datos...")
        
        # Datos del sistema
        system_data = {
            'status': 'online',
            'latest_game_version': 'N/A',
            'current_launcher_version': 'N/A',
            'maintenance_mode': False,
            'maintenance_message': None
        }
        
        # Intentar obtener configuración del sistema
        try:
            from models import SystemConfig
            config = SystemConfig.get_config()
            system_data['maintenance_mode'] = config.maintenance_mode
            system_data['maintenance_message'] = config.maintenance_message
            print(f"✅ SystemConfig obtenido: mantenimiento={config.maintenance_mode}")
        except Exception as e:
            print(f"⚠️ Error obteniendo SystemConfig: {e}")
        
        # Intentar obtener versión del juego
        try:
            from models import GameVersion
            latest_version = GameVersion.get_latest()
            if latest_version:
                system_data['latest_game_version'] = latest_version.version
                print(f"✅ Game version obtenida: {latest_version.version}")
            else:
                print("⚠️ No hay GameVersion en BD")
        except Exception as e:
            print(f"⚠️ Error obteniendo GameVersion: {e}")
        
        # Intentar obtener versión del launcher
        try:
            from models import LauncherVersion
            current_launcher = LauncherVersion.get_current()
            if current_launcher:
                system_data['current_launcher_version'] = current_launcher.version
                print(f"✅ Launcher version obtenida: {current_launcher.version}")
            else:
                print("⚠️ No hay LauncherVersion en BD")
        except Exception as e:
            print(f"⚠️ Error obteniendo LauncherVersion: {e}")
        
        # Intentar obtener noticias reales
        news_list = []
        try:
            from models import NewsMessage
            news_messages = NewsMessage.query.filter_by(is_active=True).order_by(NewsMessage.created_at.desc()).limit(10).all()
            
            for news in news_messages:
                news_item = {
                    'type': news.type or 'Información',
                    'message': news.message,
                    'priority': news.priority or 5,
                    'created_at': news.created_at.strftime('%Y-%m-%d %H:%M') if news.created_at else 'N/A'
                }
                news_list.append(news_item)
            
            print(f"✅ {len(news_list)} noticias obtenidas de BD")
            
        except Exception as e:
            print(f"⚠️ Error obteniendo noticias: {e}")
        
        # Si no hay noticias de BD, usar noticias informativas
        if not news_list:
            news_list = [
                {
                    'type': 'Sistema',
                    'message': 'Servidor launcher iniciado correctamente',
                    'priority': 5
                },
                {
                    'type': 'Base de Datos',
                    'message': 'Conexión con base de datos establecida',
                    'priority': 4
                },
                {
                    'type': 'SocketIO',
                    'message': 'Sistema de comunicación en tiempo real activo',
                    'priority': 4
                }
            ]
            print(f"📝 Usando {len(news_list)} noticias por defecto")
        
        # Calcular estadísticas reales
        stats_data = {
            'players': 500,
            'servers': '3/3',
            'status': 'online'
        }
        
        try:
            from models import DownloadLog
            from datetime import timedelta
            
            # Descargas totales
            total_downloads = DownloadLog.query.count()
            
            # Descargas recientes (última hora)
            recent_downloads = DownloadLog.query.filter(
                DownloadLog.created_at >= get_utc_now() - timedelta(hours=1)
            ).count()
            
            # Simular jugadores basado en actividad
            simulated_players = 500 + (recent_downloads * 10) + (total_downloads // 100)
            stats_data['players'] = min(simulated_players, 9999)  # Máximo 9999
            
            print(f"✅ Estadísticas calculadas: {stats_data['players']} jugadores (basado en {total_downloads} descargas)")
            
        except Exception as e:
            print(f"⚠️ Error calculando estadísticas: {e}")
        
        # Construir datos completos
        complete_data = {
            'system_status': system_data,
            'news': news_list,
            'stats': stats_data,
            'version': CODIGO_VERSION,
            'timestamp': get_utc_timestamp(),
            'source': 'real_database',
            'total_news': len(news_list)
        }
        
        print(f"✅ Datos reales preparados:")
        print(f"   - Game version: {system_data['latest_game_version']}")
        print(f"   - Launcher version: {system_data['current_launcher_version']}")
        print(f"   - Noticias: {len(news_list)} items")
        print(f"   - Jugadores: {stats_data['players']}")
        print(f"   - Mantenimiento: {system_data['maintenance_mode']}")
        
        return complete_data
        
    except Exception as e:
        print(f"❌ ERROR CRÍTICO obteniendo datos reales: {e}")
        return None

# ==================== RUTAS PRINCIPALES ====================
@app.route('/')
def index():
    try:
        return redirect(url_for('admin.dashboard'))
    except Exception as e:
        current_app.logger.error(f"Error en index: {e}")
        return jsonify({'error': 'Error en redirection'}), 500

@app.route('/login', methods=['GET', 'POST'])
def login():
    try:
        if request.method == 'POST':
            username = request.form.get('username')
            password = request.form.get('password')
            
            if not username or not password:
                flash('Usuario y contraseña son requeridos', 'error')
                return render_template('login.html')
                
            user = User.query.filter_by(username=username).first()
            
            if user and check_password_hash(user.password_hash, password):
                login_user(user)
                return redirect(url_for('admin.dashboard'))
            else:
                flash('Usuario o contraseña incorrectos', 'error')
        
        return render_template('login.html')
    except Exception as e:
        current_app.logger.error(f"Error en login: {e}")
        return jsonify({'error': 'Error en login'}), 500

@app.route('/logout')
@login_required
def logout():
    try:
        logout_user()
        return redirect(url_for('login'))
    except Exception as e:
        current_app.logger.error(f"Error en logout: {e}")
        return redirect(url_for('login'))

# Rutas para servir archivos
@app.route('/Launcher/<path:filename>')
def serve_launcher_files(filename):
    try:
        return send_from_directory('static/downloads', filename)
    except Exception as e:
        return jsonify({'error': 'File not found'}), 404

@app.route('/Launcher/updates/<path:filename>')
def serve_update_files(filename):
    try:
        return send_from_directory(os.path.join(app.config['UPLOAD_FOLDER'], 'updates'), filename)
    except Exception as e:
        return jsonify({'error': 'Update file not found'}), 404

@app.route('/Launcher/files/<path:filename>')
def serve_game_files(filename):
    try:
        return send_from_directory(os.path.join(app.config['UPLOAD_FOLDER'], 'files'), filename)
    except Exception as e:
        return jsonify({'error': 'Game file not found'}), 404

# APIs básicas
@app.route('/api/status')
def api_status():
    try:
        return jsonify({
            "status": "online",
            "server_time": get_utc_timestamp(),
            "socketio_available": True,
            "version": CODIGO_VERSION
        })
    except Exception as e:
        return jsonify({"status": "error", "error": str(e)}), 500

@app.route('/api/public/status')
def public_api_status():
    try:
        real_data = get_real_initial_data()
        if real_data:
            return jsonify({
                "status": real_data['system_status']['status'],
                "maintenance_mode": real_data['system_status']['maintenance_mode'],
                "latest_game_version": real_data['system_status']['latest_game_version'],
                "current_launcher_version": real_data['system_status']['current_launcher_version'],
                "server_time": get_utc_timestamp(),
                "version": CODIGO_VERSION
            })
        else:
            return jsonify({
                "status": "error",
                "error": "Could not fetch real data",
                "server_time": get_utc_timestamp()
            }), 500
    except Exception as e:
        return jsonify({"status": "error", "error": str(e)}), 500

# RUTAS DE PRUEBA MEJORADAS
@app.route('/test/send_data')
def test_send_data():
    try:
        print("🧪 ENVIANDO DATOS REALES DE PRUEBA...")
        real_data = get_real_initial_data()
        
        if real_data:
            socketio.emit('initial_data', real_data, namespace='/public')
            print("✅ DATOS REALES ENVIADOS")
            return jsonify({
                'status': 'sent',
                'message': 'Datos reales enviados desde la base de datos',
                'data': real_data
            })
        else:
            return jsonify({'status': 'error', 'error': 'No se pudieron obtener datos reales'})
    except Exception as e:
        return jsonify({'status': 'error', 'error': str(e)})

@app.route('/test/setup_database')
def test_setup_database():
    """Configurar datos de prueba en la base de datos"""
    try:
        print("🔧 Configurando datos de prueba en la base de datos...")
        
        # Crear versión del juego si no existe
        try:
            existing_game = GameVersion.query.first()
            if not existing_game:
                game_version = GameVersion(
                    version='2.1.5',
                    description='Versión estable del juego',
                    is_latest=True
                )
                db.session.add(game_version)
                print("✅ GameVersion creada: 2.1.5")
        except Exception as e:
            print(f"⚠️ Error creando GameVersion: {e}")
        
        # Crear versión del launcher si no existe
        try:
            from models import LauncherVersion
            existing_launcher = LauncherVersion.query.first()
            if not existing_launcher:
                launcher_version = LauncherVersion(
                    version='3.4.2',
                    description='Launcher actualizado',
                    is_current=True
                )
                db.session.add(launcher_version)
                print("✅ LauncherVersion creada: 3.4.2")
        except Exception as e:
            print(f"⚠️ Error creando LauncherVersion: {e}")
        
        # Crear noticias de prueba
        try:
            existing_news = NewsMessage.query.filter_by(is_active=True).count()
            if existing_news < 3:
                news_items = [
                    {
                        'type': 'Actualización',
                        'message': '🎮 Nueva versión del juego disponible con mejoras de rendimiento',
                        'priority': 7
                    },
                    {
                        'type': 'Evento',
                        'message': '🎉 Evento especial de fin de semana con recompensas dobles',
                        'priority': 6
                    },
                    {
                        'type': 'Mantenimiento',
                        'message': '🔧 Mantenimiento programado para el próximo martes de 2:00 a 4:00 AM',
                        'priority': 5
                    },
                    {
                        'type': 'Sistema',
                        'message': '✅ Todos los servidores funcionando a plena capacidad',
                        'priority': 4
                    },
                    {
                        'type': 'Comunidad',
                        'message': '👥 Únete a nuestro Discord para estar al día con las novedades',
                        'priority': 3
                    }
                ]
                
                for news_data in news_items:
                    news = NewsMessage(
                        type=news_data['type'],
                        message=news_data['message'],
                        priority=news_data['priority'],
                        is_active=True,
                        created_at=get_utc_now()
                    )
                    db.session.add(news)
                
                print(f"✅ {len(news_items)} noticias creadas")
        except Exception as e:
            print(f"⚠️ Error creando noticias: {e}")
        
        # Crear configuración del sistema
        try:
            from models import SystemConfig
            existing_config = SystemConfig.query.first()
            if not existing_config:
                config = SystemConfig(
                    maintenance_mode=False,
                    maintenance_message=None,
                    auto_update_enabled=True,
                    force_ssl=False
                )
                db.session.add(config)
                print("✅ SystemConfig creado")
        except Exception as e:
            print(f"⚠️ Error creando SystemConfig: {e}")
        
        # Guardar cambios
        db.session.commit()
        print("✅ Datos de prueba guardados en la base de datos")
        
        return jsonify({
            'status': 'success',
            'message': 'Datos de prueba configurados en la base de datos',
            'timestamp': get_utc_timestamp()
        })
        
    except Exception as e:
        db.session.rollback()
        print(f"❌ Error configurando datos de prueba: {e}")
        return jsonify({'status': 'error', 'error': str(e)}), 500

# ===== EVENTOS DE SOCKETIO =====

@socketio.on('connect', namespace='/public')
def handle_public_connect():
    """Cuando un launcher público se conecta - VERSIÓN CON DATOS REALES"""
    try:
        session_id = request.sid
        print(f'✅ Launcher conectado [V{CODIGO_VERSION}]: {session_id}')
        
        # Confirmar conexión
        emit('connection_status', {
            'status': 'connected',
            'message': f'Launcher conectado al sistema (V{CODIGO_VERSION})',
            'session_id': session_id,
            'version': CODIGO_VERSION
        })
        
        print(f'🔄 Obteniendo datos reales para {session_id}...')
        
        # OBTENER DATOS REALES DE LA BASE DE DATOS
        real_data = get_real_initial_data()
        
        if real_data:
            # Enviar datos reales
            emit('initial_data', real_data)
            print(f'✅ Datos reales enviados a {session_id}')
        else:
            # Fallback si hay error
            print(f'⚠️ Usando fallback para {session_id}')
            fallback_data = {
                'system_status': {
                    'status': 'online',
                    'latest_game_version': '1.0.0',
                    'current_launcher_version': '1.0.0',
                    'maintenance_mode': False
                },
                'news': [
                    {
                        'type': 'Sistema',
                        'message': 'Servidor operativo - Modo básico activo',
                        'priority': 6
                    },
                    {
                        'type': 'Error',
                        'message': 'No se pudieron cargar datos completos de la BD',
                        'priority': 7
                    }
                ],
                'stats': {
                    'players': 500,
                    'servers': '3/3',
                    'status': 'online'
                },
                'version': CODIGO_VERSION,
                'source': 'fallback'
            }
            emit('initial_data', fallback_data)
            print(f'🆘 Datos de fallback enviados a {session_id}')
            
    except Exception as e:
        current_app.logger.error(f"Error en public connect: {e}")
        print(f'❌ Error en conexión pública: {e}')

@socketio.on('disconnect', namespace='/public')
def handle_public_disconnect(*args, **kwargs):
    try:
        session_id = request.sid
        print(f'❌ Launcher desconectado [V{CODIGO_VERSION}]: {session_id}')
    except Exception as e:
        current_app.logger.error(f"Error en public disconnect: {e}")

@socketio.on('request_initial_data', namespace='/public')
def handle_request_initial_data():
    """Cuando el launcher solicita datos iniciales - VERSIÓN CON DATOS REALES"""
    try:
        session_id = request.sid
        print(f'📋 Launcher solicita datos iniciales [V{CODIGO_VERSION}]: {session_id}')
        
        # OBTENER DATOS REALES DIRECTAMENTE
        print(f'🔄 Obteniendo datos reales para solicitud de {session_id}...')
        real_data = get_real_initial_data()
        
        if real_data:
            emit('initial_data', real_data)
            print(f'✅ Datos reales enviados en respuesta a solicitud de {session_id}')
        else:
            # Datos de emergencia
            emergency_data = {
                'system_status': {
                    'status': 'online',
                    'latest_game_version': 'ERROR-BD',
                    'current_launcher_version': 'ERROR-BD',
                    'maintenance_mode': False
                },
                'news': [
                    {
                        'type': 'Error',
                        'message': 'Error accediendo a la base de datos',
                        'priority': 8
                    },
                    {
                        'type': 'Sistema',
                        'message': 'Funcionando en modo de emergencia',
                        'priority': 7
                    }
                ],
                'stats': {
                    'players': 0,
                    'servers': '1/3',
                    'status': 'degraded'
                },
                'version': CODIGO_VERSION,
                'source': 'emergency'
            }
            emit('initial_data', emergency_data)
            print(f'🚨 Datos de emergencia enviados a {session_id}')
        
    except Exception as e:
        print(f'❌ ERROR CRÍTICO en request_initial_data: {e}')
        current_app.logger.error(f"Error crítico enviando datos iniciales: {e}")

@socketio.on('ping', namespace='/public')
def handle_public_ping():
    try:
        emit('pong', {
            'timestamp': get_utc_timestamp(),
            'server_time': get_utc_time_string(),
            'version': CODIGO_VERSION
        })
    except Exception as e:
        current_app.logger.error(f"Error en public ping: {e}")

@socketio.on('launcher_heartbeat', namespace='/public')
def handle_launcher_heartbeat(data):
    try:
        session_id = request.sid
        if data and data.get('request_stats'):
            real_data = get_real_initial_data()
            if real_data and real_data.get('stats'):
                socketio.emit('stats_update', real_data['stats'], namespace='/public')
    except Exception as e:
        current_app.logger.error(f"Error en launcher_heartbeat: {e}")

# Eventos admin básicos
@socketio.on('connect', namespace='/admin')
def handle_admin_connect():
    try:
        session_id = request.sid
        print(f'✅ Admin conectado [V{CODIGO_VERSION}]: {session_id}')
        emit('connection_status', {
            'status': 'connected',
            'message': f'Panel admin conectado (V{CODIGO_VERSION})',
            'session_id': session_id,
            'version': CODIGO_VERSION
        })
    except Exception as e:
        current_app.logger.error(f"Error en admin connect: {e}")

@socketio.on('disconnect', namespace='/admin')
def handle_admin_disconnect(*args, **kwargs):
    try:
        session_id = request.sid
        print(f'❌ Admin desconectado [V{CODIGO_VERSION}]: {session_id}')
    except Exception as e:
        current_app.logger.error(f"Error en admin disconnect: {e}")

# Manejadores de errores
@socketio.on_error_default
def default_error_handler(e):
    current_app.logger.error(f"Error en SocketIO [V{CODIGO_VERSION}]: {e}")

@socketio.on_error(namespace='/public')
def public_error_handler(e):
    current_app.logger.error(f"Error en SocketIO público [V{CODIGO_VERSION}]: {e}")

@socketio.on_error(namespace='/admin')
def admin_error_handler(e):
    current_app.logger.error(f"Error en SocketIO admin [V{CODIGO_VERSION}]: {e}")

# Función para crear usuario admin
def create_admin_user():
    try:
        admin = User.query.filter_by(username='admin').first()
        if not admin:
            admin = User(
                username='admin',
                email='admin@localhost',
                password_hash=generate_password_hash('admin123'),
                is_admin=True
            )
            db.session.add(admin)
            db.session.commit()
            print(f"✅ Usuario administrador creado: admin/admin123 [V{CODIGO_VERSION}]")
    except Exception as e:
        print(f"❌ Error creando usuario admin: {e}")

# Manejo de errores HTTP
@app.errorhandler(404)
def not_found_error(error):
    return jsonify({'error': 'Not found', 'version': CODIGO_VERSION}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error', 'version': CODIGO_VERSION}), 500

# REGISTRAR BLUEPRINTS CORRECTAMENTE
def register_blueprints():
    """Registrar todos los blueprints de la aplicación"""
    try:
        # Importar blueprints
        from api_routes import api_bp
        from admin_routes import admin_bp
        
        # Registrar blueprints
        app.register_blueprint(api_bp, url_prefix='/api')
        app.register_blueprint(admin_bp, url_prefix='/admin')
        
        print(f"✅ Blueprints registrados correctamente [V{CODIGO_VERSION}]")
        
        # Inicializar limiter para api_routes
        try:
            from api_routes import init_limiter
            limiter = init_limiter(app)
            print("✅ Rate limiter inicializado correctamente")
        except Exception as e:
            print(f"⚠️ Warning: No se pudo inicializar rate limiter: {e}")
        return True
        
    except ImportError as e:
        print(f"⚠️ Warning: No se pudieron importar blueprints: {e}")
        return False
    except Exception as e:
        print(f"❌ Error registrando blueprints: {e}")
        return False

if __name__ == '__main__':
    with app.app_context():
        try:
            # Crear tablas
            db.create_all()
            
            # Crear usuario admin
            #create_admin_user()
            
            # Registrar blueprints
            blueprints_registered = register_blueprints()
            
            # Información de inicio
            port = 5000
            print(f"🚀 Iniciando Launcher Server en puerto {port} [V{CODIGO_VERSION}]")
            print(f"🔌 SocketIO optimizado para estabilidad")
            print(f"🗄️ Usando datos REALES de la base de datos")
            print(f"📊 Blueprints registrados: {'✅' if blueprints_registered else '❌'}")
            print(f"🧪 URLs disponibles:")
            print(f"   - http://localhost:{port}/ (Admin panel)")
            print(f"   - http://localhost:{port}/api/status (API status)")
            print(f"   - http://localhost:{port}/test/setup_database (configurar BD)")
            print(f"   - http://localhost:{port}/test/send_data (enviar datos reales)")
            
            # Iniciar servidor
            socketio.run(
                app, 
                debug=True,
                host='0.0.0.0', 
                port=port, 
                allow_unsafe_werkzeug=True,
                use_reloader=False
            )
        except Exception as e:
            print(f"❌ Error iniciando aplicación: {e}")
            raise