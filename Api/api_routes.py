import time
from flask import Blueprint, jsonify, render_template, request, send_from_directory, current_app, abort
from models import GameVersion, GameFile, UpdatePackage, LauncherVersion, NewsMessage, DownloadLog, launcher_ban, SystemConfig, SystemStatus, Account, LoginAttempt, db,BannerConfig, BannerSlide
import os
import json
from datetime import datetime
from pprint import pprint 
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import re

# Variable global para el limiter
limiter = None

def init_limiter(app):
    """Inicializar limiter de forma segura"""
    global limiter
    if limiter is None:
        try:
            limiter = Limiter(
                key_func=get_remote_address,
                app=app,
                default_limits=["1000 per day", "1000 per hour"],
                storage_uri="memory://",
                strategy="fixed-window"
            )
            print("✅ Flask-Limiter inicializado correctamente")
        except Exception as e:
            print(f"⚠️ Error inicializando Flask-Limiter: {e}")
            limiter = None
    return limiter

# Crear blueprint
api_bp = Blueprint('api', __name__)

def check_maintenance_mode():
    """Verificar si el sistema está en modo mantenimiento"""
    try:
        config = SystemConfig.get_config()
        if config.maintenance_mode:
            return True, config.maintenance_message
        return False, None
    except Exception as e:
        current_app.logger.error(f"Error checking maintenance mode: {e}")
        return False, None

def is_ip_allowed(ip_address):
    """Verificar si la IP está en la lista blanca"""
    try:
        config = SystemConfig.get_config()
        if not config.ip_whitelist:
            return True  # Si no hay whitelist, permitir todas las IPs
        
        whitelist = json.loads(config.ip_whitelist)
        return ip_address in whitelist or '0.0.0.0/0' in whitelist
    except Exception as e:
        current_app.logger.error(f"Error checking IP whitelist: {e}")
        return True  # En caso de error, permitir acceso

def log_download(file_requested, file_type, success=True):
    """Registrar descarga en logs"""
    try:
        log = DownloadLog(
            ip_address=request.remote_addr,
            user_agent=request.headers.get('User-Agent', ''),
            file_requested=file_requested,
            file_type=file_type,
            success=success
        )
        db.session.add(log)
        db.session.commit()
        
        # Actualizar estadísticas del sistema
        update_system_stats()
        
    except Exception as e:
        current_app.logger.error(f"Error logging download: {e}")

def update_system_stats():
    """Actualizar estadísticas del sistema"""
    try:
        status = SystemStatus.get_current()
        
        # Contar requests de hoy
        today = datetime.utcnow().date()
        total_today = DownloadLog.query.filter(
            db.func.date(DownloadLog.created_at) == today
        ).count()
        
        failed_today = DownloadLog.query.filter(
            db.func.date(DownloadLog.created_at) == today,
            DownloadLog.success == False
        ).count()
        
        status.total_requests_today = total_today
        status.failed_requests_today = failed_today
        status.last_updated = datetime.utcnow()
        
        db.session.commit()
        
    except Exception as e:
        current_app.logger.error(f"Error updating system stats: {e}")

# Decorador para rate limiting que funciona con o sin limiter
def rate_limit(limit_string):
    """Decorador que aplica rate limiting si está disponible"""
    def decorator(f):
        if limiter:
            return limiter.limit(limit_string)(f)
        else:
            return f
    return decorator

# Endpoint para verificar HWID y registrar nuevos dispositivos
@api_bp.route('/check', methods=['POST'])
def check_hwid():
    """Endpoint para verificar HWID contra la lista negra y registrar nuevos dispositivos"""
    
    # Verificar modo mantenimiento
    is_maintenance, maintenance_msg = check_maintenance_mode()
    if is_maintenance:
        return jsonify({
            "status": "maintenance",
            "message": maintenance_msg,
            "is_banned": False,
            "maintenance_mode": True
        }), 503
    
    try:
        response = request.get_json()
        if not response:
            return jsonify({"error": "Invalid JSON"}), 400
            
        hwid = response.get('hwid')
        serial = response.get('serial')
        mac = response.get('mac')

        # Validación de entrada
        if not any([hwid, serial, mac]):
            return jsonify({"error": "At least one identifier (HWID, serial or MAC) is required"}), 400

        # Buscar en la base de datos usando cualquier identificador disponible
        query = db.session.query(launcher_ban)
        
        if hwid:
            query = query.filter(launcher_ban.hwid == hwid)
        if serial:
            query = query.filter(launcher_ban.serial_number == serial)
        if mac:
            query = query.filter(launcher_ban.mac_address == mac)
        
        device = query.first()

        current_app.logger.info(f"Checking device - HWID: {hwid}, Serial: {serial}, MAC: {mac}")

        # Si el dispositivo no existe, registrarlo
        if not device:
            new_device = launcher_ban(
                hwid=hwid,
                serial_number=serial,
                mac_address=mac,
                is_banned=False,
                created_at=datetime.utcnow(),
                reason="Automatically registered"
            )
            
            db.session.add(new_device)
            db.session.commit()
            current_app.logger.info(f"New device registered - HWID: {hwid}")
            
            return jsonify({
                "status": "ok",
                "message": "Device registered successfully",
                "is_banned": False,
                "new_registration": True,
                "maintenance_mode": False
            }), 200

        # Si el dispositivo existe, verificar si está baneado
        if device.is_banned:
            current_app.logger.warning(f"Banned device detected - ID: {device.id}")
            return jsonify({
                "status": "banned",
                "is_banned": True,
                "message": "This device is blacklisted",
                "ban_reason": device.reason,
                "banned_since": device.created_at.isoformat(),
                "maintenance_mode": False
            }), 200

        # Dispositivo existe pero no está baneado
        return jsonify({
            "status": "ok",
            "message": "Device is not blacklisted",
            "is_banned": False,
            "first_seen": device.created_at.isoformat(),
            "maintenance_mode": False
        }), 200

    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error in check_hwid: {str(e)}", exc_info=True)
        return jsonify({
            "error": "Internal server error",
            "details": str(e)
        }), 500

@api_bp.route('/launcher_update', methods=['GET'])
def launcher_update():
    """Endpoint para verificar actualizaciones del launcher"""
    
    # Verificar modo mantenimiento
    is_maintenance, maintenance_msg = check_maintenance_mode()
    if is_maintenance:
        return jsonify({
            "status": "maintenance",
            "message": maintenance_msg,
            "version": "1.0.0.0",
            "file_name": "PBLauncher.exe"
        }), 503
    
    try:
        current_launcher = LauncherVersion.get_current()
        
        if not current_launcher:
            return jsonify({
                "version": "1.0.0.0",
                "file_name": "PBLauncher.exe",
                "maintenance_mode": False
            }), 404
        
        log_download('launcher_update', 'launcher_check')
        
        return jsonify({
            "version": current_launcher.version,
            "file_name": current_launcher.filename,
            "maintenance_mode": False
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Error in launcher_update: {e}")
        return jsonify({"error": str(e)}), 500

@api_bp.route('/update')
def update_info():
    """Endpoint principal para información de actualizaciones del juego"""
    
    # Verificar modo mantenimiento
    is_maintenance, maintenance_msg = check_maintenance_mode()
    if is_maintenance:
        return jsonify({
            "status": "maintenance",
            "message": maintenance_msg,
            "latest_version": "1.0.0.0",
            "updates": [],
            "file_hashes": [],
            "maintenance_mode": True
        }), 503
    
    try:
        config = SystemConfig.get_config()
        latest_version = GameVersion.get_latest()
        
        if not latest_version:
            return jsonify({
                "latest_version": "1.0.0.0",
                "updates": [],
                "file_hashes": [],
                "maintenance_mode": False,
                "auto_update_enabled": config.auto_update_enabled
            }), 404

        # Obtener todos los paquetes de actualización ordenados por versión
        updates = UpdatePackage.query.join(GameVersion).order_by(GameVersion.version).all()
        update_filenames = [f"update_{pkg.version.version}.zip" for pkg in updates]

        # ✅ CAMBIO CRÍTICO: Obtener archivos de reparación independientes
        # ❌ ANTES (LÍNEA COMENTADA): 
        # file_hashes = [{"filename": f.filename, "md5": f.md5_hash, "path": f.relative_path} for f in latest_version.files]
        
        # ✅ DESPUÉS: Obtener TODOS los archivos de reparación (independientes de versión)
        repair_files = GameFile.query.all()
        file_hashes = [
            {
                "filename": f.filename, 
                "md5": f.md5_hash, 
                "path": f.relative_path,
                "size": f.file_size
            } 
            for f in repair_files
        ]

        return jsonify({
            "latest_version": latest_version.version,
            "updates": update_filenames,
            "file_hashes": file_hashes,  # ✅ Ahora incluye TODOS los archivos de reparación
            "maintenance_mode": False,
            "auto_update_enabled": config.auto_update_enabled
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Error in update_info: {e}")
        return jsonify({"error": str(e)}), 500

@api_bp.route('/file/<filename>/verify')
def verify_file(filename):
    """Verificar MD5 de un archivo específico"""
    try:
        file = GameFile.query.filter_by(filename=filename).first()
        
        if not file:
            return jsonify({"error": "Archivo no encontrado"}), 404
        
        return jsonify({
            "filename": file.filename,
            "md5": file.md5_hash,
            "path": file.relative_path,
            "size": file.file_size,
            "download_url": f"/Launcher/files/{file.filename}"
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Error verifying file {filename}: {e}")
        return jsonify({"error": str(e)}), 500

@api_bp.route('/repair_files')
def repair_files():
    """Endpoint específico para obtener archivos de reparación"""
    try:
        # Obtener todos los archivos de reparación
        files = GameFile.query.all()
        
        file_list = []
        for file in files:
            file_data = {
                "filename": file.filename,
                "md5": file.md5_hash,
                "path": file.relative_path,
                "size": file.file_size,
                "created_at": file.created_at.isoformat() if file.created_at else None,
                "updated_at": file.updated_at.isoformat() if file.updated_at else None
            }
            file_list.append(file_data)
        
        return jsonify({
            "success": True,
            "total_files": len(file_list),
            "files": file_list
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Error in repair_files: {e}")
        return jsonify({"error": str(e)}), 500

@api_bp.route('/message')
def messages():
    """Endpoint para mensajes y noticias con información del sistema"""
    try:
        config = SystemConfig.get_config()
        
        # Verificar modo mantenimiento
        is_maintenance, maintenance_msg = check_maintenance_mode()
        
        messages_data = []
        
        # Si está en mantenimiento, agregar mensaje prioritario
        if is_maintenance:
            messages_data.append({
                'id': 0,
                'type': 'Mantenimiento',
                'message': maintenance_msg,
                'priority': 100,
                'created_at': datetime.utcnow().isoformat()
            })
        
        # Obtener mensajes activos normales
        active_messages = NewsMessage.query.filter_by(is_active=True).order_by(
            NewsMessage.priority.desc(), NewsMessage.created_at.desc()
        ).all()
        
        for msg in active_messages:
            messages_data.append({
                'id': msg.id,
                'type': msg.type,
                'message': msg.message,
                'priority': msg.priority,
                'created_at': msg.created_at.isoformat() if msg.created_at else None
            })
        
        log_download('message', 'messages')
        
        return jsonify(messages_data)
        
    except Exception as e:
        current_app.logger.error(f"Error in messages endpoint: {e}")
        return jsonify({
            "error": str(e), 
            "messages": [{
                'id': 0,
                'type': 'Error',
                'message': 'No se pudieron cargar los mensajes del servidor.',
                'priority': 0,
                'created_at': datetime.utcnow().isoformat()
            }]
        }), 500

@api_bp.route('/banner/live')
def banner_live():
    """Banner en vivo - Ruta pública integrada con el sistema admin"""
    try:
        # Obtener datos iniciales para el banner
        from models import GameVersion, LauncherVersion, NewsMessage, SystemConfig, BannerConfig, BannerSlide
        
        # Configuración del sistema
        config = SystemConfig.get_config()
        
        # Versiones
        latest_version = GameVersion.get_latest()
        current_launcher = LauncherVersion.get_current()
        
        # Noticias activas
        active_messages = NewsMessage.query.filter_by(is_active=True).order_by(
            NewsMessage.priority.desc(), 
            NewsMessage.created_at.desc()
        ).limit(10).all()
        
        # Banner activo
        banner = BannerConfig.get_active()
        slides = []
        if banner:
            slides = BannerSlide.query.filter_by(
                banner_id=banner.id, 
                is_active=True
            ).order_by(BannerSlide.order_index).all()
        
        # Si no hay banner activo, usar configuración por defecto
        if not banner:
            banner = type('obj', (object,), {
                'name': 'Game Launcher',
                'auto_rotate': True,
                'rotation_interval': 6000,
                'show_controller': True,
                'width': 1016,
                'height': 540,
                'enable_socketio': True
            })
        
        # Si no hay slides, usar slide por defecto
        if not slides:
            slides = [type('obj', (object,), {
                'id': 1,
                'title': 'Bienvenido al Launcher',
                'content': 'Sistema funcionando correctamente',
                'image_url': '/static/img/banner-default.jpg',
                'order_index': 0
            })]
        
        # Preparar datos para el template
        banner_data = {
            'config': {
                'name': banner.name,
                'auto_rotate': banner.auto_rotate,
                'rotation_interval': banner.rotation_interval,
                'show_controller': banner.show_controller,
                'width': 1016,  # Fijo
                'height': 540,  # Fijo
                'enable_socketio': banner.enable_socketio
            },
            'slides': [
                {
                    'id': slide.id if hasattr(slide, 'id') else 1,
                    'title': slide.title if hasattr(slide, 'title') else 'Título',
                    'content': slide.content if hasattr(slide, 'content') else 'Contenido',
                    'image_url': slide.image_url if hasattr(slide, 'image_url') else None
                } for slide in slides
            ]
        }
        
        initial_data = {
            'system_status': {
                'status': 'maintenance' if config.maintenance_mode else 'online',
                'latest_game_version': latest_version.version if latest_version else 'N/A',
                'current_launcher_version': current_launcher.version if current_launcher else 'N/A',
                'maintenance_mode': config.maintenance_mode,
                'maintenance_message': config.maintenance_message
            },
            'news': [
                {
                    'id': msg.id,
                    'type': msg.type,
                    'message': msg.message,
                    'priority': msg.priority,
                    'created_at': msg.created_at.isoformat() if msg.created_at else None
                } for msg in active_messages
            ],
            'stats': {
                'players': 500,  # Simulado
                'servers': '3/3',
                'status': 'online'
            }
        }
        
        return render_template('banner/live.html', 
                             banner_data=banner_data,
                             initial_data=initial_data)
        
    except Exception as e:
        current_app.logger.error(f"Error loading banner live: {e}")
        # Fallback mínimo
        return render_template('banner/live.html', 
                             banner_data={
                                 'config': {
                                     'name': 'Game Launcher',
                                     'auto_rotate': True,
                                     'rotation_interval': 6000,
                                     'show_controller': True,
                                     'width': 1016,
                                     'height': 540,
                                     'enable_socketio': True
                                 },
                                 'slides': [{
                                     'id': 1,
                                     'title': 'Game Launcher',
                                     'content': 'Sistema en línea',
                                     'image_url': None
                                 }]
                             },
                             initial_data={
                                 'system_status': {
                                     'status': 'online',
                                     'latest_game_version': 'N/A',
                                     'current_launcher_version': 'N/A',
                                     'maintenance_mode': False,
                                     'maintenance_message': None
                                 },
                                 'news': [],
                                 'stats': {
                                     'players': 0,
                                     'servers': '0/3',
                                     'status': 'offline'
                                 }
                             })

@api_bp.route('/banner/iframe')
def banner_iframe():
    """Banner para embebido en iframe - Sin layout del admin"""
    try:
        # Reutilizar la misma lógica pero con template diferente
        return banner_live()
    except Exception as e:
        current_app.logger.error(f"Error loading banner iframe: {e}")
        return "<h1>Error cargando banner</h1>", 500

@api_bp.route('/banner/config', methods=['GET'])
def get_banner_config():
    """API pública para obtener configuración del banner activo"""
    try:
        banner = BannerConfig.get_active()
        
        if not banner:
            # Retornar configuración por defecto
            return jsonify({
                'config': {
                    'name': 'Banner por Defecto',
                    'auto_rotate': True,
                    'rotation_interval': 6000,
                    'show_controller': True,
                    'responsive': True,
                    'enable_socketio': True
                },
                'slides': [
                    {
                        'id': 1,
                        'title': 'Bienvenido al Launcher',
                        'content': 'Noticias y Actualizaciones',
                        'image_url': 'img/banner.png',
                        'link_url': '#'
                    }
                ]
            })
        
        # Obtener slides activos del banner
        slides = BannerSlide.query.filter_by(
            banner_id=banner.id, 
            is_active=True
        ).order_by(BannerSlide.order_index).all()
        
        return jsonify({
            'config': banner.to_dict(),
            'slides': [slide.to_dict() for slide in slides]
        })
        
    except Exception as e:
        current_app.logger.error(f"Error fetching banner config: {e}")
        return jsonify({'error': str(e)}), 500

@api_bp.route('/banner/refresh', methods=['POST'])
def refresh_banner():
    """Forzar actualización del banner en todos los launchers conectados"""
    try:
        banner = BannerConfig.get_active()
        
        if not banner:
            return jsonify({'error': 'No hay banner activo'}), 404
        
        slides = BannerSlide.query.filter_by(
            banner_id=banner.id, 
            is_active=True
        ).order_by(BannerSlide.order_index).all()
        
        # Emitir actualización a todos los launchers
        try:
            from public_socketio_utils import emit_to_public
            emit_to_public('banner_refresh', {
                'config': banner.to_dict(),
                'slides': [slide.to_dict() for slide in slides],
                'timestamp': datetime.utcnow().isoformat()
            })
        except ImportError:
            pass
        
        return jsonify({
            'success': True,
            'message': 'Banner actualizado en todos los launchers'
        })
        
    except Exception as e:
        current_app.logger.error(f"Error refreshing banner: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@api_bp.route('/files/<filename>')
def download_game_file(filename):
    """Endpoint para descargar archivos individuales del juego"""
    try:
        file_path = os.path.join(current_app.config['UPLOAD_FOLDER'], 'files', filename)
        
        if not os.path.exists(file_path):
            log_download(filename, 'game_file', success=False)
            return jsonify({"error": "File not found"}), 404
        
        log_download(filename, 'game_file')
        
        # ✅ FORZAR DESCARGA con headers correctos
        return send_from_directory(
            os.path.join(current_app.config['UPLOAD_FOLDER'], 'files'), 
            filename,
            as_attachment=True,  # 🔥 FUERZA LA DESCARGA
            download_name=filename  # Nombre del archivo descargado
        )
    except Exception as e:
        log_download(filename, 'game_file', success=False)
        return jsonify({"error": str(e)}), 500

@api_bp.route('/updates/<filename>')
def download_update(filename):
    """Endpoint para descargar paquetes de actualización"""
    try:
        file_path = os.path.join(current_app.config['UPLOAD_FOLDER'], 'updates', filename)
        
        if not os.path.exists(file_path):
            log_download(filename, 'update', success=False)
            return jsonify({"error": "Update file not found"}), 404
        
        log_download(filename, 'update')
        return send_from_directory(os.path.join(current_app.config['UPLOAD_FOLDER'], 'updates'), filename)
    except Exception as e:
        log_download(filename, 'update', success=False)
        return jsonify({"error": str(e)}), 500

@api_bp.route('/LauncherUpdater.exe')
def download_launcher_updater():
    """Endpoint para descargar el actualizador del launcher"""
    try:
        file_name = 'LauncherUpdater.exe'
        folder_path = os.path.join(current_app.root_path, 'static', 'downloads')
        file_path = os.path.join(folder_path, file_name)
        if not os.path.exists(file_path):
            log_download('LauncherUpdater.exe', 'launcher_updater', success=False)
            return jsonify({"error": "Launcher updater not found"}), 404
        
        log_download('LauncherUpdater.exe', 'launcher_updater')
        return send_from_directory('static/downloads', 'LauncherUpdater.exe')
    except Exception as e:
        log_download('LauncherUpdater.exe', 'launcher_updater', success=False)
        return jsonify({"error": str(e)}), 500

@api_bp.route('/PBConfig.exe')
def download_Config():
    """Endpoint para descargar el PBConfig"""
    try:
        file_name = 'PBConfig.exe'
        folder_path = os.path.join(current_app.root_path, 'static', 'downloads')
        file_path = os.path.join(folder_path, file_name)

        if not os.path.exists(file_path):
            log_download('PBConfig.exe', 'PBConfig', success=False)
            return jsonify({"error": "Config not found"}), 404
        
        log_download('PBConfig.exe', 'PBConfig')
        return send_from_directory('static/downloads', 'PBConfig.exe')
    except Exception as e:
        log_download('PBConfig.exe', 'PBConfig', success=False)
        return jsonify({"error": str(e)}), 500

@api_bp.route('/status')
def api_status():
    """Endpoint para verificar el estado de la API con información extendida"""
    try:
        config = SystemConfig.get_config()
        system_status = SystemStatus.get_current()
        latest_version = GameVersion.get_latest()
        launcher_version = LauncherVersion.get_current()
        total_files = GameFile.query.count()
        total_updates = UpdatePackage.query.count()
        
        # Verificar estado del sistema
        is_maintenance, maintenance_msg = check_maintenance_mode()
        
        response_data = {
            "status": "maintenance" if is_maintenance else "online",
            "maintenance_mode": is_maintenance,
            "maintenance_message": maintenance_msg if is_maintenance else None,
            "latest_game_version": latest_version.version if latest_version else "N/A",
            "current_launcher_version": launcher_version.version if launcher_version else "N/A",
            "total_files": total_files,
            "total_updates": total_updates,
            "system_config": {
                "auto_update_enabled": config.auto_update_enabled,
                "force_ssl": config.force_ssl,
                "update_check_interval": config.update_check_interval,
                "debug_mode": config.debug_mode
            },
            "system_stats": system_status.to_dict(),
            "timestamp": datetime.utcnow().isoformat()
        }
        
        if is_maintenance:
            return jsonify(response_data), 503
        
        return jsonify(response_data)
        
    except Exception as e:
        current_app.logger.error(f"Error in api_status: {e}")
        return jsonify({
            "status": "error",
            "error": str(e)
        }), 500

@api_bp.route('/config')
def get_public_config():
    """Endpoint público para obtener configuración del launcher"""
    try:
        config = SystemConfig.get_config()
        
        # Solo devolver configuración pública (no sensible)
        public_config = {
            "launcher_base_url": config.launcher_base_url,
            "update_check_interval": config.update_check_interval,
            "max_download_retries": config.max_download_retries,
            "connection_timeout": config.connection_timeout,
            "auto_update_enabled": config.auto_update_enabled,
            "force_ssl": config.force_ssl,
            "maintenance_mode": config.maintenance_mode,
            "debug_mode": config.debug_mode,
            "proxy_enabled": config.proxy_enabled,
            "proxy_port": config.proxy_port,
            "proxy_ip": config.proxy_ip
        }
        
        return jsonify(public_config)
        
    except Exception as e:
        current_app.logger.error(f"Error in get_public_config: {e}")
        return jsonify({"error": str(e)}), 500

@api_bp.route('/stats')
def download_stats():
    """Endpoint para estadísticas de descarga"""
    try:
        # Estadísticas básicas
        total_downloads = DownloadLog.query.count()
        successful_downloads = DownloadLog.query.filter_by(success=True).count()
        failed_downloads = DownloadLog.query.filter_by(success=False).count()
        
        # Descargas por tipo
        stats_by_type = db.session.query(
            DownloadLog.file_type, 
            db.func.count(DownloadLog.id).label('count')
        ).group_by(DownloadLog.file_type).all()
        
        # Archivos más descargados
        popular_files = db.session.query(
            DownloadLog.file_requested,
            db.func.count(DownloadLog.id).label('count')
        ).group_by(DownloadLog.file_requested).order_by(db.func.count(DownloadLog.id).desc()).limit(10).all()
        
        return jsonify({
            "total_downloads": total_downloads,
            "successful_downloads": successful_downloads,
            "failed_downloads": failed_downloads,
            "success_rate": round((successful_downloads / total_downloads * 100), 2) if total_downloads > 0 else 0,
            "downloads_by_type": {stat[0]: stat[1] for stat in stats_by_type},
            "popular_files": [{"file": stat[0], "downloads": stat[1]} for stat in popular_files]
        })
    except Exception as e:
        current_app.logger.error(f"Error in download_stats: {e}")
        return jsonify({"error": str(e)}), 500

def validate_login_input(username, password):
    """Validar entrada de login para prevenir ataques"""
    # Verificar que los campos no estén vacíos
    if not username or not password:
        return False, "Username y password son requeridos"
    
    # Verificar longitud
    if len(username) > 80 or len(password) > 255:
        return False, "Username o password demasiado largos"
    
    # Verificar caracteres peligrosos
    dangerous_patterns = [
        r"['\";]",  # Comillas y punto y coma
        r"(union|select|insert|update|delete|drop|exec|script)",  # SQL keywords
        r"(<script|javascript:|vbscript:)",  # XSS patterns
        r"(--|#|\/\*)"  # SQL comments
    ]
    
    for pattern in dangerous_patterns:
        if re.search(pattern, username, re.IGNORECASE) or re.search(pattern, password, re.IGNORECASE):
            return False, "Caracteres no permitidos detectados"
    
    return True, "Válido"

def log_login_attempt(username, ip_address, success, reason=""):
    """Registrar intento de login en logs"""
    try:
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'username': username,
            'ip_address': ip_address,
            'success': success,
            'reason': reason,
            'user_agent': request.headers.get('User-Agent', '')
        }
        
        # Log en archivo de aplicación
        if success:
            current_app.logger.info(f"LOGIN_SUCCESS: {username} from {ip_address}")
        else:
            current_app.logger.warning(f"LOGIN_FAILED: {username} from {ip_address} - {reason}")
        
        return True
        
    except Exception as e:
        current_app.logger.error(f"Error logging login attempt: {e}")
        return False

def validate_account_login_input(username, password):
    """Validar entrada de login para tabla accounts"""
    # Verificar que los campos no estén vacíos
    if not username or not password:
        return False, "Username y password son requeridos"
    
    # Verificar longitud según el esquema de la tabla
    if len(username) > 64 or len(password) > 64:
        return False, "Username o password demasiado largos (máximo 64 caracteres)"
    
    # Verificar caracteres peligrosos
    dangerous_patterns = [
        r"['\";]",  # Comillas y punto y coma
        r"(union|select|insert|update|delete|drop|exec|script)",  # SQL keywords
        r"(<script|javascript:|vbscript:)",  # XSS patterns
        r"(--|#|\/\*)"  # SQL comments
    ]
    
    for pattern in dangerous_patterns:
        if re.search(pattern, username, re.IGNORECASE) or re.search(pattern, password, re.IGNORECASE):
            return False, "Caracteres no permitidos detectados"
    
    # Verificar caracteres de control
    if any(ord(char) < 32 for char in username + password):
        return False, "Caracteres de control no permitidos"
    
    return True, "Válido"

def log_account_login_attempt(username, ip_address, success, reason="", user_agent=""):
    """Registrar intento de login para tabla accounts"""
    try:
        # Registrar en base de datos
        LoginAttempt.record_attempt(
            username=username,
            ip_address=ip_address,
            success=success,
            user_agent=user_agent
        )
        
        # Log en archivo de aplicación
        if success:
            current_app.logger.info(f"ACCOUNT_LOGIN_SUCCESS: {username} from {ip_address}")
        else:
            current_app.logger.warning(f"ACCOUNT_LOGIN_FAILED: {username} from {ip_address} - {reason}")
        
        return True
        
    except Exception as e:
        current_app.logger.error(f"Error logging account login attempt: {e}")
        return False

# API de login para tabla accounts
@api_bp.route('/account/login', methods=['POST'])
@rate_limit("5 per minute")  # Máximo 5 intentos por minuto por IP
def account_login():
    try:
        # Verificar que sea POST con JSON
        if not request.is_json:
            log_account_login_attempt("", request.remote_addr, False, "Invalid content type")
            return jsonify({
                "success": False,
                "message": "Content-Type debe ser application/json",
                "error_code": "INVALID_CONTENT_TYPE"
            }), 400
        
        # Obtener datos del request
        data = request.get_json()
        username = data.get('username', '').strip()
        password = data.get('password', '')
        user_agent = request.headers.get('User-Agent', '')
        
        # Validar entrada
        is_valid, validation_message = validate_account_login_input(username, password)
        if not is_valid:
            log_account_login_attempt(username, request.remote_addr, False, validation_message, user_agent)
            return jsonify({
                "success": False,
                "message": "Datos de entrada inválidos",
                "error_code": "INVALID_INPUT"
            }), 400
        
        # Verificar protección contra fuerza bruta por username
        if LoginAttempt.check_brute_force(username=username, time_window_minutes=15, max_attempts=5):
            log_account_login_attempt(username, request.remote_addr, False, "Brute force protection - username", user_agent)
            return jsonify({
                "success": False,
                "message": "Demasiados intentos fallidos para este usuario. Intenta en 15 minutos.",
                "error_code": "BRUTE_FORCE_USERNAME"
            }), 429
        
        # Verificar protección contra fuerza bruta por IP
        if LoginAttempt.check_brute_force(ip_address=request.remote_addr, time_window_minutes=15, max_attempts=10):
            log_account_login_attempt(username, request.remote_addr, False, "Brute force protection - IP", user_agent)
            return jsonify({
                "success": False,
                "message": "Demasiados intentos fallidos desde esta IP. Intenta en 15 minutos.",
                "error_code": "BRUTE_FORCE_IP"
            }), 429
        
        # Agregar pequeño delay para mitigar timing attacks
        time.sleep(0.1)
        
        # Autenticar usuario usando el método del modelo
        try:
            account = Account.authenticate(username, password)
        except Exception as e:
            current_app.logger.error(f"Database error during account authentication: {e}")
            log_account_login_attempt(username, request.remote_addr, False, "Database error", user_agent)
            return jsonify({
                "success": False,
                "message": "Error interno del servidor",
                "error_code": "DATABASE_ERROR"
            }), 500
        
        # Verificar resultado de autenticación
        if not account:
            log_account_login_attempt(username, request.remote_addr, False, "Invalid credentials", user_agent)
            
            # Agregar delay adicional en caso de fallo para mitigar ataques
            time.sleep(0.5)
            
            return jsonify({
                "success": False,
                "message": "Usuario o contraseña incorrectos",
                "error_code": "INVALID_CREDENTIALS"
            }), 401
        
        # Login exitoso
        log_account_login_attempt(username, request.remote_addr, True, "Login successful", user_agent)
        
        # Preparar datos del usuario (sin información sensible)
        user_data = account.to_dict(include_sensitive=False)
        
        # Respuesta exitosa
        current_app.logger.info(f"User {username} logged in successfully from {request.remote_addr}")
        return jsonify({
            "success": True,
            "message": "Login exitoso",
            "user_data": user_data,
            "player_id": account.player_id,
            "session_info": {
                "login_time": datetime.utcnow().isoformat(),
                "ip_address": request.remote_addr
            }
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Unexpected error in account_login: {e}")
        log_account_login_attempt("", request.remote_addr, False, f"Unexpected error: {str(e)}", "")
        return jsonify({
            "success": False,
            "message": "Error interno del servidor",
            "error_code": "INTERNAL_ERROR"
        }), 500

# API adicional para verificar estado de cuenta
@api_bp.route('/account/verify', methods=['POST'])
@rate_limit("10 per minute")
def verify_account():
    """Verificar si una cuenta existe"""
    try:
        if not request.is_json:
            return jsonify({
                "success": False,
                "message": "Content-Type debe ser application/json"
            }), 400
        
        data = request.get_json()
        username = data.get('username', '').strip()
        
        if not username:
            return jsonify({
                "success": False,
                "message": "Username es requerido"
            }), 400
        
        # Validar entrada básica
        if len(username) > 64:
            return jsonify({
                "success": False,
                "message": "Username demasiado largo"
            }), 400
        
        # Buscar cuenta usando ORM (protegido contra SQL injection)
        account = Account.query.filter_by(username=username).first()
        
        if account:
            return jsonify({
                "success": True,
                "exists": True,
                "account_info": {
                    "username": account.username,
                    "player_id": account.player_id
                }
            }), 200
        else:
            return jsonify({
                "success": True,
                "exists": False
            }), 200
            
    except Exception as e:
        current_app.logger.error(f"Error in verify_account: {e}")
        return jsonify({
            "success": False,
            "message": "Error interno del servidor"
        }), 500

# API para obtener estadísticas de intentos de login (para administradores)
@api_bp.route('/account/login_stats', methods=['GET'])
@rate_limit("60 per hour")
def account_login_stats():
    """Obtener estadísticas de intentos de login"""
    try:
        from datetime import timedelta
        
        # Estadísticas de las últimas 24 horas
        last_24h = datetime.utcnow() - timedelta(hours=24)
        
        total_attempts = LoginAttempt.query.filter(
            LoginAttempt.attempt_time >= last_24h
        ).count()
        
        successful_attempts = LoginAttempt.query.filter(
            LoginAttempt.attempt_time >= last_24h,
            LoginAttempt.success == True
        ).count()
        
        failed_attempts = LoginAttempt.query.filter(
            LoginAttempt.attempt_time >= last_24h,
            LoginAttempt.success == False
        ).count()
        
        # Top IPs con más intentos fallidos
        top_failed_ips = db.session.query(
            LoginAttempt.ip_address,
            db.func.count(LoginAttempt.id).label('failed_count')
        ).filter(
            LoginAttempt.attempt_time >= last_24h,
            LoginAttempt.success == False
        ).group_by(
            LoginAttempt.ip_address
        ).order_by(
            db.func.count(LoginAttempt.id).desc()
        ).limit(10).all()
        
        # Top usuarios con más intentos fallidos
        top_failed_users = db.session.query(
            LoginAttempt.username,
            db.func.count(LoginAttempt.id).label('failed_count')
        ).filter(
            LoginAttempt.attempt_time >= last_24h,
            LoginAttempt.success == False
        ).group_by(
            LoginAttempt.username
        ).order_by(
            db.func.count(LoginAttempt.id).desc()
        ).limit(10).all()
        
        return jsonify({
            "success": True,
            "period": "last_24_hours",
            "stats": {
                "total_attempts": total_attempts,
                "successful_attempts": successful_attempts,
                "failed_attempts": failed_attempts,
                "success_rate": round((successful_attempts / total_attempts * 100), 2) if total_attempts > 0 else 0
            },
            "top_failed_ips": [{"ip": ip, "count": count} for ip, count in top_failed_ips],
            "top_failed_users": [{"username": username, "count": count} for username, count in top_failed_users]
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Error in account_login_stats: {e}")
        return jsonify({
            "success": False,
            "message": "Error interno del servidor"
        }), 500

# Tarea de limpieza automática
def cleanup_old_login_attempts():
    """Función para limpiar intentos de login antiguos"""
    try:
        deleted_count = LoginAttempt.cleanup_old_attempts(days_to_keep=30)
        current_app.logger.info(f"Limpieza automática: {deleted_count} intentos de login antiguos eliminados")
        return deleted_count
    except Exception as e:
        current_app.logger.error(f"Error en limpieza automática de login attempts: {e}")
        return 0

@api_bp.before_request
def check_rate_limit():
    """Verificar límites de velocidad antes de cada request"""
    try:
        config = SystemConfig.get_config()
        
        if not config.rate_limiting_enabled:
            return None
        
        # La lógica de rate limiting se maneja con el decorador @rate_limit
        return None
        
    except Exception as e:
        current_app.logger.error(f"Error in rate limiting: {e}")
        return None

@api_bp.after_request
def log_request(response):
    """Log de requests si está habilitado"""
    try:
        config = SystemConfig.get_config()
        
        if config.log_all_requests:
            current_app.logger.info(
                f"{request.remote_addr} - {request.method} {request.path} - {response.status_code}"
            )
        
        return response
        
    except Exception as e:
        current_app.logger.error(f"Error logging request: {e}")
        return response

@api_bp.errorhandler(503)
def maintenance_mode_handler(error):
    """Manejador personalizado para modo mantenimiento"""
    try:
        config = SystemConfig.get_config()
        return jsonify({
            "status": "maintenance",
            "message": config.maintenance_message,
            "maintenance_mode": True
        }), 503
    except Exception as e:
        return jsonify({
            "status": "maintenance",
            "message": "Sistema en mantenimiento",
            "maintenance_mode": True
        }), 503

@api_bp.errorhandler(404)
def api_not_found(error):
    return jsonify({"error": "Endpoint not found"}), 404

@api_bp.errorhandler(500)
def api_internal_error(error):
    return jsonify({"error": "Internal server error"}), 500

@api_bp.before_request
def reject_proxies():
    user_agent = request.headers.get('User-Agent', '')
    if 'Fiddler' in user_agent or 'HTTPDebugger' in user_agent:
        abort(403)