from pprint import pprint
from flask import Blueprint, abort, render_template, request, redirect, url_for, flash, current_app, jsonify, send_file
from flask_login import login_required, current_user
from werkzeug.utils import secure_filename
from models import (GameVersion, GameFile, UpdatePackage, LauncherVersion, NewsMessage, DownloadLog, ServerSettings, User, db,launcher_ban,SystemConfig, SystemStatus, NotificationLog,BannerConfig, BannerSlide)
import os
import hashlib
import zipfile
from datetime import datetime, time, timedelta
import json

# Importar funciones de utils
from utils import (
    format_file_size, 
    validate_version_format, 
    generate_launcher_json,
    backup_file,
    safe_delete_file
)

from public_socketio_utils import (
    notify_maintenance_mode_changed,
    notify_new_game_version_available,
    notify_launcher_update_available,
    notify_news_updated,
    notify_system_status_changed,
    emit_to_both_namespaces
)
# Importar funciones de SocketIO si están disponibles
try:
    from socketio_utils import (
        notify_admin, 
        notify_version_created, 
        notify_files_uploaded, 
        notify_update_created,
        notify_message_created,
        notify_launcher_uploaded,
        broadcast_stats_update
    )
except ImportError:
    # Crear funciones dummy si socketio_utils no está disponible
    def notify_launcher_uploaded(*args, **kwargs):
        pass
    def notify_message_created(*args, **kwargs):
        pass



admin_bp = Blueprint('admin', __name__)


# AGREGAR ESTA FUNCIÓN HELPER AL INICIO DEL ARCHIVO:
# 2. AGREGAR RUTA PARA PROBAR SOCKETIO:

# AGREGAR NOTIFICACIONES EN RUTAS IMPORTANTES:

# ==================== FUNCIONES AUXILIARES ====================

def allowed_file(filename, allowed_extensions):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in allowed_extensions

def calculate_md5(file_path):
    """Calcular MD5 de un archivo"""
    hash_md5 = hashlib.md5()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

# ==================== DASHBOARD ====================

@admin_bp.route('/')
@login_required
def dashboard():
    """Dashboard principal - Solo renderiza la estructura HTML."""
    try:
        # Aquí ya no se cargan todos los datos. Vue.js los pedirá vía API.
        # Se pueden pasar variables mínimas si la plantilla lo necesita para lógica de "if"
        # pero para el dashboard, la estructura es bastante estática.
        return render_template('admin/dashboard.html') # Vue.js pedirá los datos después
    except Exception as e:
        flash(f'Error loading dashboard: {str(e)}', 'error')
        return render_template('admin/dashboard.html')

# --- NUEVA RUTA API para los datos del Dashboard ---
@admin_bp.route('/api/dashboard_data', methods=['GET'])
@login_required
def get_dashboard_data():
    """API para obtener todos los datos del dashboard."""
    try:
        total_versions = GameVersion.query.count()
        total_files = GameFile.query.count()
        total_updates = UpdatePackage.query.count()
        total_downloads = DownloadLog.query.count()

        latest_version = GameVersion.get_latest()
        current_launcher = LauncherVersion.get_current()

        yesterday = datetime.utcnow() - timedelta(days=1)
        recent_downloads = DownloadLog.query.filter(DownloadLog.created_at >= yesterday).count()

        active_messages = NewsMessage.query.filter_by(is_active=True).count()

        downloads_by_day = []
        for i in range(7):
            day = datetime.utcnow() - timedelta(days=i)
            day_start = day.replace(hour=0, minute=0, second=0, microsecond=0)
            day_end = day_start + timedelta(days=1)
            count = DownloadLog.query.filter(
                DownloadLog.created_at >= day_start,
                DownloadLog.created_at < day_end
            ).count()
            downloads_by_day.append({
                'date': day_start.strftime('%Y-%m-%d'),
                'count': count
            })
        downloads_by_day.reverse()

        return jsonify({
            'stats': {
                'totalVersions': total_versions,
                'totalFiles': total_files,
                'totalUpdates': total_updates,
                'totalDownloads': total_downloads,
                'recentDownloads': recent_downloads,
                'activeMessages': active_messages,
                'latestVersion': latest_version.version if latest_version else ''
            },
            'systemStatus': {
                'gameVersion': latest_version.version if latest_version else '',
                'launcherVersion': current_launcher.version if current_launcher else ''
            },
            'chartData': downloads_by_day
        })
    except Exception as e:
        current_app.logger.error(f"Error fetching dashboard data: {e}")
        return jsonify({'error': 'Error al cargar datos del dashboard', 'details': str(e)}), 500
# ==================== RUTAS ADMINISTRATIVAS ====================
@admin_bp.route('/versions')
@login_required
def versions():
    """Gestión de versiones del juego"""
    versions = GameVersion.query.order_by(GameVersion.created_at.desc()).all()
    return render_template('admin/versions.html', versions=versions)

# ==================== RUTAS PARA VERSIONES DEL JUEGO ====================
@admin_bp.route('/versions/create', methods=['GET', 'POST'])
@login_required
def create_version():
    """Crear nueva versión"""
    if request.method == 'POST':
        try:
            version = request.form['version']
            release_notes = request.form['release_notes']
            is_latest = 'is_latest' in request.form
            
            # Verificar que la versión no exista
            existing = GameVersion.query.filter_by(version=version).first()
            if existing:
                flash('Esta versión ya existe', 'error')
                return render_template('admin/create_version.html')
            
            new_version = GameVersion(
                version=version,
                release_notes=release_notes,
                created_by=current_user.id
            )
            
            db.session.add(new_version)
            db.session.commit()
            
            if is_latest:
                new_version.set_as_latest()
            
            flash(f'Versión {version} creada exitosamente', 'success')
            return redirect(url_for('admin.versions'))
        
        except Exception as e:
            db.session.rollback()
            flash(f'Error al crear versión: {str(e)}', 'error')
    
    return render_template('admin/create_version.html')


@admin_bp.route('/api/versions_data', methods=['GET'])
@login_required
def get_versions_data():
    """API para obtener los datos de las versiones (SIN archivos asociados)."""
    try:
        # Obtener todas las versiones con sus relaciones (solo update_packages)
        versions = GameVersion.query.order_by(GameVersion.created_at.desc()).all()

        versions_data = []
        for version in versions:
            version_dict = {
                'id': version.id,
                'version': version.version,
                'is_latest': version.is_latest,
                'release_notes': version.release_notes,
                'created_at': version.created_at.isoformat() if version.created_at else None,
                'created_by': version.created_by,
                'update_packages': []
                # ❌ REMOVIDO: 'files': [] - Los archivos ahora son independientes
            }
            
            # ❌ REMOVIDO: Código para agregar archivos asociados
            # Los archivos de reparación son independientes de versiones
            
            # Agregar paquetes de actualización
            if version.update_packages:
                for package in version.update_packages:
                    version_dict['update_packages'].append({
                        'id': package.id,
                        'filename': package.filename,
                        'file_size': package.file_size,
                        'md5_hash': package.md5_hash,
                        'created_at': package.created_at.isoformat() if package.created_at else None
                    })
            
            versions_data.append(version_dict)

        # Calcular estadísticas
        total_versions = len(versions)
        latest_version = GameVersion.get_latest()
        
        # ❌ REMOVIDO: versions_with_files - Los archivos son independientes ahora
        versions_with_packages = len([v for v in versions if v.update_packages])

        return jsonify({
            'versions': versions_data,
            'stats': {
                'total_versions': total_versions,
                'latest_version': latest_version.version if latest_version else None,
                'versions_with_packages': versions_with_packages
                # ❌ REMOVIDO: 'versions_with_files'
            }
        })
    except Exception as e:
        current_app.logger.error(f"Error fetching versions data: {e}")
        return jsonify({'error': 'Error al cargar datos de versiones', 'details': str(e)}), 500
    
@admin_bp.route('/versions/<int:version_id>/set_latest', methods=['POST'])
@login_required
def set_latest_version_api(version_id):
    """Establecer versión como la más reciente - Compatible con API"""
    try:
        version = db.session.get(GameVersion, version_id)
        old_latest = GameVersion.get_latest()
        
        if not version:
            abort(404, description="Versión no encontrada")
            
        version.set_as_latest()
        
        # ✅ NUEVO: Notificar a launchers sobre nueva versión
        notify_new_game_version_available(version.version, is_latest=True)
        
        # Notificar via SocketIO admin
        try:
            from socketio_utils import notify_admin
            notify_admin(
                f'Versión {version.version} establecida como la más reciente',
                'success',
                {
                    'action': 'version_set_latest',
                    'version': version.version,
                    'version_id': version.id,
                    'old_latest': old_latest.version if old_latest else None
                }
            )
        except ImportError:
            pass
        
        if request.is_json or request.headers.get('Content-Type') == 'application/json':
            return jsonify({
                'success': True,
                'message': f'Versión {version.version} establecida como la más reciente',
                'version': version.version
            })
        else:
            flash(f'Versión {version.version} establecida como la más reciente', 'success')
            return redirect(url_for('admin.versions'))
            
    except Exception as e:
        current_app.logger.error(f"Error setting latest version: {e}")
        if request.is_json or request.headers.get('Content-Type') == 'application/json':
            return jsonify({'error': str(e)}), 500
        else:
            flash(f'Error: {str(e)}', 'error')
            return redirect(url_for('admin.versions'))


@admin_bp.route('/versions/<int:version_id>/delete', methods=['POST'])
@login_required
def delete_version_api(version_id):
    """Eliminar versión (SIN eliminar archivos de reparación)"""
    try:
        version = GameVersion.query.get_or_404(version_id)
        
        if version.is_latest:
            error_msg = 'No se puede eliminar la versión actual'
            if request.is_json or request.headers.get('Content-Type') == 'application/json':
                return jsonify({'error': error_msg}), 400
            else:
                flash(error_msg, 'error')
                return redirect(url_for('admin.versions'))
        
        version_name = version.version
        
        # ❌ REMOVIDO: Código para eliminar archivos asociados
        # Los archivos de reparación son independientes y NO se eliminan
        
        # ✅ SOLO eliminar paquetes de actualización (que sí dependen de versiones)
        for update_package in version.update_packages:
            if os.path.exists(update_package.file_path):
                os.remove(update_package.file_path)
            db.session.delete(update_package)
        
        # Eliminar la versión
        db.session.delete(version)
        db.session.commit()
        
        success_msg = f'Versión {version_name} eliminada exitosamente'
        current_app.logger.info(success_msg)
        
        if request.is_json or request.headers.get('Content-Type') == 'application/json':
            return jsonify({'success': True, 'message': success_msg})
        else:
            flash(success_msg, 'success')
            return redirect(url_for('admin.versions'))
            
    except Exception as e:
        db.session.rollback()
        error_msg = f"Error eliminando versión: {str(e)}"
        current_app.logger.error(error_msg)
        
        if request.is_json or request.headers.get('Content-Type') == 'application/json':
            return jsonify({'error': error_msg}), 500
        else:
            flash(error_msg, 'error')
            return redirect(url_for('admin.versions'))


# ==================== RUTAS PARA GESTIONAR ARCHIVOS DEL JUEGO ====================
@admin_bp.route('/files')
@login_required
def files():
    """Gestión de archivos del juego - TODOS los archivos para reparación"""
    try:
        return render_template('admin/files.html')
    except Exception as e:
        flash(f'Error: {str(e)}', 'error')
        return render_template('admin/files.html')

# --- NUEVA RUTA API para los datos de la tabla de archivos ---
@admin_bp.route('/api/files_data', methods=['GET'])
@login_required
def get_files_data():
    """API para obtener los datos de los archivos, con paginación y filtro."""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 50, type=int)
        
        
        
        files_paginated = GameFile.query.order_by(GameFile.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )

        files_data = []
        for file in files_paginated.items:
            file_dict = {
                'id': file.id,
                'filename': file.filename,
                'relative_path': file.relative_path,
                'md5_hash': file.md5_hash,
                'file_size': file.file_size, # En bytes
                'file_size_formatted': format_file_size(file.file_size) if file.file_size else '0 B',
                'created_at': file.created_at.isoformat() if file.created_at else None,
                'updated_at': file.updated_at.isoformat() if file.updated_at else None,
            }
            files_data.append(file_dict)

        # También enviar los URLs necesarios para acciones desde el cliente
        urls = {
            'deleteFile': url_for("admin.delete_file", file_id=0), # Placeholder 0 para el ID
            'deleteSelected': url_for("admin.delete_selected_files"),
            'downloadBase': url_for("static", filename="downloads/") + 'files/' # La ruta para descargar archivos individuales del juego
        }

        return jsonify({
            'files': files_data,
            'pagination': {
                'page': files_paginated.page,
                'pages': files_paginated.pages,
                'perPage': files_paginated.per_page,
                'total': files_paginated.total,
                'hasNext': files_paginated.has_next,
                'hasPrev': files_paginated.has_prev
            },
            'urls': urls
        })
    except Exception as e:
        current_app.logger.error(f"Error fetching files data: {e}")
        return jsonify({'error': 'Error al cargar datos de archivos', 'details': str(e)}), 500

@admin_bp.route('/files/upload', methods=['GET', 'POST'])
@login_required
def upload_files():
    """Subir archivos de reparación del juego (independientes de versión)"""
    if request.method == 'POST':
        try:
            uploaded_files = request.files.getlist('files')
            if not uploaded_files or not any(f.filename for f in uploaded_files):
                flash('No se seleccionaron archivos para subir', 'warning')
                return redirect(url_for('admin.upload_files'))
            
            files_uploaded = 0
            files_updated = 0
            
            current_app.logger.info(f"Iniciando subida de {len(uploaded_files)} archivos de reparación")
            
            for i, file in enumerate(uploaded_files):
                if file and file.filename:
                    try:
                        filename = secure_filename(file.filename)
                        relative_path = request.form.get(f'relative_path_{i}', f'bin/{filename}')
                        
                        current_app.logger.info(f"Procesando archivo de reparación: {filename} -> {relative_path}")
                        
                        # Guardar archivo físico
                        file_path = os.path.join(current_app.config['UPLOAD_FOLDER'], 'files', filename)
                        os.makedirs(os.path.dirname(file_path), exist_ok=True)
                        file.save(file_path)
                        
                        # Calcular MD5 y tamaño
                        md5_hash = calculate_md5(file_path)
                        file_size = os.path.getsize(file_path)
                        
                        current_app.logger.info(f"Archivo guardado: {file_path} ({file_size} bytes, MD5: {md5_hash})")
                        
                        # Verificar si el archivo ya existe (solo por filename, sin version_id)
                        existing_file = GameFile.query.filter_by(filename=filename).first()
                        
                        if existing_file:
                            # Actualizar archivo existente
                            existing_file.md5_hash = md5_hash
                            existing_file.file_size = file_size
                            existing_file.relative_path = relative_path
                            existing_file.updated_at = datetime.utcnow()
                            files_updated += 1
                            current_app.logger.info(f"Archivo de reparación actualizado: {filename}")
                        else:
                            # Crear nuevo registro (SIN version_id)
                            game_file = GameFile(
                                filename=filename,
                                relative_path=relative_path,
                                md5_hash=md5_hash,
                                file_size=file_size
                            )
                            db.session.add(game_file)
                            files_uploaded += 1
                            current_app.logger.info(f"Nuevo archivo de reparación creado: {filename}")
                            
                    except Exception as file_error:
                        current_app.logger.error(f"Error procesando archivo {file.filename}: {str(file_error)}")
                        db.session.rollback()
                        flash(f'Error procesando archivo {file.filename}: {str(file_error)}', 'error')
                        return redirect(url_for('admin.upload_files'))
            
            db.session.commit()
            
            success_parts = []
            if files_uploaded > 0:
                success_parts.append(f'{files_uploaded} archivos nuevos subidos')
            if files_updated > 0:
                success_parts.append(f'{files_updated} archivos actualizados')
            
            success_msg = ', '.join(success_parts) + ' como archivos de reparación'
            flash(success_msg, 'success')
            current_app.logger.info(f"Subida completada exitosamente: {success_msg}")
            
            return redirect(url_for('admin.files'))
            
        except Exception as e:
            db.session.rollback()
            error_msg = f'Error general al subir archivos de reparación: {str(e)}'
            current_app.logger.error(error_msg)
            flash(error_msg, 'error')
            return redirect(url_for('admin.upload_files'))

    # GET: Renderizar formulario simple (sin selección de versiones)
    return render_template('admin/upload_files.html')

@admin_bp.route('/updates')
@login_required
def updates():
    """Gestión de paquetes de actualización - Solo renderiza la estructura HTML."""
    try:
        # Solo renderizar el template, Vue.js cargará los datos
        return render_template('admin/updates.html')
    except Exception as e:
        flash(f'Error al cargar la página de actualizaciones: {str(e)}', 'error')
        return render_template('admin/updates.html')

@admin_bp.route('/updates/create', methods=['GET', 'POST'])
@login_required
def create_update():
    """Crear paquete de actualización - FIX MD5"""
    
    if request.method == 'POST':
        try:
            # Obtener datos básicos
            version_id = request.form.get('version_id')
            update_file = request.files.get('update_file')
            
            # ✅ FIX: Leer opciones con debugging
            generate_md5_raw = request.form.get('generate_md5', 'false')
            overwrite_existing_raw = request.form.get('overwrite_existing', 'false')
            validate_after_upload_raw = request.form.get('validate_after_upload', 'false')
            
            # Debug: Mostrar qué recibimos
            current_app.logger.info(f"🐛 DEBUG - Datos recibidos:")
            current_app.logger.info(f"  version_id: {version_id}")
            current_app.logger.info(f"  generate_md5_raw: '{generate_md5_raw}' (type: {type(generate_md5_raw)})")
            current_app.logger.info(f"  overwrite_existing_raw: '{overwrite_existing_raw}'")
            current_app.logger.info(f"  validate_after_upload_raw: '{validate_after_upload_raw}'")
            
            # ✅ FIX: Conversión más robusta de string a boolean
            def str_to_bool(value):
                if isinstance(value, bool):
                    return value
                if isinstance(value, str):
                    return value.lower() in ('true', '1', 'yes', 'on')
                return False
            
            # Convertir opciones a boolean
            generate_md5 = str_to_bool(generate_md5_raw)
            overwrite_existing = str_to_bool(overwrite_existing_raw)
            validate_after_upload = str_to_bool(validate_after_upload_raw)
            
            # Debug: Mostrar conversión
            current_app.logger.info(f"🔄 DEBUG - Después de conversión:")
            current_app.logger.info(f"  generate_md5: {generate_md5} (type: {type(generate_md5)})")
            current_app.logger.info(f"  overwrite_existing: {overwrite_existing}")
            current_app.logger.info(f"  validate_after_upload: {validate_after_upload}")
            
            # Validaciones básicas
            if not version_id:
                return jsonify({"error": "version_id es requerido"}), 400
                
            if not update_file or not update_file.filename:
                return jsonify({"error": "Archivo es requerido"}), 400
            
            # Validar extensión
            if not update_file.filename.lower().endswith('.zip'):
                return jsonify({"error": "Solo se permiten archivos ZIP"}), 415
            
            # Obtener versión
            version = GameVersion.query.get_or_404(version_id)
            filename = f"update_{version.version}.zip"
            
            # Guardar archivo
            file_path = os.path.join(current_app.config['UPLOAD_FOLDER'], 'updates', filename)
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
            update_file.save(file_path)
            
            # Obtener tamaño del archivo
            file_size = os.path.getsize(file_path)
            current_app.logger.info(f"📁 Archivo guardado: {file_path} ({file_size} bytes)")
            
            # ✅ FIX: Calcular MD5 con logging detallado
            md5_hash = None
            if generate_md5:
                current_app.logger.info("🔑 Calculando MD5...")
                try:
                    from utils import calculate_file_hash  # Usar función existente
                    md5_hash = calculate_file_hash(file_path, 'md5')
                    
                    if md5_hash:
                        current_app.logger.info(f"✅ MD5 calculado exitosamente: {md5_hash}")
                    else:
                        current_app.logger.error("❌ Error: MD5 retornó None")
                        
                except Exception as e:
                    current_app.logger.error(f"❌ Error calculando MD5: {e}")
                    md5_hash = None
            else:
                current_app.logger.info("⏭️ Generación de MD5 deshabilitada")
            
            # Validar archivo ZIP si está habilitado
            if validate_after_upload:
                current_app.logger.info("🔍 Validando archivo ZIP...")
                try:
                    import zipfile
                    with zipfile.ZipFile(file_path, 'r') as zipf:
                        if zipf.testzip() is not None:
                            os.remove(file_path)
                            return jsonify({"error": "El archivo ZIP está corrupto"}), 422
                    current_app.logger.info("✅ Archivo ZIP válido")
                except zipfile.BadZipFile:
                    os.remove(file_path)
                    return jsonify({"error": "El archivo no es un ZIP válido"}), 422
            
            # Manejar paquete existente
            existing_update = UpdatePackage.query.filter_by(version_id=version_id).first()
            if existing_update:
                if not overwrite_existing:
                    return jsonify({
                        "error": "Ya existe un paquete para esta versión",
                        "existing": True
                    }), 409
                
                # Eliminar archivo anterior
                # if os.path.exists(existing_update.file_path):
                #     os.remove(existing_update.file_path)
                #     current_app.logger.info(f"🗑️ Archivo anterior eliminado: {existing_update.file_path}")
                
                # Actualizar registro existente
                existing_update.filename = filename
                existing_update.file_path = file_path
                existing_update.file_size = file_size
                existing_update.md5_hash = md5_hash
                current_app.logger.info("🔄 Registro existente actualizado")
            
            else:
                # Crear nuevo registro
                update_package = UpdatePackage(
                    filename=filename,
                    version_id=version_id,
                    file_path=file_path,
                    file_size=file_size,
                    md5_hash=md5_hash,
                    uploaded_by=current_user.id
                )
                db.session.add(update_package)
                current_app.logger.info("➕ Nuevo registro creado")
            
            # Guardar en base de datos
            db.session.commit()
            current_app.logger.info("💾 Cambios guardados en base de datos")
            
            # ✅ DEBUG: Verificar qué se guardó en la base de datos
            saved_package = UpdatePackage.query.filter_by(version_id=version_id).first()
            if saved_package:
                current_app.logger.info(f"🔍 Verificación BD - MD5 guardado: '{saved_package.md5_hash}'")
            
            
            # Notificación SocketIO
            try:
                from socketio_utils import notify_update_created
                notify_update_created(version.version, filename)
                current_app.logger.info("📡 Notificación SocketIO enviada")
            except Exception as e:
                current_app.logger.warning(f"⚠️ No se pudo enviar notificación SocketIO: {e}")
            
            # ✅ Respuesta exitosa con información detallada
            response_data = {
                "success": True,
                "message": f"Paquete de actualización creado para versión {version.version}",
                "data": {
                    "version": version.version,
                    "filename": filename,
                    "file_size": file_size,
                    "file_size_formatted": format_file_size(file_size),
                    "md5_hash": md5_hash,
                    "md5_generated": generate_md5,
                    "md5_success": md5_hash is not None if generate_md5 else None,
                    "options": {
                        "overwrite_existing": overwrite_existing,
                        "validate_after_upload": validate_after_upload,
                        "generate_md5": generate_md5
                    }
                }
            }
            
            current_app.logger.info(f"✅ Paquete creado exitosamente: {filename}")
            return jsonify(response_data), 200
            
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f"❌ Error creando paquete: {e}", exc_info=True)
            
            # Limpiar archivo si se creó
            if 'file_path' in locals() and os.path.exists(file_path):
                try:
                    os.remove(file_path)
                    current_app.logger.info(f"🧹 Archivo limpiado: {file_path}")
                except:
                    pass
            
            return jsonify({
                "error": "Error interno del servidor",
                "message": str(e)
            }), 500
    
    # GET request - Renderizar template con datos para Vue.js
    versions = GameVersion.query.order_by(GameVersion.version.desc()).all()
    
    # CAMBIO IMPORTANTE: Convertir a diccionarios serializables
    versions_data = []
    for version in versions:
        version_dict = version.to_dict()  # Usar el método to_dict() existente
        # Agregar información de paquetes de actualización si es necesario
        version_dict['update_packages'] = [pkg.id for pkg in version.update_packages]
        versions_data.append(version_dict)
    
    return render_template('admin/create_update.html', versions=versions_data)


# AGREGAR: API endpoint para datos de updates
@admin_bp.route('/api/updates_data', methods=['GET'])
@login_required
def get_updates_data():
    """API para obtener los datos de los paquetes de actualización."""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 50, type=int)
        
        # Obtener updates con paginación
        updates_query = UpdatePackage.query.join(GameVersion).order_by(GameVersion.version.desc())
        updates_paginated = updates_query.paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        # Procesar datos
        updates_data = []
        for update in updates_paginated.items:
            update_dict = {
                'id': update.id,
                'filename': update.filename,
                'file_size': update.file_size,
                'file_size_formatted': format_file_size(update.file_size) if update.file_size else None,
                'md5_hash': update.md5_hash,
                'file_path': update.file_path,
                'file_exists': os.path.exists(update.file_path) if update.file_path else False,
                'created_at': update.created_at.isoformat() if update.created_at else None,
                'uploaded_by': update.uploaded_by,
                'version': {
                    'id': update.version.id,
                    'version': update.version.version,
                    'is_latest': update.version.is_latest,
                    'release_notes': update.version.release_notes
                }
            }
            updates_data.append(update_dict)
        
        # Calcular estadísticas
        all_updates = UpdatePackage.query.all()
        total_size = sum(u.file_size for u in all_updates if u.file_size)
        latest_update = UpdatePackage.query.join(GameVersion).filter(GameVersion.is_latest == True).first()
        with_md5_count = len([u for u in all_updates if u.md5_hash])
        
        stats = {
            'totalUpdates': len(all_updates),
            'totalSize': total_size,
            'totalSizeFormatted': format_file_size(total_size),
            'latestVersion': latest_update.version.version if latest_update else 'N/A',
            'withMD5': with_md5_count
        }
        
        # URLs para acciones
        urls = {
            'download': '/Launcher/updates/',
            'test': '/Launcher/updates/',
            'delete': url_for('admin.delete_update', update_id=0),
            'regenerateHash': url_for('admin.regenerate_hash', update_id=0),
            'validate': url_for('admin.validate_update', update_id=0),
        }
        
        return jsonify({
            'updates': updates_data,
            'pagination': {
                'page': updates_paginated.page,
                'pages': updates_paginated.pages,
                'perPage': updates_paginated.per_page,
                'total': updates_paginated.total,
                'hasNext': updates_paginated.has_next,
                'hasPrev': updates_paginated.has_prev
            },
            'stats': stats,
            'urls': urls
        })
        
    except Exception as e:
        current_app.logger.error(f"Error fetching updates data: {e}")
        return jsonify({'error': 'Error al cargar datos de actualizaciones', 'details': str(e)}), 500

# AGREGAR: Endpoint para regenerar hash
@admin_bp.route('/api/regenerate_hash/<int:update_id>', methods=['POST'])
@login_required
def regenerate_hash(update_id):
    """Regenerar hash MD5 de un paquete de actualización"""
    try:
        update = UpdatePackage.query.get_or_404(update_id)
        
        if not update.file_path or not os.path.exists(update.file_path):
            return jsonify({'error': 'Archivo no encontrado'}), 404
        
        # Calcular nuevo hash
        new_hash = calculate_md5(update.file_path)
        update.md5_hash = new_hash
        db.session.commit()
        
        # Notificar via SocketIO
        notify_admin(
            f'Hash MD5 regenerado para {update.filename}',
            'success',
            {
                'action': 'hash_regenerated',
                'filename': update.filename,
                'update_id': update.id,
                'new_hash': new_hash
            }
        )
        
        return jsonify({
            'success': True,
            'new_hash': new_hash,
            'message': f'Hash regenerado para {update.filename}'
        })
        
    except Exception as e:
        current_app.logger.error(f"Error regenerating hash: {e}")
        return jsonify({'error': 'Error al regenerar hash', 'details': str(e)}), 500

# AGREGAR: Endpoint para validar integridad
@admin_bp.route('/api/validate_update/<int:update_id>', methods=['POST'])
@login_required
def validate_update(update_id):
    """Validar integridad de un paquete de actualización"""
    try:
        update = UpdatePackage.query.get_or_404(update_id)
        
        if not update.file_path or not os.path.exists(update.file_path):
            return jsonify({'error': 'Archivo no encontrado'}), 404
        
        if not update.md5_hash:
            return jsonify({'error': 'No hay hash MD5 para comparar'}), 400
        
        # Calcular hash actual y comparar
        current_hash = calculate_md5(update.file_path)
        is_valid = current_hash == update.md5_hash
        
        return jsonify({
            'success': True,
            'is_valid': is_valid,
            'stored_hash': update.md5_hash,
            'current_hash': current_hash,
            'message': f'Archivo {"válido" if is_valid else "corrupto"}'
        })
        
    except Exception as e:
        current_app.logger.error(f"Error validating update: {e}")
        return jsonify({'error': 'Error al validar integridad', 'details': str(e)}), 500

@admin_bp.route('/launcher')
@login_required
def launcher_versions():
    """Gestión de versiones del launcher"""
    try:
        launchers = LauncherVersion.query.order_by(LauncherVersion.created_at.desc()).all()
        
        # Convertir a diccionarios y agregar datos adicionales
        launchers_data = []
        for launcher in launchers:
            launcher_dict = launcher.to_dict()
            
            # Agregar file_size calculado si existe el archivo
            if launcher.file_path and os.path.exists(launcher.file_path):
                file_size = os.path.getsize(launcher.file_path)
                launcher_dict['file_size'] = file_size
                launcher_dict['file_size_formatted'] = format_file_size(file_size)
            else:
                launcher_dict['file_size'] = None
                launcher_dict['file_size_formatted'] = None
            
            launchers_data.append(launcher_dict)
        
        return render_template('admin/launcher.html', launchers=launchers_data)
        
    except Exception as e:
        current_app.logger.error(f'Error loading launcher versions: {str(e)}')
        flash(f'Error al cargar versiones del launcher: {str(e)}', 'error')
        return render_template('admin/launcher.html', launchers=[])

# En admin_routes.py, REEMPLAZAR la función upload_launcher() con esta implementación completa:

@admin_bp.route('/launcher/upload', methods=['GET', 'POST'])
@login_required
def upload_launcher():
    """Subir nueva versión del launcher con opciones avanzadas"""
    if request.method == 'POST':
        try:
            # Obtener datos del formulario
            version = request.form.get('version', '').strip()
            launcher_file = request.files.get('launcher_file')
            release_notes = request.form.get('release_notes', '').strip()
            is_current = 'is_current' in request.form
            
            # Obtener opciones avanzadas
            replace_existing = 'replace_existing' in request.form
            create_backup = 'create_backup' in request.form
            update_json = 'update_json' in request.form
            notify_clients = 'notify_clients' in request.form
            
            current_app.logger.info(f"Upload launcher - Version: {version}, Options: replace={replace_existing}, backup={create_backup}, json={update_json}, notify={notify_clients}")
            
            # Validaciones básicas
            if not version or not launcher_file or not launcher_file.filename:
                flash('Versión y archivo son requeridos', 'error')
                return render_template('admin/upload_launcher.html')
            
            if not launcher_file.filename.lower().endswith('.exe'):
                flash('Solo se permiten archivos ejecutables (.exe)', 'error')
                return render_template('admin/upload_launcher.html')
            
            # Validar formato de versión
            if not validate_version_format(version):
                flash('Formato de versión inválido. Use formato: X.Y.Z.W', 'error')
                return render_template('admin/upload_launcher.html')
            
            # Verificar si ya existe esta versión
            existing_launcher = LauncherVersion.query.filter_by(version=version).first()
            if existing_launcher and not replace_existing:
                flash(f'La versión {version} ya existe. Active "Reemplazar si existe" para sobrescribirla.', 'error')
                return render_template('admin/upload_launcher.html')
            
            # 1. CREAR BACKUP DE VERSIÓN ACTUAL (si está habilitado)
            backup_path = None
            if create_backup:
                backup_path = create_launcher_backup()
                if backup_path:
                    current_app.logger.info(f"Backup creado en: {backup_path}")
                    flash(f'Backup creado: {os.path.basename(backup_path)}', 'info')
                else:
                    current_app.logger.warning("No se pudo crear backup")
            
            # 2. PREPARAR ARCHIVO
            filename = 'LC.exe'  # Nombre final estándar
            file_path = os.path.join('static/downloads', filename)
            
            # Crear directorio si no existe
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
            
            # Guardar archivo
            launcher_file.save(file_path)
            current_app.logger.info(f"Archivo guardado en: {file_path}")
            
            # 3. PROCESAR VERSIÓN EXISTENTE O CREAR NUEVA
            if existing_launcher and replace_existing:
                # Actualizar versión existente
                old_file_path = existing_launcher.file_path
                existing_launcher.filename = filename
                existing_launcher.file_path = file_path
                existing_launcher.release_notes = release_notes
                existing_launcher.created_at = datetime.utcnow()
                existing_launcher.created_by = current_user.id
                
                if is_current:
                    existing_launcher.set_as_current()
                
                # Eliminar archivo anterior si es diferente
                if old_file_path and old_file_path != file_path and os.path.exists(old_file_path):
                    try:
                        os.remove(old_file_path)
                        current_app.logger.info(f"Archivo anterior eliminado: {old_file_path}")
                    except Exception as e:
                        current_app.logger.warning(f"No se pudo eliminar archivo anterior: {e}")
                
                action_message = f'Versión {version} actualizada exitosamente'
                
            else:
                # Crear nueva versión
                launcher_version = LauncherVersion(
                    version=version,
                    filename=filename,
                    file_path=file_path,
                    release_notes=release_notes,
                    created_by=current_user.id
                )
                
                db.session.add(launcher_version)
                db.session.flush()  # Para obtener el ID
                
                if is_current:
                    launcher_version.set_as_current()
                
                action_message = f'Versión {version} creada exitosamente'
            
            # 5. NOTIFICAR A CLIENTES (si está habilitado)
            if notify_clients:
                notification_sent = send_launcher_notification(version, is_current)
                if notification_sent:
                    current_app.logger.info(f"Notificación enviada para versión {version}")
                    flash('Notificación enviada a clientes', 'success')
                else:
                    current_app.logger.warning("No se pudo enviar notificación")
                    flash('Error enviando notificación', 'warning')
            
            # Confirmar cambios en base de datos
            db.session.commit()
            
            flash(action_message, 'success')
            
            # Emitir evento SocketIO si está disponible
            try:
                notify_launcher_uploaded(version, is_current)
            except Exception as e:
                current_app.logger.warning(f"Error enviando notificación SocketIO: {e}")
            
            return redirect(url_for('admin.launcher_versions'))
            
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Error uploading launcher: {str(e)}', exc_info=True)
            flash(f'Error al subir launcher: {str(e)}', 'error')
    
    return render_template('admin/upload_launcher.html')

@admin_bp.route('/launcher/<int:launcher_id>/delete', methods=['POST'])
@login_required
def delete_launcher_api(launcher_id):
    """Eliminar versión del launcher - API para Vue.js"""
    try:
        launcher = LauncherVersion.query.get_or_404(launcher_id)
        
        # Verificar que no sea la versión actual
        if launcher.is_current:
            return jsonify({
                'success': False,
                'error': 'No se puede eliminar la versión actual del launcher'
            }), 400
        
        version = launcher.version
        filename = launcher.filename
        
        # Eliminar archivo físico
        if launcher.file_path and os.path.exists(launcher.file_path):
            try:
                os.remove(launcher.file_path)
                current_app.logger.info(f'Archivo físico eliminado: {launcher.file_path}')
            except Exception as e:
                current_app.logger.warning(f'No se pudo eliminar archivo físico: {e}')
        
        # Eliminar registro de la base de datos
        db.session.delete(launcher)
        db.session.commit()
        
        current_app.logger.info(f'Launcher {version} eliminado por usuario {current_user.username}')
        
        # Notificar via SocketIO si está disponible
        try:
            from socketio_utils import notify_admin
            notify_admin(
                f'Launcher versión {version} eliminado',
                'success',
                {
                    'action': 'launcher_deleted',
                    'version': version,
                    'filename': filename
                }
            )
        except ImportError:
            pass  # SocketIO no disponible
        
        return jsonify({
            'success': True,
            'message': f'Launcher versión {version} eliminado exitosamente',
            'deleted_launcher': {
                'id': launcher_id,
                'version': version,
                'filename': filename
            }
        })
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f'Error eliminando launcher {launcher_id}: {str(e)}')
        return jsonify({
            'success': False,
            'error': 'Error al eliminar launcher',
            'details': str(e)
        }), 500

@admin_bp.route('/launcher/cleanup', methods=['POST'])
@login_required  
def cleanup_old_launchers():
    """Eliminar todas las versiones archivadas del launcher - API para Vue.js"""
    try:
        # Obtener launchers archivados (no actuales)
        old_launchers = LauncherVersion.query.filter_by(is_current=False).all()
        
        if not old_launchers:
            return jsonify({
                'success': True,
                'message': 'No hay versiones archivadas para eliminar',
                'deleted_count': 0,
                'deleted_launchers': []
            })
        
        deleted_count = 0
        deleted_launchers = []
        errors = []
        
        for launcher in old_launchers:
            try:
                # Guardar info antes de eliminar
                launcher_info = {
                    'id': launcher.id,
                    'version': launcher.version,
                    'filename': launcher.filename
                }
                
                # Eliminar archivo físico
                if launcher.file_path and os.path.exists(launcher.file_path):
                    os.remove(launcher.file_path)
                
                # Eliminar registro
                db.session.delete(launcher)
                deleted_count += 1
                deleted_launchers.append(launcher_info)
                
            except Exception as e:
                errors.append(f'Error eliminando {launcher.version}: {str(e)}')
                current_app.logger.error(f'Error eliminando launcher {launcher.version}: {e}')
        
        db.session.commit()
        
        current_app.logger.info(f'{deleted_count} launchers archivados eliminados por usuario {current_user.username}')
        
        # Notificar via SocketIO si está disponible
        try:
            from socketio_utils import notify_admin
            notify_admin(
                f'{deleted_count} versiones archivadas eliminadas',
                'success',
                {
                    'action': 'launchers_cleaned',
                    'deleted_count': deleted_count,
                    'deleted_launchers': deleted_launchers
                }
            )
        except ImportError:
            pass  # SocketIO no disponible
        
        response_data = {
            'success': True,
            'message': f'{deleted_count} versiones archivadas eliminadas exitosamente',
            'deleted_count': deleted_count,
            'deleted_launchers': deleted_launchers
        }
        
        if errors:
            response_data['warnings'] = errors
        
        return jsonify(response_data)
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f'Error en cleanup_old_launchers: {str(e)}')
        return jsonify({
            'success': False,
            'error': 'Error al limpiar versiones archivadas',
            'details': str(e)
        }), 500

@admin_bp.route('/launcher/export_history')
@login_required
def export_launcher_history():
    """Exportar historial de versiones como CSV"""
    try:
        from datetime import datetime
        import csv
        from io import StringIO
        
        launchers = LauncherVersion.query.order_by(LauncherVersion.created_at.desc()).all()
        
        # Crear CSV
        output = StringIO()
        writer = csv.writer(output)
        
        # Headers
        writer.writerow([
            'Version', 'Filename', 'Status', 'File Size', 'Date', 'Created By', 'Release Notes'
        ])
        
        # Datos
        for launcher in launchers:
            file_size = 'N/A'
            if launcher.file_path and os.path.exists(launcher.file_path):
                try:
                    size_bytes = os.path.getsize(launcher.file_path)
                    file_size = format_file_size(size_bytes)
                except:
                    pass
            
            writer.writerow([
                launcher.version,
                launcher.filename,
                'Actual' if launcher.is_current else 'Archivada',
                file_size,
                launcher.created_at.strftime('%d/%m/%Y %H:%M:%S') if launcher.created_at else 'N/A',
                'Admin' if launcher.created_by else 'Sistema',
                launcher.release_notes or ''
            ])
        
        # Preparar respuesta
        from flask import make_response
        
        output.seek(0)
        response = make_response(output.getvalue())
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = f'attachment; filename=launcher_history_{datetime.now().strftime("%Y%m%d_%H%M")}.csv'
        
        current_app.logger.info(f'Historial de launchers exportado por usuario {current_user.username}')
        
        return response
        
    except Exception as e:
        current_app.logger.error(f'Error exportando historial de launchers: {e}')
        return jsonify({
            'error': 'Error al exportar historial',
            'details': str(e)
        }), 500


def create_launcher_backup():
    """Crear backup de la versión actual del launcher"""
    try:
        current_launcher = LauncherVersion.get_current()
        if not current_launcher or not current_launcher.file_path:
            current_app.logger.info("No hay versión actual para hacer backup")
            return None
        
        if not os.path.exists(current_launcher.file_path):
            current_app.logger.warning(f"Archivo actual no encontrado: {current_launcher.file_path}")
            return None
        
        # Crear directorio de backups
        backup_dir = os.path.join('static', 'backups', 'launcher')
        os.makedirs(backup_dir, exist_ok=True)
        
        # Generar nombre de backup con timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_filename = f"launcher_v{current_launcher.version}_{timestamp}.exe"
        backup_path = os.path.join(backup_dir, backup_filename)
        
        # Copiar archivo
        import shutil
        shutil.copy2(current_launcher.file_path, backup_path)
        
        current_app.logger.info(f"Backup creado: {backup_path}")
        return backup_path
        
    except Exception as e:
        current_app.logger.error(f"Error creando backup: {e}")
        return None


def send_launcher_notification(version, is_current):
    """Enviar notificación de nueva versión a clientes"""
    try:
        # Crear mensaje de notificación
        message_type = "Actualización" if is_current else "Nueva Versión"
        message_text = f"Nueva versión del launcher {version} disponible para descarga."
        
        if is_current:
            message_text += " Esta es ahora la versión oficial."
        
        # Crear mensaje en la base de datos
        news_message = NewsMessage(
            type=message_type,
            message=message_text,
            is_active=True,
            priority=5,  # Alta prioridad para actualizaciones de launcher
            created_by=current_user.id
        )
        
        db.session.add(news_message)
        db.session.commit()
        
        # Emitir notificación SocketIO si está disponible
        try:
            notify_message_created(message_type, True)
        except:
            pass
        
        current_app.logger.info(f"Notificación creada para launcher {version}")
        return True
        
    except Exception as e:
        current_app.logger.error(f"Error enviando notificación: {e}")
        return False

@admin_bp.route('/launcher/<int:launcher_id>/set_current')
@login_required
def set_current_launcher(launcher_id):
    """Establecer launcher como actual - VERSIÓN CORREGIDA"""
    try:
        launcher = LauncherVersion.query.get_or_404(launcher_id)
        old_current = LauncherVersion.get_current()
        
        # Guardar información antes de hacer cambios
        old_version = old_current.version if old_current else None
        new_version = launcher.version
        new_filename = launcher.filename
        
        # Hacer cambios en la base de datos
        launcher.set_as_current()
        
        # IMPORTANTE: Commit antes de notificar
        db.session.commit()
        
        # ✅ NUEVO: Notificar a launchers sobre nueva versión del launcher
        notify_launcher_update_available(new_version, new_filename, is_current=True)
        
        # Notificar via SocketIO admin
        try:
            from socketio_utils import notify_admin
            notify_admin(
                f'Launcher versión {new_version} establecido como actual',
                'success',
                {
                    'action': 'launcher_set_current',
                    'version': new_version,
                    'filename': new_filename,
                    'old_version': old_version
                }
            )
        except ImportError:
            pass
        
        flash(f'Launcher versión {new_version} establecido como actual', 'success')
        current_app.logger.info(f'Launcher {new_version} establecido como actual por usuario {current_user.username}')
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f'Error estableciendo launcher actual: {e}')
        flash(f'Error: {str(e)}', 'error')
    
    return redirect(url_for('admin.launcher_versions'))

@admin_bp.route('/messages')
@login_required
def messages():
    """Gestión de mensajes y noticias"""
    try:
        messages_query = NewsMessage.query.order_by(NewsMessage.priority.desc(), NewsMessage.created_at.desc()).all()
        
        # Convertir a diccionarios para evitar el error de JSON serialization
        messages_data = []
        for message in messages_query:
            messages_data.append({
                'id': message.id,
                'type': message.type,
                'message': message.message,
                'is_active': message.is_active,
                'priority': message.priority,
                'created_at': message.created_at.isoformat() if message.created_at else None,
                'created_by': message.created_by
            })
        
        return render_template('admin/messages.html', messages=messages_data)
    except Exception as e:
        flash(f'Error al cargar mensajes: {str(e)}', 'error')
        return render_template('admin/messages.html', messages=[])

@admin_bp.route('/messages/create', methods=['GET', 'POST'])
@login_required
def create_message():
    """Crear mensaje/noticia CON notificación SocketIO MEJORADA"""
    if request.method == 'POST':
        try:
            data = request.get_json() if request.is_json else request.form
            
            message_type = data.get('type', '').strip()
            message = data.get('message', '').strip()
            priority = int(data.get('priority', 5))
            is_active = data.get('is_active') in [True, 'true', 'True', '1', 'on'] if request.is_json else 'is_active' in request.form
            
            if not message_type or not message:
                error_msg = 'Tipo y mensaje son requeridos'
                if request.is_json:
                    return jsonify({'success': False, 'error': error_msg}), 400
                else:
                    flash(error_msg, 'error')
                    return render_template('admin/create_message.html')
            
            news_message = NewsMessage(
                type=message_type,
                message=message,
                priority=priority,
                is_active=is_active,
                created_by=current_user.id
            )
            
            db.session.add(news_message)
            db.session.commit()
            
            print(f"📝 NUEVO MENSAJE CREADO - ID: {news_message.id}, Activo: {is_active}")
            
            # ✅ NOTIFICAR A LAUNCHERS si está activo
            if is_active:
                try:
                    active_messages = NewsMessage.query.filter_by(is_active=True).order_by(
                        NewsMessage.priority.desc(), 
                        NewsMessage.created_at.desc()
                    ).all()
                    
                    print(f"📊 Total mensajes activos: {len(active_messages)}")
                    
                    # Notificar usando función específica
                    notify_news_updated(active_messages)
                    
                    # Envío directo de backup
                    try:
                        from app import socketio
                        
                        news_data = []
                        for msg in active_messages:
                            news_data.append({
                                'id': msg.id,
                                'type': msg.type,
                                'message': msg.message,
                                'priority': msg.priority,
                                'created_at': msg.created_at.isoformat() if msg.created_at else None
                            })
                        
                        socketio.emit('news_updated', {
                            'news': news_data,
                            'count': len(news_data),
                            'new_message_id': news_message.id,
                            'action': 'message_created'
                        }, namespace='/public')
                        
                        print(f"✅ Notificación de nuevo mensaje enviada: {len(news_data)} noticias totales")
                        
                    except Exception as e:
                        print(f"❌ Error en envío directo de nuevo mensaje: {e}")
                        
                except Exception as e:
                    print(f"❌ Error notificando nuevo mensaje: {e}")
            
            # Notificación SocketIO admin
            try:
                notify_message_created(message_type, is_active)
                broadcast_stats_update()
            except ImportError:
                print("⚠️ socketio_utils no disponible para admin")
            
            success_msg = 'Mensaje creado exitosamente'
            if request.is_json:
                return jsonify({
                    'success': True,
                    'message': success_msg,
                    'news_message': {
                        'id': news_message.id,
                        'type': message_type,
                        'message': message,
                        'priority': priority,
                        'is_active': is_active
                    }
                })
            else:
                flash(success_msg, 'success')
                return redirect(url_for('admin.messages'))
            
        except Exception as e:
            db.session.rollback()
            error_msg = f'Error al crear mensaje: {str(e)}'
            print(f"❌ {error_msg}")
            
            if request.is_json:
                return jsonify({'success': False, 'error': error_msg}), 500
            else:
                flash(error_msg, 'error')
    
    return render_template('admin/create_message.html')

@admin_bp.route('/messages/<int:message_id>/toggle', methods=['POST'])
@login_required
def toggle_message(message_id):
    """Activar/desactivar mensaje CON notificación SocketIO MEJORADA"""
    try:
        message = NewsMessage.query.get_or_404(message_id)
        old_status = message.is_active
        message.is_active = not message.is_active
        db.session.commit()
        
        status = "activado" if message.is_active else "desactivado"
        
        print(f"🔄 TOGGLE MESSAGE - ID: {message_id}, Nuevo estado: {message.is_active}")
        
        # ✅ CRÍTICO: Notificar a launchers sobre cambio en noticias
        try:
            active_messages = NewsMessage.query.filter_by(is_active=True).order_by(
                NewsMessage.priority.desc(), 
                NewsMessage.created_at.desc()
            ).all()
            
            print(f"📊 Mensajes activos después del toggle: {len(active_messages)}")
            
            # Método 1: Usar función específica de noticias
            notify_news_updated(active_messages)
            print("✅ notify_news_updated ejecutado")
            
            # Método 2: Enviar datos completos usando emit directo (BACKUP)
            try:
                from app import socketio
                
                # Formatear noticias para launchers
                news_data = []
                for msg in active_messages:
                    news_data.append({
                        'id': msg.id,
                        'type': msg.type,
                        'message': msg.message,
                        'priority': msg.priority,
                        'created_at': msg.created_at.isoformat() if msg.created_at else None
                    })
                
                # Emitir directamente a namespace público
                socketio.emit('news_updated', {
                    'news': news_data,
                    'count': len(news_data),
                    'updated_message_id': message_id,
                    'action': 'message_toggled'
                }, namespace='/public')
                
                print(f"✅ Evento directo enviado a /public: {len(news_data)} noticias")
                
                # También enviar como initial_data (que sabemos que funciona)
                socketio.emit('initial_data', {
                    'system_status': {
                        'status': 'online',
                        'latest_game_version': 'N/A',
                        'current_launcher_version': 'N/A',
                        'maintenance_mode': False
                    },
                    'news': news_data,
                    'stats': {
                        'players': 500,
                        'servers': '3/3',
                        'status': 'online'
                    },
                    'version': 'MESSAGE_UPDATE',
                    'source': 'message_toggle'
                }, namespace='/public')
                
                print(f"✅ Evento initial_data enviado como backup")
                
            except Exception as e:
                print(f"❌ Error en envío directo: {e}")
            
        except Exception as e:
            print(f"❌ Error notificando actualización de noticias: {e}")
            current_app.logger.error(f"Error notificando actualización de noticias: {e}")
        
        # Notificación SocketIO admin
        try:
            notify_admin(
                f'Mensaje {status}',
                'success',
                {
                    'action': 'message_toggled',
                    'message_id': message_id,
                    'is_active': message.is_active,
                    'type': message.type
                }
            )
            broadcast_stats_update()
        except ImportError:
            print("⚠️ socketio_utils no disponible")
        
        # Responder según el tipo de request
        if request.is_json or request.headers.get('Content-Type') == 'application/json':
            return jsonify({
                'success': True,
                'message': f'Mensaje {status} exitosamente',
                'is_active': message.is_active,
                'active_count': len(active_messages) if 'active_messages' in locals() else 0
            })
        else:
            flash(f'Mensaje {status} exitosamente', 'success')
            return redirect(url_for('admin.messages'))
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error en toggle_message: {e}")
        print(f"❌ Error en toggle_message: {e}")
        
        if request.is_json or request.headers.get('Content-Type') == 'application/json':
            return jsonify({'success': False, 'error': str(e)}), 500
        else:
            flash(f'Error: {str(e)}', 'error')
            return redirect(url_for('admin.messages'))

@admin_bp.route('/api/messages_data', methods=['GET'])
@login_required
def get_messages_data():
    """API para obtener todos los datos de mensajes con estadísticas."""
    try:
        # Obtener todos los mensajes
        messages = NewsMessage.query.order_by(
            NewsMessage.priority.desc(), 
            NewsMessage.created_at.desc()
        ).all()
        
        # Convertir a diccionarios
        messages_data = []
        for message in messages:
            message_dict = {
                'id': message.id,
                'type': message.type,
                'message': message.message,
                'is_active': message.is_active,
                'priority': message.priority,
                'created_at': message.created_at.isoformat() if message.created_at else None,
                'created_by': message.created_by
            }
            messages_data.append(message_dict)
        
        # Calcular estadísticas
        total_messages = len(messages)
        active_messages = len([m for m in messages if m.is_active])
        update_messages = len([m for m in messages if m.type == 'Actualización'])
        news_messages = len([m for m in messages if m.type == 'Noticia'])
        
        statistics = {
            'totalMessages': total_messages,
            'activeMessages': active_messages,
            'updateMessages': update_messages,
            'newsMessages': news_messages
        }
        
        # URLs para acciones
        urls = {
            'toggleStatus': url_for("admin.toggle_message", message_id=0),
            'deleteMessage': url_for("admin.delete_message", message_id=0),
            'deleteSelected': url_for("admin.delete_selected_messages"),
            'createMessage': url_for("admin.create_message")
        }
        
        return jsonify({
            'messages': messages_data,
            'statistics': statistics,
            'urls': urls
        })
        
    except Exception as e:
        current_app.logger.error(f"Error fetching messages data: {e}")
        return jsonify({
            'error': 'Error al cargar datos de mensajes', 
            'details': str(e)
        }), 500

@admin_bp.route('/api/message_statistics', methods=['GET'])
@login_required
def get_message_statistics():
    """API específica para estadísticas de mensajes."""
    try:
        # Estadísticas básicas
        total_messages = NewsMessage.query.count()
        active_messages = NewsMessage.query.filter_by(is_active=True).count()
        
        # Por tipo
        types_stats = db.session.query(
            NewsMessage.type, 
            db.func.count(NewsMessage.id).label('count')
        ).group_by(NewsMessage.type).all()
        
        # Por prioridad
        priority_stats = db.session.query(
            NewsMessage.priority, 
            db.func.count(NewsMessage.id).label('count')
        ).group_by(NewsMessage.priority).order_by(NewsMessage.priority.desc()).all()
        
        # Actividad reciente (últimos 7 días)
        from datetime import datetime, timedelta
        week_ago = datetime.utcnow() - timedelta(days=7)
        recent_messages = NewsMessage.query.filter(
            NewsMessage.created_at >= week_ago
        ).count()
        
        return jsonify({
            'totalMessages': total_messages,
            'activeMessages': active_messages,
            'inactiveMessages': total_messages - active_messages,
            'recentMessages': recent_messages,
            'typeStats': {type_stat[0]: type_stat[1] for type_stat in types_stats},
            'priorityStats': {str(priority_stat[0]): priority_stat[1] for priority_stat in priority_stats}
        })
        
    except Exception as e:
        current_app.logger.error(f"Error fetching message statistics: {e}")
        return jsonify({'error': 'Error al cargar estadísticas', 'details': str(e)}), 500

@admin_bp.route('/logs')
@login_required
def download_logs():
    """Ver logs de descarga con estadísticas corregidas"""
    page = request.args.get('page', 1, type=int)
    file_type = request.args.get('file_type', '')
    
    query = DownloadLog.query
    if file_type:
        query = query.filter_by(file_type=file_type)
    
    logs = query.order_by(DownloadLog.created_at.desc()).paginate(
        page=page, per_page=100, error_out=False
    )
    
    # ESTADÍSTICAS CORREGIDAS
    try:
        # Total de logs
        total_logs = DownloadLog.query.count()
        
        # Logs exitosos y fallidos
        successful_logs = DownloadLog.query.filter_by(success=True).count()
        failed_logs = DownloadLog.query.filter_by(success=False).count()
        
        # IPs únicas - CORREGIR PROBLEMA DE CONTEO
        unique_ips_query = db.session.query(DownloadLog.ip_address).distinct()
        unique_ips_count = unique_ips_query.count()
        
        # Tipos de archivo únicos para el filtro
        file_types_query = db.session.query(DownloadLog.file_type).distinct().filter(
            DownloadLog.file_type.isnot(None)
        ).all()
        file_types = [ft[0] for ft in file_types_query if ft[0]]
        
        # Estadísticas adicionales para la página
        stats = {
            'total_logs': total_logs,
            'successful_logs': successful_logs,
            'failed_logs': failed_logs,
            'unique_ips': unique_ips_count,
            'success_rate': round((successful_logs / total_logs * 100), 2) if total_logs > 0 else 0
        }
        
        current_app.logger.info(f"Estadísticas de logs calculadas: {stats}")
        
    except Exception as e:
        current_app.logger.error(f"Error calculando estadísticas de logs: {e}")
        stats = {
            'total_logs': 0,
            'successful_logs': 0,
            'failed_logs': 0,
            'unique_ips': 0,
            'success_rate': 0
        }
        file_types = []
    
    return render_template('admin/logs.html', logs=logs, file_types=file_types, current_file_type=file_type, stats=stats)

@admin_bp.route('/api/logs_data', methods=['GET'])
@login_required
def get_logs_data():
    """API para obtener los datos de los logs con paginación y filtros."""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 100, type=int)
        file_type = request.args.get('file_type', '')
        search = request.args.get('search', '')
        status = request.args.get('status', '')
        time_filter = request.args.get('time', '')
        ip_filter = request.args.get('ip', '')

        # Construir query base
        query = DownloadLog.query

        # Aplicar filtros
        if file_type:
            query = query.filter_by(file_type=file_type)
        
        if search:
            search_pattern = f"%{search}%"
            query = query.filter(
                db.or_(
                    DownloadLog.file_requested.ilike(search_pattern),
                    DownloadLog.ip_address.ilike(search_pattern)
                )
            )
        
        if status:
            if status == 'success':
                query = query.filter_by(success=True)
            elif status == 'failed':
                query = query.filter_by(success=False)
        
        if ip_filter:
            query = query.filter(DownloadLog.ip_address.ilike(f"%{ip_filter}%"))
        
        if time_filter:
            from datetime import datetime, timedelta
            now = datetime.utcnow()
            
            if time_filter == 'today':
                start_date = now.replace(hour=0, minute=0, second=0, microsecond=0)
                query = query.filter(DownloadLog.created_at >= start_date)
            elif time_filter == 'yesterday':
                yesterday = now - timedelta(days=1)
                start_date = yesterday.replace(hour=0, minute=0, second=0, microsecond=0)
                end_date = now.replace(hour=0, minute=0, second=0, microsecond=0)
                query = query.filter(
                    DownloadLog.created_at >= start_date,
                    DownloadLog.created_at < end_date
                )
            elif time_filter == 'week':
                start_date = now - timedelta(days=7)
                query = query.filter(DownloadLog.created_at >= start_date)
            elif time_filter == 'month':
                start_date = now - timedelta(days=30)
                query = query.filter(DownloadLog.created_at >= start_date)

        # Paginación
        logs_paginated = query.order_by(DownloadLog.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )

        # Convertir logs a diccionarios
        logs_data = []
        for log in logs_paginated.items:
            logs_data.append({
                'id': log.id,
                'ip_address': log.ip_address,
                'user_agent': log.user_agent,
                'file_requested': log.file_requested,
                'file_type': log.file_type,
                'success': log.success,
                'created_at': log.created_at.isoformat() if log.created_at else None
            })

        # Calcular estadísticas
        total_logs = DownloadLog.query.count()
        successful_logs = DownloadLog.query.filter_by(success=True).count()
        failed_logs = DownloadLog.query.filter_by(success=False).count()
        
        try:
            unique_ips_count = db.session.query(DownloadLog.ip_address).distinct().count()
        except Exception as e:
            current_app.logger.error(f"Error counting unique IPs: {e}")
            unique_ips_count = 0

        # Obtener tipos de archivo únicos
        file_types_query = db.session.query(DownloadLog.file_type).distinct().filter(
            DownloadLog.file_type.isnot(None)
        ).all()
        file_types = [ft[0] for ft in file_types_query if ft[0]]

        return jsonify({
            'logs': logs_data,
            'pagination': {
                'page': logs_paginated.page,
                'pages': logs_paginated.pages,
                'perPage': logs_paginated.per_page,
                'total': logs_paginated.total,
                'hasNext': logs_paginated.has_next,
                'hasPrev': logs_paginated.has_prev
            },
            'stats': {
                'totalLogs': total_logs,
                'successfulLogs': successful_logs,
                'failedLogs': failed_logs,
                'uniqueIps': unique_ips_count,
                'successRate': round((successful_logs / total_logs * 100), 2) if total_logs > 0 else 0
            },
            'file_types': file_types
        })

    except Exception as e:
        current_app.logger.error(f"Error fetching logs data: {e}")
        return jsonify({'error': 'Error al cargar datos de logs', 'details': str(e)}), 500

@admin_bp.route('/logs_stats')
@login_required
def logs_stats_enhanced():
    """API para estadísticas de logs en tiempo real"""
    try:
        from datetime import datetime, timedelta
        
        one_hour_ago = datetime.utcnow() - timedelta(hours=1)
        
        last_hour_downloads = DownloadLog.query.filter(
            DownloadLog.created_at >= one_hour_ago
        ).count()
        
        try:
            last_hour_unique_ips = db.session.query(DownloadLog.ip_address).distinct().filter(
                DownloadLog.created_at >= one_hour_ago
            ).count()
        except Exception as e:
            current_app.logger.error(f"Error counting unique IPs: {e}")
            last_hour_unique_ips = 0
        
        twenty_four_hours_ago = datetime.utcnow() - timedelta(hours=24)
        
        try:
            popular_files = db.session.query(
                DownloadLog.file_requested,
                db.func.count(DownloadLog.id).label('count')
            ).filter(
                DownloadLog.created_at >= twenty_four_hours_ago
            ).group_by(
                DownloadLog.file_requested
            ).order_by(
                db.func.count(DownloadLog.id).desc()
            ).limit(5).all()
        except Exception as e:
            current_app.logger.error(f"Error getting popular files: {e}")
            popular_files = []
        
        hourly_activity = []
        try:
            for i in range(24):
                hour_start = datetime.utcnow().replace(minute=0, second=0, microsecond=0) - timedelta(hours=i)
                hour_end = hour_start + timedelta(hours=1)
                
                count = DownloadLog.query.filter(
                    DownloadLog.created_at >= hour_start,
                    DownloadLog.created_at < hour_end
                ).count()
                
                hourly_activity.append({
                    'hour': hour_start.strftime('%H:00'),
                    'count': count
                })
        except Exception as e:
            current_app.logger.error(f"Error getting hourly activity: {e}")
            hourly_activity = []
        
        return jsonify({
            'last_hour_downloads': last_hour_downloads,
            'last_hour_unique_ips': last_hour_unique_ips,
            'popular_files': [{'file': f[0], 'count': f[1]} for f in popular_files],
            'hourly_activity': list(reversed(hourly_activity))
        })
        
    except Exception as e:
        current_app.logger.error(f"Error obteniendo estadísticas de logs: {e}")
        return jsonify({
            'error': str(e),
            'last_hour_downloads': 0,
            'last_hour_unique_ips': 0,
            'popular_files': [],
            'hourly_activity': []
        }), 500

# 2. NUEVA RUTA PARA LIMPIAR LOGS ANTIGUOS
@admin_bp.route('/logs/cleanup', methods=['POST'])
@login_required
def cleanup_old_logs():
    """Limpiar logs antiguos"""
    try:
        # Obtener parámetros
        days = request.form.get('days', 30, type=int)
        confirm = request.form.get('confirm', 'false')
        
        if confirm != 'true':
            flash('Debes confirmar la acción para eliminar logs antiguos', 'error')
            return redirect(url_for('admin.download_logs'))
        
        # Calcular fecha límite
        from datetime import datetime, timedelta
        cutoff_date = datetime.utcnow() - timedelta(days=days)
        
        # Contar logs que se van a eliminar
        logs_to_delete = DownloadLog.query.filter(
            DownloadLog.created_at < cutoff_date
        ).count()
        
        if logs_to_delete == 0:
            flash(f'No hay logs anteriores a {days} días para eliminar', 'info')
            return redirect(url_for('admin.download_logs'))
        
        # Eliminar logs antiguos
        deleted_count = DownloadLog.query.filter(
            DownloadLog.created_at < cutoff_date
        ).delete()
        
        db.session.commit()
        
        current_app.logger.info(f"Eliminados {deleted_count} logs antiguos por usuario {current_user.username}")
        flash(f'{deleted_count} logs antiguos eliminados exitosamente', 'success')
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error limpiando logs antiguos: {e}")
        flash(f'Error al limpiar logs: {str(e)}', 'error')
    
    return redirect(url_for('admin.download_logs'))

@admin_bp.route('/logs/export')
@login_required
def export_logs():
    """Exportar logs como CSV"""
    try:
        from datetime import datetime
        import csv
        from io import StringIO
        
        # Obtener parámetros de filtro
        file_type = request.args.get('file_type', '')
        days = request.args.get('days', 30, type=int)
        
        # Crear query
        query = DownloadLog.query
        
        if file_type:
            query = query.filter_by(file_type=file_type)
        
        if days > 0:
            from datetime import timedelta
            cutoff_date = datetime.utcnow() - timedelta(days=days)
            query = query.filter(DownloadLog.created_at >= cutoff_date)
        
        # Obtener logs
        logs = query.order_by(DownloadLog.created_at.desc()).all()
        
        # Crear CSV
        output = StringIO()
        writer = csv.writer(output)
        
        # Headers
        writer.writerow([
            'Fecha', 'Hora', 'IP', 'Archivo', 'Tipo', 'Estado', 'User Agent'
        ])
        
        # Datos
        for log in logs:
            writer.writerow([
                log.created_at.strftime('%Y-%m-%d'),
                log.created_at.strftime('%H:%M:%S'),
                log.ip_address,
                log.file_requested,
                log.file_type or 'N/A',
                'Exitoso' if log.success else 'Fallido',
                log.user_agent or 'N/A'
            ])
        
        # Preparar respuesta
        from flask import make_response
        
        output.seek(0)
        response = make_response(output.getvalue())
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = f'attachment; filename=logs_export_{datetime.now().strftime("%Y%m%d_%H%M")}.csv'
        
        current_app.logger.info(f"Logs exportados por usuario {current_user.username}")
        
        return response
        
    except Exception as e:
        current_app.logger.error(f"Error exportando logs: {e}")
        flash(f'Error al exportar logs: {str(e)}', 'error')
        return redirect(url_for('admin.download_logs'))

@admin_bp.route('/files/<int:file_id>/delete', methods=['POST'])
@login_required
def delete_file(file_id):
    """Eliminar archivo individual"""
    try:
        game_file = GameFile.query.get_or_404(file_id)
        filename = game_file.filename
        
        # Eliminar archivo físico
        file_path = os.path.join(current_app.config['UPLOAD_FOLDER'], 'files', game_file.filename)
        if os.path.exists(file_path):
            os.remove(file_path)
            current_app.logger.info(f'Archivo físico eliminado: {file_path}')
        else:
            current_app.logger.warning(f'Archivo físico no encontrado: {file_path}')
        
        # Eliminar registro de la base de datos
        db.session.delete(game_file)
        db.session.commit()
        
        current_app.logger.info(f'Archivo {filename} eliminado exitosamente por usuario {current_user.username}')
        flash(f'Archivo {filename} eliminado exitosamente', 'success')
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f'Error al eliminar archivo {file_id}: {str(e)}')
        flash(f'Error al eliminar archivo: {str(e)}', 'error')
    
    return redirect(url_for('admin.files'))

@admin_bp.route('/files/delete_selected', methods=['POST'])
@login_required
def delete_selected_files():
    """Eliminar archivos seleccionados"""
    try:
        file_ids = request.form.getlist('file_ids')
        if not file_ids:
            flash('No se seleccionaron archivos para eliminar', 'warning')
            return redirect(url_for('admin.files'))
        
        deleted_count = 0
        errors = []
        
        for file_id in file_ids:
            try:
                game_file = GameFile.query.get(file_id)
                if game_file:
                    filename = game_file.filename
                    
                    # Eliminar archivo físico
                    file_path = os.path.join(current_app.config['UPLOAD_FOLDER'], 'files', game_file.filename)
                    if os.path.exists(file_path):
                        os.remove(file_path)
                        current_app.logger.info(f'Archivo físico eliminado: {file_path}')
                    else:
                        current_app.logger.warning(f'Archivo físico no encontrado: {file_path}')
                    
                    # Eliminar registro de la base de datos
                    db.session.delete(game_file)
                    deleted_count += 1
                    current_app.logger.info(f'Archivo {filename} eliminado exitosamente')
                else:
                    errors.append(f'Archivo con ID {file_id} no encontrado')
            except Exception as e:
                errors.append(f'Error eliminando archivo ID {file_id}: {str(e)}')
                current_app.logger.error(f'Error eliminando archivo ID {file_id}: {str(e)}')
        
        db.session.commit()
        
        if deleted_count > 0:
            flash(f'{deleted_count} archivo(s) eliminado(s) exitosamente', 'success')
        
        if errors:
            for error in errors:
                flash(error, 'error')
                
        current_app.logger.info(f'{deleted_count} archivos eliminados por usuario {current_user.username}')
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f'Error general al eliminar archivos: {str(e)}')
        flash(f'Error al eliminar archivos: {str(e)}', 'error')
    
    return redirect(url_for('admin.files'))

@admin_bp.route('/updates/<int:update_id>/delete', methods=['POST'])
@login_required
def delete_update(update_id):
    """Eliminar paquete de actualización"""
    try:
        update_package = UpdatePackage.query.get_or_404(update_id)
        
        # Eliminar archivo físico
        if os.path.exists(update_package.file_path):
            os.remove(update_package.file_path)
        
        # Eliminar registro de la base de datos
        db.session.delete(update_package)
        db.session.commit()
        
        flash(f'Paquete de actualización {update_package.filename} eliminado exitosamente', 'success')
    except Exception as e:
        db.session.rollback()
        flash(f'Error al eliminar paquete: {str(e)}', 'error')
    
    return redirect(url_for('admin.updates'))

@admin_bp.route('/messages/<int:message_id>/delete', methods=['POST'])
@login_required
def delete_message(message_id):
    """Eliminar mensaje CON notificación SocketIO"""
    try:
        message = NewsMessage.query.get_or_404(message_id)
        message_type = message.type
        
        db.session.delete(message)
        db.session.commit()
        
        flash('Mensaje eliminado exitosamente', 'success')
        
        # Notificación SocketIO
        notify_admin(
            f'Mensaje "{message_type}" eliminado',
            'success',
            {
                'action': 'message_deleted',
                'message_id': message_id,
                'type': message_type
            }
        )
        
        # Actualizar estadísticas en tiempo real
        broadcast_stats_update()
        
    except Exception as e:
        db.session.rollback()
        flash(f'Error al eliminar mensaje: {str(e)}', 'error')
    
    return redirect(url_for('admin.messages'))

@admin_bp.route('/messages/delete_selected', methods=['POST'])
@login_required
def delete_selected_messages():
    """Eliminar mensajes seleccionados CON notificación SocketIO"""
    try:
        message_ids = request.form.getlist('message_ids')
        if not message_ids:
            flash('No se seleccionaron mensajes para eliminar', 'warning')
            return redirect(url_for('admin.messages'))
        
        deleted_count = 0
        for message_id in message_ids:
            message = NewsMessage.query.get(message_id)
            if message:
                db.session.delete(message)
                deleted_count += 1
        
        db.session.commit()
        flash(f'{deleted_count} mensaje(s) eliminado(s) exitosamente', 'success')
        
        # Notificación SocketIO
        notify_admin(
            f'{deleted_count} mensajes eliminados',
            'success',
            {
                'action': 'messages_deleted',
                'count': deleted_count
            }
        )
        
        # Actualizar estadísticas en tiempo real
        broadcast_stats_update()
        
    except Exception as e:
        db.session.rollback()
        flash(f'Error al eliminar mensajes: {str(e)}', 'error')
    
    return redirect(url_for('admin.messages'))

@admin_bp.route('/launcher/<int:launcher_id>/delete', methods=['POST'])
@login_required
def delete_launcher(launcher_id):
    """Eliminar versión del launcher"""
    try:
        launcher = LauncherVersion.query.get_or_404(launcher_id)
        
        # Verificar que no sea la versión actual
        if launcher.is_current:
            flash('No se puede eliminar la versión actual del launcher', 'error')
            return redirect(url_for('admin.launcher_versions'))
        
        # Eliminar archivo físico
        if os.path.exists(launcher.file_path):
            os.remove(launcher.file_path)
        
        # Eliminar registro de la base de datos
        db.session.delete(launcher)
        db.session.commit()
        
        flash(f'Launcher versión {launcher.version} eliminado exitosamente', 'success')
    except Exception as e:
        db.session.rollback()
        flash(f'Error al eliminar launcher: {str(e)}', 'error')
    
    return redirect(url_for('admin.launcher_versions'))

@admin_bp.route('/settings')
@login_required
def settings():
    """Configuración del servidor - redirigir a nueva página"""
    return redirect(url_for('admin.system_config'))

@admin_bp.route('/system/config')
@login_required
def system_config():
    """Página de configuración del sistema"""
    config = SystemConfig.get_config()
    return render_template('admin/system_config.html', config=config)

@admin_bp.route('/system/config/update', methods=['POST'])
@login_required
def update_system_config():
    """Actualizar configuración del sistema"""
    try:
        config = SystemConfig.get_config()
        data = request.get_json() if request.is_json else request.form.to_dict()

        # Guardar estado anterior del mantenimiento
        old_maintenance_mode = config.maintenance_mode
        old_maintenance_message = config.maintenance_message
        
        # Convertir strings a tipos correctos
        boolean_fields = [
            'maintenance_mode', 'debug_mode', 'auto_update_enabled', 'force_ssl',
            'rate_limiting_enabled', 'log_all_requests', 'notify_new_versions',
            'notify_system_errors', 'notify_high_traffic','proxy_enabled'
        ]
        
        for field in boolean_fields:
            if field in data:
                data[field] = data[field] in ['true', 'True', '1', 'on', True]
        
        integer_fields = [
            'update_check_interval', 'max_download_retries', 'connection_timeout',
            'session_duration_hours', 'max_login_attempts', 'download_rate_limit',
            'ip_ban_duration_minutes','proxy_port'
        ]
        
        for field in integer_fields:
            if field in data:
                try:
                    data[field] = int(data[field])
                except ValueError:
                    pass
        
        # Procesar IP whitelist
        if 'ip_whitelist' in data:
            if isinstance(data['ip_whitelist'], str):
                ip_list = [ip.strip() for ip in data['ip_whitelist'].split('\n') if ip.strip()]
                data['ip_whitelist'] = ip_list
        
        # Actualizar configuración
        config.update_from_dict(data)
        config.updated_by = current_user.id
        
        db.session.commit()
        
        # ✅ NUEVO: Notificar cambios importantes a launchers
        if 'maintenance_mode' in data and data['maintenance_mode'] != old_maintenance_mode:
            new_message = data.get('maintenance_message', old_maintenance_message)
            notify_maintenance_mode_changed(data['maintenance_mode'], new_message)
        
        # Notificar cambios del sistema
        try:
            latest_version = GameVersion.get_latest()
            launcher_version = LauncherVersion.get_current()
            
            system_status_data = {
                'status': 'maintenance' if config.maintenance_mode else 'online',
                'maintenance_mode': config.maintenance_mode,
                'maintenance_message': config.maintenance_message,
                'latest_game_version': latest_version.version if latest_version else 'N/A',
                'current_launcher_version': launcher_version.version if launcher_version else 'N/A',
                'auto_update_enabled': config.auto_update_enabled,
                'force_ssl': config.force_ssl,
            }
            
            notify_system_status_changed(system_status_data)
            
        except Exception as e:
            current_app.logger.error(f"Error notificando cambio de estado del sistema: {e}")
        
        # Notificar admin
        if data.get('maintenance_mode') and not old_maintenance_mode:
            notify_admin('Sistema puesto en modo mantenimiento', 'warning', {
                'action': 'maintenance_enabled',
                'message': data.get('maintenance_message', 'Modo mantenimiento activado')
            })
        elif 'maintenance_mode' in data and not data['maintenance_mode'] and old_maintenance_mode:
            notify_admin('Sistema salió del modo mantenimiento', 'success', {
                'action': 'maintenance_disabled'
            })
        
        #flash('Configuración actualizada exitosamente', 'success')
        
        if request.is_json:
            return jsonify({'success': True, 'message': 'Configuración actualizada'})
        else:
            return redirect(url_for('admin.system_config'))
            
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error updating system config: {e}")
        flash(f'Error al actualizar configuración: {str(e)}', 'error')
        
        if request.is_json:
            return jsonify({'success': False, 'error': str(e)}), 500
        else:
            return redirect(url_for('admin.system_config'))

@admin_bp.route('/system/status')
@login_required
def system_status():
    """Página de estado del sistema"""
    try:
        config = SystemConfig.get_config()
        status = SystemStatus.get_current()
        
        # Estadísticas adicionales
        from datetime import timedelta
        
        # Logs de las últimas 24 horas
        yesterday = datetime.utcnow() - timedelta(days=1)
        recent_logs = DownloadLog.query.filter(
            DownloadLog.created_at >= yesterday
        ).count()
        
        # Errores recientes
        recent_errors = DownloadLog.query.filter(
            DownloadLog.created_at >= yesterday,
            DownloadLog.success == False
        ).count()
        
        # IPs únicas
        unique_ips = db.session.query(DownloadLog.ip_address).distinct().filter(
            DownloadLog.created_at >= yesterday
        ).count()
        
        stats = {
            'recent_requests': recent_logs,
            'recent_errors': recent_errors,
            'unique_ips': unique_ips,
            'error_rate': round((recent_errors / recent_logs * 100), 2) if recent_logs > 0 else 0
        }
        
        return render_template('admin/system_status.html', 
                             config=config, 
                             status=status, 
                             stats=stats)
                             
    except Exception as e:
        current_app.logger.error(f"Error loading system status: {e}")
        flash(f'Error cargando estado del sistema: {str(e)}', 'error')
        return redirect(url_for('admin.dashboard'))

@admin_bp.route('/system/maintenance/toggle', methods=['POST'])
@login_required
def toggle_maintenance():
    """Activar/desactivar modo mantenimiento"""
    try:
        config = SystemConfig.get_config()
        data = request.get_json() or {}
        
        enabled = data.get('enabled', not config.maintenance_mode)
        message = data.get('message', 'Sistema en mantenimiento programado')
        
        config.maintenance_mode = enabled
        config.maintenance_message = message
        config.updated_by = current_user.id
        config.updated_at = datetime.utcnow()
        
        db.session.commit()
        
        status_text = "activado" if enabled else "desactivado"
        flash(f'Modo mantenimiento {status_text} exitosamente', 'success')
        
        # ✅ NUEVO: Notificar a launchers sobre cambio de mantenimiento
        notify_maintenance_mode_changed(enabled, message)
        
        notify_admin(
            f'Modo mantenimiento {status_text}',
            'warning' if enabled else 'success',
            {
                'action': 'maintenance_toggled',
                'enabled': enabled,
                'message': message
            }
        )
        
        return jsonify({
            'success': True,
            'maintenance_mode': enabled,
            'message': message
        })
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error toggling maintenance mode: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@admin_bp.route('/system/notifications')
@login_required
def notification_logs():
    """Ver logs de notificaciones"""
    try:
        page = request.args.get('page', 1, type=int)
        
        logs = NotificationLog.query.order_by(
            NotificationLog.created_at.desc()
        ).paginate(page=page, per_page=50, error_out=False)
        
        return render_template('admin/notification_logs.html', logs=logs)
        
    except Exception as e:
        current_app.logger.error(f"Error loading notification logs: {e}")
        flash(f'Error cargando logs de notificaciones: {str(e)}', 'error')
        return redirect(url_for('admin.dashboard'))

@admin_bp.route('/system/test_notification', methods=['POST'])
@login_required
def test_notification():
    """Enviar notificación de prueba"""
    try:
        data = request.get_json() or {}
        notification_type = data.get('type', 'test')
        
        # Crear notificación de prueba
        test_log = NotificationLog(
            notification_type=notification_type,
            title='Prueba de Notificación',
            message=f'Esta es una notificación de prueba enviada por {current_user.username}',
            recipient='test@example.com',
            status='sent',
            sent_at=datetime.utcnow()
        )
        
        db.session.add(test_log)
        db.session.commit()
        
        # Enviar notificación SocketIO
        notify_admin(
            'Notificación de prueba enviada',
            'info',
            {
                'action': 'test_notification',
                'type': notification_type,
                'user': current_user.username
            }
        )
        
        return jsonify({
            'success': True,
            'message': 'Notificación de prueba enviada exitosamente'
        })
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error sending test notification: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@admin_bp.route('/system/backup/create', methods=['POST'])
@login_required
def create_system_backup():
    """Crear backup del sistema"""
    try:
        from datetime import datetime
        import shutil
        import tempfile
        import zipfile
        
        # Crear directorio temporal para el backup
        with tempfile.TemporaryDirectory() as temp_dir:
            backup_name = f"system_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}.zip"
            backup_path = os.path.join('backups', backup_name)
            
            # Asegurar que existe el directorio de backups
            os.makedirs('backups', exist_ok=True)
            
            # Crear archivo ZIP con la configuración
            with zipfile.ZipFile(backup_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
                # Exportar configuración del sistema
                config = SystemConfig.get_config()
                config_data = config.to_dict()
                
                config_file = os.path.join(temp_dir, 'system_config.json')
                with open(config_file, 'w') as f:
                    json.dump(config_data, f, indent=2, default=str)
                
                zipf.write(config_file, 'system_config.json')
                
                # Exportar base de datos (SQLite si está configurado)
                db_path = current_app.config.get('SQLALCHEMY_DATABASE_URI')
                if db_path and db_path.startswith('sqlite:///'):
                    db_file = db_path.replace('sqlite:///', '')
                    if os.path.exists(db_file):
                        zipf.write(db_file, 'database.db')
        
        flash(f'Backup creado exitosamente: {backup_name}', 'success')
        
        return jsonify({
            'success': True,
            'backup_file': backup_name,
            'message': 'Backup creado exitosamente'
        })
        
    except Exception as e:
        current_app.logger.error(f"Error creating system backup: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@admin_bp.route('/system/ip_whitelist/add', methods=['POST'])
@login_required
def add_ip_to_whitelist():
    """Agregar IP a la lista blanca"""
    try:
        data = request.get_json() or {}
        ip_address = data.get('ip_address', '').strip()
        
        if not ip_address:
            return jsonify({'success': False, 'error': 'IP address is required'}), 400
        
        config = SystemConfig.get_config()
        
        # Obtener lista actual
        current_list = json.loads(config.ip_whitelist) if config.ip_whitelist else []
        
        # Agregar nueva IP si no existe
        if ip_address not in current_list:
            current_list.append(ip_address)
            config.ip_whitelist = json.dumps(current_list)
            config.updated_by = current_user.id
            config.updated_at = datetime.utcnow()
            
            db.session.commit()
            
            notify_admin(
                f'IP {ip_address} agregada a lista blanca',
                'info',
                {
                    'action': 'ip_whitelist_add',
                    'ip_address': ip_address,
                    'user': current_user.username
                }
            )
            
            return jsonify({
                'success': True,
                'message': f'IP {ip_address} agregada exitosamente',
                'whitelist': current_list
            })
        else:
            return jsonify({
                'success': False,
                'error': 'IP already in whitelist'
            }), 400
            
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error adding IP to whitelist: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@admin_bp.route('/system/ip_whitelist/remove', methods=['POST'])
@login_required
def remove_ip_from_whitelist():
    """Remover IP de la lista blanca"""
    try:
        data = request.get_json() or {}
        ip_address = data.get('ip_address', '').strip()
        
        if not ip_address:
            return jsonify({'success': False, 'error': 'IP address is required'}), 400
        
        config = SystemConfig.get_config()
        
        # Obtener lista actual
        current_list = json.loads(config.ip_whitelist) if config.ip_whitelist else []
        
        # Remover IP si existe
        if ip_address in current_list:
            current_list.remove(ip_address)
            config.ip_whitelist = json.dumps(current_list)
            config.updated_by = current_user.id
            config.updated_at = datetime.utcnow()
            
            db.session.commit()
            
            notify_admin(
                f'IP {ip_address} removida de lista blanca',
                'warning',
                {
                    'action': 'ip_whitelist_remove',
                    'ip_address': ip_address,
                    'user': current_user.username
                }
            )
            
            return jsonify({
                'success': True,
                'message': f'IP {ip_address} removida exitosamente',
                'whitelist': current_list
            })
        else:
            return jsonify({
                'success': False,
                'error': 'IP not found in whitelist'
            }), 400
            
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error removing IP from whitelist: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

# Actualizar la ruta de configuración existente


# ==================== RUTAS PARA GESTIÓN DE HWID ====================

@admin_bp.route('/hwid')
@login_required
def hwid_management():
    """Gestión de dispositivos y HWID - Solo renderiza la estructura HTML."""
    try:
        # La página se carga sin datos, Vue.js los pedirá vía API
        return render_template('admin/hwid.html')
    except Exception as e:
        flash(f'Error al cargar la página de HWID: {str(e)}', 'error')
        return render_template('admin/hwid.html')

# --- NUEVA RUTA API para los datos de HWID ---
@admin_bp.route('/api/hwid_data', methods=['GET'])
@login_required
def get_hwid_data():
    """API para obtener los datos de HWID con paginación y filtros."""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 50, type=int)
        search = request.args.get('search', '', type=str)
        status_filter = request.args.get('status', '', type=str)  # 'banned', 'allowed', ''
        
        query = launcher_ban.query
        
        # Filtro por búsqueda (HWID, serial, MAC, razón)
        if search:
            search_term = f"%{search}%"
            query = query.filter(
                db.or_(
                    launcher_ban.hwid.ilike(search_term),
                    launcher_ban.serial_number.ilike(search_term),
                    launcher_ban.mac_address.ilike(search_term),
                    launcher_ban.reason.ilike(search_term)
                )
            )
        
        # Filtro por estado
        if status_filter == 'banned':
            query = query.filter_by(is_banned=True)
        elif status_filter == 'allowed':
            query = query.filter_by(is_banned=False)
        
        devices_paginated = query.order_by(launcher_ban.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        devices_data = []
        for device in devices_paginated.items:
            device_dict = {
                'id': device.id,
                'hwid': device.hwid,
                'serial_number': device.serial_number,
                'mac_address': device.mac_address,
                'reason': device.reason,
                'is_banned': device.is_banned,
                'created_at': device.created_at.isoformat() if device.created_at else None,
                'status_text': 'Baneado' if device.is_banned else 'Permitido',
                'status_class': 'danger' if device.is_banned else 'success'
            }
            devices_data.append(device_dict)
        
        # URLs para acciones desde el cliente
        urls = {
            'banDevice': url_for("admin.ban_device", device_id=0),
            'unbanDevice': url_for("admin.unban_device", device_id=0),
            'deleteDevice': url_for("admin.delete_device", device_id=0),
            'addDevice': url_for("admin.add_device"),
            'bulkAction': url_for("admin.bulk_hwid_action")
        }
        
        # Estadísticas
        stats = {
            'totalDevices': launcher_ban.query.count(),
            'bannedDevices': launcher_ban.query.filter_by(is_banned=True).count(),
            'allowedDevices': launcher_ban.query.filter_by(is_banned=False).count(),
            'newDevices24h': launcher_ban.query.filter(
                launcher_ban.created_at >= datetime.utcnow() - timedelta(hours=24)
            ).count()
        }
        
        return jsonify({
            'devices': devices_data,
            'pagination': {
                'page': devices_paginated.page,
                'pages': devices_paginated.pages,
                'perPage': devices_paginated.per_page,
                'total': devices_paginated.total,
                'hasNext': devices_paginated.has_next,
                'hasPrev': devices_paginated.has_prev
            },
            'urls': urls,
            'stats': stats
        })
    except Exception as e:
        current_app.logger.error(f"Error fetching HWID data: {e}")
        return jsonify({'error': 'Error al cargar datos de dispositivos', 'details': str(e)}), 500

@admin_bp.route('/hwid/add', methods=['POST'])
@login_required
def add_device():
    """Agregar nuevo dispositivo manualmente"""
    try:
        data = request.get_json()
        hwid = data.get('hwid', '').strip()
        serial_number = data.get('serial_number', '').strip()
        mac_address = data.get('mac_address', '').strip()
        reason = data.get('reason', '').strip()
        is_banned = data.get('is_banned', False)
        
        # Validaciones
        if not hwid:
            return jsonify({'error': 'HWID es requerido'}), 400
        
        # Verificar si ya existe
        existing = launcher_ban.query.filter_by(hwid=hwid).first()
        if existing:
            return jsonify({'error': 'Este HWID ya existe en el sistema'}), 409
        
        # Crear nuevo dispositivo
        new_device = launcher_ban(
            hwid=hwid,
            serial_number=serial_number if serial_number else None,
            mac_address=mac_address if mac_address else None,
            reason=reason if reason else ('Agregado manualmente por administrador'),
            is_banned=is_banned,
            created_at=datetime.utcnow()
        )
        
        db.session.add(new_device)
        db.session.commit()
        
        # Notificación SocketIO
        notify_admin(
            f'Nuevo dispositivo agregado: {hwid[:12]}...',
            'success',
            {
                'action': 'device_added',
                'hwid': hwid,
                'is_banned': is_banned
            }
        )
        
        current_app.logger.info(f'Dispositivo {hwid} agregado por {current_user.username}')
        
        return jsonify({
            'success': True,
            'message': 'Dispositivo agregado exitosamente',
            'device': new_device.to_dict()
        })
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f'Error agregando dispositivo: {e}')
        return jsonify({'error': f'Error al agregar dispositivo: {str(e)}'}), 500

@admin_bp.route('/hwid/<int:device_id>/ban', methods=['POST'])
@login_required
def ban_device(device_id):
    """Banear dispositivo"""
    try:
        data = request.get_json()
        reason = data.get('reason', 'Baneado por administrador')
        
        device = launcher_ban.query.get_or_404(device_id)
        
        if device.is_banned:
            return jsonify({'error': 'El dispositivo ya está baneado'}), 400
        
        device.is_banned = True
        device.reason = reason
        db.session.commit()
        
        # Notificación SocketIO
        notify_admin(
            f'Dispositivo baneado: {device.hwid[:12]}...',
            'warning',
            {
                'action': 'device_banned',
                'hwid': device.hwid,
                'reason': reason
            }
        )
        
        current_app.logger.info(f'Dispositivo {device.hwid} baneado por {current_user.username}')
        
        return jsonify({
            'success': True,
            'message': 'Dispositivo baneado exitosamente'
        })
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f'Error baneando dispositivo: {e}')
        return jsonify({'error': f'Error al banear dispositivo: {str(e)}'}), 500

@admin_bp.route('/hwid/<int:device_id>/unban', methods=['POST'])
@login_required
def unban_device(device_id):
    """Desbanear dispositivo"""
    try:
        device = launcher_ban.query.get_or_404(device_id)
        
        if not device.is_banned:
            return jsonify({'error': 'El dispositivo no está baneado'}), 400
        
        device.is_banned = False
        device.reason = 'Desbaneado por administrador'
        db.session.commit()
        
        # Notificación SocketIO
        notify_admin(
            f'Dispositivo desbaneado: {device.hwid[:12]}...',
            'success',
            {
                'action': 'device_unbanned',
                'hwid': device.hwid
            }
        )
        
        current_app.logger.info(f'Dispositivo {device.hwid} desbaneado por {current_user.username}')
        
        return jsonify({
            'success': True,
            'message': 'Dispositivo desbaneado exitosamente'
        })
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f'Error desbaneando dispositivo: {e}')
        return jsonify({'error': f'Error al desbanear dispositivo: {str(e)}'}), 500

@admin_bp.route('/hwid/<int:device_id>/delete', methods=['POST'])
@login_required
def delete_device(device_id):
    """Eliminar dispositivo"""
    try:
        device = launcher_ban.query.get_or_404(device_id)
        hwid = device.hwid
        
        db.session.delete(device)
        db.session.commit()
        
        # Notificación SocketIO
        notify_admin(
            f'Dispositivo eliminado: {hwid[:12]}...',
            'info',
            {
                'action': 'device_deleted',
                'hwid': hwid
            }
        )
        
        current_app.logger.info(f'Dispositivo {hwid} eliminado por {current_user.username}')
        
        return jsonify({
            'success': True,
            'message': 'Dispositivo eliminado exitosamente'
        })
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f'Error eliminando dispositivo: {e}')
        return jsonify({'error': f'Error al eliminar dispositivo: {str(e)}'}), 500

@admin_bp.route('/hwid/bulk_action', methods=['POST'])
@login_required
def bulk_hwid_action():
    """Acciones en lote para dispositivos"""
    try:
        data = request.get_json()
        action = data.get('action')  # 'ban', 'unban', 'delete'
        device_ids = data.get('device_ids', [])
        reason = data.get('reason', 'Acción en lote por administrador')
        
        if not action or not device_ids:
            return jsonify({'error': 'Acción y dispositivos son requeridos'}), 400
        
        devices = launcher_ban.query.filter(launcher_ban.id.in_(device_ids)).all()
        if not devices:
            return jsonify({'error': 'No se encontraron dispositivos'}), 404
        
        affected_count = 0
        
        for device in devices:
            if action == 'ban' and not device.is_banned:
                device.is_banned = True
                device.reason = reason
                affected_count += 1
            elif action == 'unban' and device.is_banned:
                device.is_banned = False
                device.reason = 'Desbaneado en lote por administrador'
                affected_count += 1
            elif action == 'delete':
                db.session.delete(device)
                affected_count += 1
        
        db.session.commit()
        
        # Notificación SocketIO
        action_text = {
            'ban': 'baneados',
            'unban': 'desbaneados',
            'delete': 'eliminados'
        }
        
        notify_admin(
            f'{affected_count} dispositivos {action_text[action]}',
            'success' if action in ['unban', 'delete'] else 'warning',
            {
                'action': f'bulk_{action}',
                'count': affected_count
            }
        )
        
        current_app.logger.info(f'{affected_count} dispositivos {action_text[action]} por {current_user.username}')
        
        return jsonify({
            'success': True,
            'message': f'{affected_count} dispositivos {action_text[action]} exitosamente',
            'affected_count': affected_count
        })
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f'Error en acción en lote: {e}')
        return jsonify({'error': f'Error en acción en lote: {str(e)}'}), 500

@admin_bp.route('/hwid/export')
@login_required
def export_hwid():
    """Exportar lista de dispositivos como CSV"""
    try:
        from datetime import datetime
        import csv
        from io import StringIO
        
        # Obtener parámetros de filtro
        status_filter = request.args.get('status', '')
        
        # Crear query
        query = launcher_ban.query
        
        if status_filter == 'banned':
            query = query.filter_by(is_banned=True)
        elif status_filter == 'allowed':
            query = query.filter_by(is_banned=False)
        
        # Obtener dispositivos
        devices = query.order_by(launcher_ban.created_at.desc()).all()
        
        # Crear CSV
        output = StringIO()
        writer = csv.writer(output)
        
        # Headers
        writer.writerow([
            'ID', 'HWID', 'Serial Number', 'MAC Address', 'Estado', 'Razón', 'Fecha Registro'
        ])
        
        # Datos
        for device in devices:
            writer.writerow([
                device.id,
                device.hwid,
                device.serial_number or 'N/A',
                device.mac_address or 'N/A',
                'Baneado' if device.is_banned else 'Permitido',
                device.reason or 'N/A',
                device.created_at.strftime('%Y-%m-%d %H:%M:%S') if device.created_at else 'N/A'
            ])
        
        # Preparar respuesta
        from flask import make_response
        
        output.seek(0)
        response = make_response(output.getvalue())
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = f'attachment; filename=hwid_export_{datetime.now().strftime("%Y%m%d_%H%M")}.csv'
        
        current_app.logger.info(f'HWID exportado por usuario {current_user.username}')
        
        return response
        
    except Exception as e:
        current_app.logger.error(f"Error exportando HWID: {e}")
        flash(f'Error al exportar dispositivos: {str(e)}', 'error')
        return redirect(url_for('admin.hwid_management'))

@admin_bp.route('/hwid/stats')
@login_required
def hwid_stats():
    """API para estadísticas de HWID en tiempo real"""
    try:
        from datetime import datetime, timedelta
        
        # Estadísticas generales
        total_devices = launcher_ban.query.count()
        banned_devices = launcher_ban.query.filter_by(is_banned=True).count()
        allowed_devices = launcher_ban.query.filter_by(is_banned=False).count()
        
        # Dispositivos nuevos en las últimas 24 horas
        twenty_four_hours_ago = datetime.utcnow() - timedelta(hours=24)
        new_devices_24h = launcher_ban.query.filter(
            launcher_ban.created_at >= twenty_four_hours_ago
        ).count()
        
        # Actividad por día (últimos 7 días)
        daily_activity = []
        for i in range(7):
            day = datetime.utcnow() - timedelta(days=i)
            day_start = day.replace(hour=0, minute=0, second=0, microsecond=0)
            day_end = day_start + timedelta(days=1)
            
            new_count = launcher_ban.query.filter(
                launcher_ban.created_at >= day_start,
                launcher_ban.created_at < day_end
            ).count()
            
            daily_activity.append({
                'date': day_start.strftime('%Y-%m-%d'),
                'count': new_count
            })
        
        return jsonify({
            'total_devices': total_devices,
            'banned_devices': banned_devices,
            'allowed_devices': allowed_devices,
            'new_devices_24h': new_devices_24h,
            'ban_rate': round((banned_devices / total_devices * 100), 1) if total_devices > 0 else 0,
            'daily_activity': list(reversed(daily_activity))
        })
        
    except Exception as e:
        current_app.logger.error(f"Error obteniendo estadísticas de HWID: {e}")
        return jsonify({'error': str(e)}), 500

def emit_initial_system_state():
    """Emitir estado inicial del sistema a todos los launchers conectados"""
    try:
        from models import GameVersion, LauncherVersion, NewsMessage, SystemConfig
        
        config = SystemConfig.get_config()
        latest_version = GameVersion.get_latest()
        launcher_version = LauncherVersion.get_current()
        active_messages = NewsMessage.query.filter_by(is_active=True).all()
        
        # Datos del sistema
        system_status_data = {
            'status': 'maintenance' if config.maintenance_mode else 'online',
            'maintenance_mode': config.maintenance_mode,
            'maintenance_message': config.maintenance_message,
            'latest_game_version': latest_version.version if latest_version else 'N/A',
            'current_launcher_version': launcher_version.version if launcher_version else 'N/A',
            'auto_update_enabled': config.auto_update_enabled,
            'force_ssl': config.force_ssl
        }
        
        # Emitir eventos
        notify_system_status_changed(system_status_data)
        
        if config.maintenance_mode:
            notify_maintenance_mode_changed(True, config.maintenance_message)
        
        if active_messages:
            notify_news_updated(active_messages)
        
        current_app.logger.info("Estado inicial del sistema emitido a launchers")
        
    except Exception as e:
        current_app.logger.error(f"Error emitiendo estado inicial: {e}")
        
@admin_bp.route('/test/socketio_public')
@login_required
def test_socketio_public():
    """Página de testing para SocketIO público"""
    return render_template('admin/test_socketio_public.html')

@admin_bp.route('/api/test/notify_public', methods=['POST'])
@login_required
def api_test_notify_public():
    """API para probar notificaciones públicas desde el admin panel"""
    try:
        data = request.get_json() or {}
        test_type = data.get('type', 'all')
        
        print(f"🧪 Admin API Test iniciado - Type: {test_type}")
        
        results = {}
        
        # ✅ USAR LAS FUNCIONES CORREGIDAS DE public_socketio_utils
        from public_socketio_utils import (
            test_public_socketio, 
            notify_news_updated, 
            notify_maintenance_mode_changed,
            notify_new_game_version_available,
            debug_socketio_state,
            safe_execute_with_context
        )
        
        # 1. Debug del estado
        results['debug_info'] = debug_socketio_state()
        
        # 2. Test básico de SocketIO
        if test_type in ['all', 'socketio']:
            print("🧪 Probando SocketIO básico...")
            results['socketio_test'] = safe_execute_with_context(test_public_socketio)
        
        # 3. Test de noticias
        if test_type in ['all', 'news']:
            print("🧪 Probando notificaciones de noticias...")
            try:
                # Usar noticias reales de la BD
                active_messages = NewsMessage.query.filter_by(is_active=True).order_by(
                    NewsMessage.priority.desc()
                ).limit(3).all()
                
                if active_messages:
                    results['news_test'] = safe_execute_with_context(notify_news_updated, active_messages)
                    results['news_count'] = len(active_messages)
                else:
                    # Crear noticias fake para testing
                    fake_news = []
                    fake_message = type('obj', (object,), {
                        'id': 9999,
                        'type': 'Test Admin',
                        'message': f'Prueba de notificación desde admin panel - {datetime.now().strftime("%H:%M:%S")}',
                        'priority': 8,
                        'is_active': True,
                        'created_at': datetime.now()
                    })
                    fake_news.append(fake_message)
                    
                    results['news_test'] = safe_execute_with_context(notify_news_updated, fake_news)
                    results['news_count'] = 1
                    
            except Exception as e:
                results['news_test'] = False
                results['news_error'] = str(e)
        
        # 4. Test de mantenimiento
        if test_type in ['all', 'maintenance']:
            print("🧪 Probando notificaciones de mantenimiento...")
            # ✅ NUEVO: Probar AMBOS casos
            # Caso 1: Test de mantenimiento (enabled=false con mensaje)
            test_result_1 = safe_execute_with_context(
                notify_maintenance_mode_changed, 
                False,  # enabled=False (es un test)
                f"🧪 TEST de mantenimiento desde admin panel - {datetime.now().strftime('%H:%M:%S')}"
            )
            
            test_result_2 = safe_execute_with_context(
                notify_maintenance_mode_changed, 
                True,  # enabled=True (mantenimiento real simulado)
                f"🔧 SIMULACIÓN de mantenimiento real - {datetime.now().strftime('%H:%M:%S')}"
            )
            
            # Caso 3: Desactivar mantenimiento
            test_result_3 = safe_execute_with_context(
                notify_maintenance_mode_changed, 
                False,  # enabled=False (desactivar)
                ""  # Sin mensaje = desactivación real
            )
            
            results['maintenance_test'] = {
                'test_notification': test_result_1,
                'real_maintenance': test_result_2, 
                'deactivate_maintenance': test_result_3,
                'all_success': test_result_1 and test_result_2 and test_result_3
            }
        
        # 5. Test de nueva versión
        if test_type in ['all', 'version']:
            print("🧪 Probando notificaciones de nueva versión...")
            results['version_test'] = safe_execute_with_context(
                notify_new_game_version_available, 
                f"TEST.{datetime.utcnow().strftime('%H%M%S')}", 
                True
            )
        
        # 6. Emitir evento directo adicional
        if test_type in ['all', 'direct']:
            print("🧪 Probando emisión directa...")
            try:
                from public_socketio_utils import emit_to_public
                direct_data = {
                    'test_type': 'direct_emission',
                    'message': 'Emisión directa desde admin panel',
                    'timestamp': datetime.utcnow().isoformat(),
                    'admin_user': current_user.username
                }
                results['direct_test'] = safe_execute_with_context(emit_to_public, 'admin_direct_test', direct_data)
            except Exception as e:
                results['direct_test'] = False
                results['direct_error'] = str(e)
        
        # Notificar admin sobre la prueba
        try:
            from socketio_utils import notify_admin
            notify_admin(
                f'Prueba de SocketIO público ejecutada por {current_user.username}',
                'info',
                {
                    'action': 'socketio_public_test',
                    'test_type': test_type,
                    'results': results,
                    'user': current_user.username
                }
            )
        except ImportError:
            pass
        
        return jsonify({
            'success': True,
            'message': f'Prueba de SocketIO público completada (tipo: {test_type})',
            'test_type': test_type,
            'results': results,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        current_app.logger.error(f"Error en test SocketIO público: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 500

@admin_bp.route('/api/test/force_news_update', methods=['POST'])
@login_required
def api_force_news_update():
    """Forzar actualización de noticias para testing"""
    try:
        print("🔄 FORCE_NEWS_UPDATE iniciado desde admin...")
        
        # Obtener todas las noticias activas
        active_messages = NewsMessage.query.filter_by(is_active=True).order_by(
            NewsMessage.priority.desc(), 
            NewsMessage.created_at.desc()
        ).all()
        
        print(f"📊 Encontradas {len(active_messages)} noticias activas")
        
        # Usar la función corregida
        from public_socketio_utils import notify_news_updated, safe_execute_with_context
        
        success = safe_execute_with_context(notify_news_updated, active_messages)
        
        # También emitir evento de estadísticas actualizadas
        try:
            from public_socketio_utils import emit_to_public
            stats_data = {
                'active_messages': len(active_messages),
                'last_update': datetime.utcnow().isoformat(),
                'source': 'admin_force_update'
            }
            safe_execute_with_context(emit_to_public, 'stats_update', stats_data)
        except Exception as stats_error:
            print(f"⚠️ Error enviando stats: {stats_error}")
        
        return jsonify({
            'success': success,
            'message': f'Actualización de noticias {"exitosa" if success else "falló"}',
            'news_count': len(active_messages),
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        current_app.logger.error(f"Error en force_news_update: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 500

@admin_bp.route('/api/test/debug_socketio', methods=['GET'])
@login_required
def api_debug_socketio():
    """Obtener información de debug sobre SocketIO"""
    try:
        from public_socketio_utils import debug_socketio_state
        from flask import has_app_context
        
        debug_info = {
            'flask_context': has_app_context(),
            'current_time': datetime.utcnow().isoformat(),
            'admin_user': current_user.username,
            'request_endpoint': request.endpoint,
            'request_method': request.method
        }
        
        # Obtener info de SocketIO
        socketio_info = debug_socketio_state()
        debug_info.update(socketio_info)
        
        # Información adicional
        try:
            import os
            debug_info['process_id'] = os.getpid()
            debug_info['thread_name'] = current_app.config.get('TESTING', False)
        except:
            pass
        
        return jsonify({
            'success': True,
            'debug_info': debug_info,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 500

# ==================== TEMPLATE HELPER PARA TESTING ====================
# ==================== RUTAS PARA GESTIÓN DE BANNERS ====================

@admin_bp.route('/banners')
@login_required
def banner_management():
    """Gestión de banners - Renderiza la página principal"""
    try:
        return render_template('admin/banners.html')
    except Exception as e:
        flash(f'Error al cargar la página de banners: {str(e)}', 'error')
        return render_template('admin/banners.html')

@admin_bp.route('/api/banners_data', methods=['GET'])
@login_required
def get_banners_data():
    """API para obtener todos los datos de banners"""
    try:
        banners = BannerConfig.query.order_by(BannerConfig.created_at.desc()).all()
        
        banners_data = []
        for banner in banners:
            banner_dict = banner.to_dict()
            
            # Agregar slides
            slides = BannerSlide.query.filter_by(banner_id=banner.id).order_by(BannerSlide.order_index).all()
            banner_dict['slides'] = [slide.to_dict() for slide in slides]
            banner_dict['slides_count'] = len(slides)
            
            banners_data.append(banner_dict)
        
        # Estadísticas
        total_banners = len(banners)
        active_banners = len([b for b in banners if b.is_active])
        total_slides = BannerSlide.query.count()
        
        return jsonify({
            'banners': banners_data,
            'stats': {
                'totalBanners': total_banners,
                'activeBanners': active_banners,
                'totalSlides': total_slides
            }
        })
        
    except Exception as e:
        current_app.logger.error(f"Error fetching banners data: {e}")
        return jsonify({'error': 'Error al cargar datos de banners', 'details': str(e)}), 500

@admin_bp.route('/banners/create', methods=['GET', 'POST'])
@login_required
def create_banner():
    """Crear nuevo banner"""
    if request.method == 'POST':
        try:
            data = request.get_json() if request.is_json else request.form
            
            name = data.get('name', '').strip()
            description = data.get('description', '').strip()
            
            if not name:
                error_msg = 'El nombre del banner es requerido'
                if request.is_json:
                    return jsonify({'success': False, 'error': error_msg}), 400
                else:
                    flash(error_msg, 'error')
                    return render_template('admin/create_banner.html')
            
            # Verificar si ya existe
            existing = BannerConfig.query.filter_by(name=name).first()
            if existing:
                error_msg = 'Ya existe un banner con ese nombre'
                if request.is_json:
                    return jsonify({'success': False, 'error': error_msg}), 409
                else:
                    flash(error_msg, 'error')
                    return render_template('admin/create_banner.html')
            
            # Crear banner
            banner = BannerConfig(
                name=name,
                description=description,
                auto_rotate=data.get('auto_rotate', True),
                rotation_interval=int(data.get('rotation_interval', 6000)),
                responsive=data.get('responsive', True),
                show_controller=data.get('show_controller', True),
                width=int(data.get('width', 775)),
                height=int(data.get('height', 394)),
                enable_socketio=data.get('enable_socketio', True),
                enable_real_time=data.get('enable_real_time', True),
                created_by=current_user.id
            )
            
            db.session.add(banner)
            db.session.commit()
            
            # Notificar via SocketIO
            try:
                from socketio_utils import notify_admin
                notify_admin(
                    f'Nuevo banner creado: {name}',
                    'success',
                    {
                        'action': 'banner_created',
                        'banner_id': banner.id,
                        'name': name
                    }
                )
            except ImportError:
                pass
            
            success_msg = f'Banner "{name}" creado exitosamente'
            if request.is_json:
                return jsonify({
                    'success': True,
                    'message': success_msg,
                    'banner': banner.to_dict()
                })
            else:
                flash(success_msg, 'success')
                return redirect(url_for('admin.banner_management'))
                
        except Exception as e:
            db.session.rollback()
            error_msg = f'Error al crear banner: {str(e)}'
            current_app.logger.error(error_msg)
            
            if request.is_json:
                return jsonify({'success': False, 'error': error_msg}), 500
            else:
                flash(error_msg, 'error')
    
    return render_template('admin/create_banner.html')

@admin_bp.route('/banners/<int:banner_id>/set_active', methods=['POST'])
@login_required
def set_active_banner(banner_id):
    """Establecer banner como activo"""
    try:
        banner = BannerConfig.query.get_or_404(banner_id)
        old_active = BannerConfig.get_active()
        
        banner.set_as_active()
        
        # Notificar cambio a launchers
        try:
            from public_socketio_utils import emit_to_public
            emit_to_public('banner_changed', {
                'banner_id': banner.id,
                'name': banner.name,
                'config': banner.to_dict()
            })
        except ImportError:
            pass
        
        # Notificar admin
        try:
            from socketio_utils import notify_admin
            notify_admin(
                f'Banner "{banner.name}" establecido como activo',
                'success',
                {
                    'action': 'banner_set_active',
                    'banner_id': banner.id,
                    'name': banner.name,
                    'old_active': old_active.name if old_active else None
                }
            )
        except ImportError:
            pass
        
        if request.is_json:
            return jsonify({
                'success': True,
                'message': f'Banner "{banner.name}" establecido como activo',
                'banner': banner.to_dict()
            })
        else:
            flash(f'Banner "{banner.name}" establecido como activo', 'success')
            return redirect(url_for('admin.banner_management'))
            
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error setting active banner: {e}")
        
        if request.is_json:
            return jsonify({'success': False, 'error': str(e)}), 500
        else:
            flash(f'Error: {str(e)}', 'error')
            return redirect(url_for('admin.banner_management'))

@admin_bp.route('/banners/<int:banner_id>/delete', methods=['POST'])
@login_required
def delete_banner(banner_id):
    """Eliminar banner"""
    try:
        banner = BannerConfig.query.get_or_404(banner_id)
        
        if banner.is_active:
            error_msg = 'No se puede eliminar el banner activo'
            if request.is_json:
                return jsonify({'success': False, 'error': error_msg}), 400
            else:
                flash(error_msg, 'error')
                return redirect(url_for('admin.banner_management'))
        
        banner_name = banner.name
        
        # Eliminar slides asociados
        BannerSlide.query.filter_by(banner_id=banner.id).delete()
        
        # Eliminar banner
        db.session.delete(banner)
        db.session.commit()
        
        # Notificar via SocketIO
        try:
            from socketio_utils import notify_admin
            notify_admin(
                f'Banner "{banner_name}" eliminado',
                'success',
                {
                    'action': 'banner_deleted',
                    'banner_id': banner_id,
                    'name': banner_name
                }
            )
        except ImportError:
            pass
        
        success_msg = f'Banner "{banner_name}" eliminado exitosamente'
        if request.is_json:
            return jsonify({'success': True, 'message': success_msg})
        else:
            flash(success_msg, 'success')
            return redirect(url_for('admin.banner_management'))
            
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error deleting banner: {e}")
        
        if request.is_json:
            return jsonify({'success': False, 'error': str(e)}), 500
        else:
            flash(f'Error: {str(e)}', 'error')
            return redirect(url_for('admin.banner_management'))

# ==================== RUTAS PARA SLIDES ====================

@admin_bp.route('/banners/<int:banner_id>/slides', methods=['GET'])
@login_required
def get_banner_slides(banner_id):
    """Obtener slides de un banner"""
    try:
        banner = BannerConfig.query.get_or_404(banner_id)
        slides = BannerSlide.query.filter_by(banner_id=banner_id).order_by(BannerSlide.order_index).all()
        
        return jsonify({
            'banner': banner.to_dict(),
            'slides': [slide.to_dict() for slide in slides]
        })
        
    except Exception as e:
        current_app.logger.error(f"Error fetching banner slides: {e}")
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/banners/<int:banner_id>/slides/add', methods=['POST'])
@login_required
def add_banner_slide(banner_id):
    """Agregar slide a un banner"""
    try:
        banner = BannerConfig.query.get_or_404(banner_id)
        data = request.get_json() if request.is_json else request.form
        
        title = data.get('title', '').strip()
        content = data.get('content', '').strip()
        image_url = data.get('image_url', '').strip()
        link_url = data.get('link_url', '').strip()
        
        if not title:
            return jsonify({'success': False, 'error': 'El título es requerido'}), 400
        
        # Obtener próximo order_index
        max_order = db.session.query(db.func.max(BannerSlide.order_index)).filter_by(banner_id=banner_id).scalar() or 0
        
        slide = BannerSlide(
            banner_id=banner_id,
            title=title,
            content=content,
            image_url=image_url,
            link_url=link_url,
            order_index=max_order + 1,
            duration=int(data.get('duration', 6000))
        )
        
        db.session.add(slide)
        db.session.commit()
        
        # Notificar si es el banner activo
        if banner.is_active:
            try:
                from public_socketio_utils import emit_to_public
                emit_to_public('banner_slides_updated', {
                    'banner_id': banner.id,
                    'slides_count': len(banner.slides)
                })
            except ImportError:
                pass
        
        return jsonify({
            'success': True,
            'message': f'Slide "{title}" agregado exitosamente',
            'slide': slide.to_dict()
        })
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error adding slide: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@admin_bp.route('/slides/<int:slide_id>/delete', methods=['POST'])
@login_required
def delete_slide(slide_id):
    """Eliminar slide"""
    try:
        slide = BannerSlide.query.get_or_404(slide_id)
        banner = slide.banner
        slide_title = slide.title
        
        db.session.delete(slide)
        db.session.commit()
        
        # Notificar si es el banner activo
        if banner.is_active:
            try:
                from public_socketio_utils import emit_to_public
                emit_to_public('banner_slides_updated', {
                    'banner_id': banner.id,
                    'slides_count': len(banner.slides)
                })
            except ImportError:
                pass
        
        return jsonify({
            'success': True,
            'message': f'Slide "{slide_title}" eliminado exitosamente'
        })
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error deleting slide: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

# ==================== API PÚBLICA PARA LAUNCHER ====================
@admin_bp.route('/banners/<int:banner_id>/update', methods=['POST'])
@login_required
def update_banner(banner_id):
    """Actualizar banner existente"""
    try:
        banner = BannerConfig.query.get_or_404(banner_id)
        data = request.get_json() if request.is_json else request.form
        
        # Validar datos
        name = data.get('name', '').strip()
        description = data.get('description', '').strip()
        
        if not name:
            error_msg = 'El nombre del banner es requerido'
            if request.is_json:
                return jsonify({'success': False, 'error': error_msg}), 400
            else:
                flash(error_msg, 'error')
                return redirect(url_for('admin.banner_management'))
        
        # Verificar nombre único (excepto el actual)
        existing = BannerConfig.query.filter(
            BannerConfig.name == name,
            BannerConfig.id != banner_id
        ).first()
        
        if existing:
            error_msg = 'Ya existe otro banner con ese nombre'
            if request.is_json:
                return jsonify({'success': False, 'error': error_msg}), 409
            else:
                flash(error_msg, 'error')
                return redirect(url_for('admin.banner_management'))
        
        # Actualizar campos
        banner.name = name
        banner.description = description
        banner.auto_rotate = data.get('auto_rotate', True)
        banner.rotation_interval = int(data.get('rotation_interval', 6000))
        banner.responsive = data.get('responsive', True)
        banner.show_controller = data.get('show_controller', True)
        banner.width = int(data.get('width', 775))
        banner.height = int(data.get('height', 394))
        banner.enable_socketio = data.get('enable_socketio', True)
        banner.enable_real_time = data.get('enable_real_time', True)
        banner.updated_at = datetime.utcnow()
        
        db.session.commit()
        
        # Notificar si es el banner activo
        if banner.is_active:
            try:
                from public_socketio_utils import emit_to_public
                emit_to_public('banner_config_updated', {
                    'banner_id': banner.id,
                    'config': banner.to_dict()
                })
            except ImportError:
                pass
        
        # Notificar admin
        try:
            from socketio_utils import notify_admin
            notify_admin(
                f'Banner "{name}" actualizado exitosamente',
                'success',
                {
                    'action': 'banner_updated',
                    'banner_id': banner.id,
                    'name': name
                }
            )
        except ImportError:
            pass
        
        success_msg = f'Banner "{name}" actualizado exitosamente'
        if request.is_json:
            return jsonify({
                'success': True,
                'message': success_msg,
                'banner': banner.to_dict()
            })
        else:
            flash(success_msg, 'success')
            return redirect(url_for('admin.banner_management'))
            
    except Exception as e:
        db.session.rollback()
        error_msg = f'Error al actualizar banner: {str(e)}'
        current_app.logger.error(error_msg)
        
        if request.is_json:
            return jsonify({'success': False, 'error': error_msg}), 500
        else:
            flash(error_msg, 'error')
            return redirect(url_for('admin.banner_management'))
# ==================== RUTAS PARA TESTING ====================

@admin_bp.route('/banners/test')
@login_required
def test_banner():
    """Página de testing del banner"""
    try:
        banner = BannerConfig.get_active()
        return render_template('admin/test_banner.html', banner=banner)
    except Exception as e:
        flash(f'Error: {str(e)}', 'error')
        return redirect(url_for('admin.banner_management'))

@admin_bp.route('/api/banner/test_data', methods=['POST'])
@login_required
def send_test_banner_data():
    """Enviar datos de prueba al banner"""
    try:
        data = request.get_json() or {}
        test_type = data.get('type', 'full')
        
        # Datos de prueba
        test_data = {
            'system_status': {
                'status': 'online',
                'latest_game_version': '2.1.5-TEST',
                'current_launcher_version': '3.4.2-TEST',
                'maintenance_mode': False
            },
            'news': [
                {
                    'id': 999,
                    'type': 'Test',
                    'message': f'Mensaje de prueba enviado a las {datetime.now().strftime("%H:%M:%S")}',
                    'priority': 7
                }
            ],
            'stats': {
                'players': 750,
                'servers': '4/4',
                'status': 'online'
            },
            'timestamp': datetime.utcnow().isoformat(),
            'source': 'admin_test'
        }
        
        # Emitir a launchers
        try:
            from public_socketio_utils import emit_to_public
            emit_to_public('initial_data', test_data)
        except ImportError:
            pass
        
        return jsonify({
            'success': True,
            'message': f'Datos de prueba enviados (tipo: {test_type})',
            'test_data': test_data
        })
        
    except Exception as e:
        current_app.logger.error(f"Error sending test banner data: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


# ==================== AGREGAR AL FINAL DE admin_routes.py ====================

# ✅ RUTA FALTANTE: Crear noticias de prueba
@admin_bp.route('/api/test/create_test_news', methods=['POST'])
@login_required
def api_create_test_news():
    """Crear noticias de prueba para testing de SocketIO"""
    try:
        data = request.get_json() or {}
        count = int(data.get('count', 2))
        
        print(f"🧪 Creando {count} noticias de prueba...")
        
        # Crear noticias de prueba
        test_news = []
        for i in range(count):
            news_types = ['Test', 'Prueba', 'Sistema', 'Actualización', 'Evento']
            messages = [
                f'🧪 Noticia de prueba #{i+1} - {datetime.now().strftime("%H:%M:%S")}',
                f'📡 Test de comunicación SocketIO - Mensaje {i+1}',
                f'🔔 Verificación de notificaciones en tiempo real',
                f'⚡ Prueba de actualización automática del banner',
                f'🎯 Test específico de funcionalidad #{i+1}'
            ]
            
            news_message = NewsMessage(
                type=news_types[i % len(news_types)],
                message=messages[i % len(messages)],
                priority=7 + i,  # Alta prioridad para tests
                is_active=True,
                created_by=current_user.id
            )
            
            db.session.add(news_message)
            test_news.append({
                'type': news_message.type,
                'message': news_message.message,
                'priority': news_message.priority
            })
        
        db.session.commit()
        print(f"✅ {count} noticias de prueba creadas en BD")
        
        # Obtener todas las noticias activas
        active_messages = NewsMessage.query.filter_by(is_active=True).order_by(
            NewsMessage.priority.desc(), 
            NewsMessage.created_at.desc()
        ).all()
        
        print(f"📊 Total noticias activas: {len(active_messages)}")
        
        # ✅ NOTIFICAR VIA SOCKETIO
        notification_sent = False
        try:
            notify_news_updated(active_messages)
            notification_sent = True
            print("✅ Notificación SocketIO enviada")
        except Exception as e:
            print(f"❌ Error enviando notificación: {e}")
        
        return jsonify({
            'success': True,
            'message': f'{count} noticias de prueba creadas exitosamente',
            'test_news': test_news,
            'total_active_news': len(active_messages),
            'notification_sent': notification_sent,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error creando noticias de prueba: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 500

# ✅ RUTA MEJORADA: Debug SocketIO con más información
@admin_bp.route('/api/test/debug_socketio_enhanced', methods=['GET'])
@login_required
def api_debug_socketio_enhanced():
    """Debug completo del estado de SocketIO"""
    try:
        debug_info = {
            'timestamp': datetime.utcnow().isoformat(),
            'flask_context': True,  # Si llegamos aquí, el contexto está bien
            'current_user': current_user.username,
            'request_method': request.method,
            'request_endpoint': request.endpoint
        }
        
        # Verificar SocketIO
        try:
            from app import socketio
            debug_info['socketio_available'] = True
            debug_info['socketio_type'] = str(type(socketio))
            debug_info['socketio_connected_count'] = len(getattr(socketio.server.manager, 'rooms', {}).get('/public', {}))
        except ImportError as e:
            debug_info['socketio_available'] = False
            debug_info['socketio_error'] = str(e)
        except Exception as e:
            debug_info['socketio_available'] = False
            debug_info['socketio_error'] = f"Error inesperado: {str(e)}"
        
        # Verificar public_socketio_utils
        try:
            from public_socketio_utils import debug_socketio_state
            socketio_state = debug_socketio_state()
            debug_info.update(socketio_state)
            debug_info['public_utils_available'] = True
        except ImportError as e:
            debug_info['public_utils_available'] = False
            debug_info['public_utils_error'] = str(e)
        except Exception as e:
            debug_info['public_utils_available'] = False
            debug_info['public_utils_error'] = f"Error inesperado: {str(e)}"
        
        # Estadísticas de la base de datos
        try:
            debug_info['total_news'] = NewsMessage.query.count()
            debug_info['active_news'] = NewsMessage.query.filter_by(is_active=True).count()
            debug_info['game_versions'] = GameVersion.query.count()
            debug_info['launcher_versions'] = LauncherVersion.query.count()
        except Exception as e:
            debug_info['db_error'] = str(e)
        
        return jsonify({
            'success': True,
            'debug_info': debug_info,
            'recommendations': get_debug_recommendations(debug_info)
        })
        
    except Exception as e:
        current_app.logger.error(f"Error en debug enhanced: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 500

def get_debug_recommendations(debug_info):
    """Generar recomendaciones basadas en el estado del debug"""
    recommendations = []
    
    if not debug_info.get('socketio_available'):
        recommendations.append("❌ SocketIO no está disponible - verificar importación en app.py")
    
    if not debug_info.get('public_utils_available'):
        recommendations.append("❌ public_socketio_utils no disponible - verificar archivo")
    
    if debug_info.get('active_news', 0) == 0:
        recommendations.append("⚠️ No hay noticias activas - crear algunas para testing")
    
    if debug_info.get('socketio_connected_count', 0) == 0:
        recommendations.append("⚠️ No hay clientes conectados al namespace /public")
    
    if len(recommendations) == 0:
        recommendations.append("✅ Todo parece estar funcionando correctamente")
    
    return recommendations

# ✅ RUTA NUEVA: Test específico de mantenimiento
@admin_bp.route('/api/test/maintenance_mode', methods=['POST'])
@login_required
def api_test_maintenance_mode():
    """Test específico de modo mantenimiento"""
    try:
        data = request.get_json() or {}
        mode = data.get('mode', 'test')  # 'test', 'real', 'disable'
        
        print(f"🔧 Test de mantenimiento - Modo: {mode}")
        
        if mode == 'test':
            # Solo enviar notificación de test (enabled=false)
            message = f"🧪 TEST de mantenimiento desde admin - {datetime.now().strftime('%H:%M:%S')}"
            notify_maintenance_mode_changed(False, message)
            result_message = "Test de mantenimiento enviado (solo notificación)"
            
        elif mode == 'real':
            # Simular mantenimiento real (enabled=true) 
            message = f"🔧 SIMULACIÓN de mantenimiento real - {datetime.now().strftime('%H:%M:%S')}"
            notify_maintenance_mode_changed(True, message)
            result_message = "Simulación de mantenimiento real enviada"
            
        elif mode == 'disable':
            # Desactivar mantenimiento
            notify_maintenance_mode_changed(False, "")
            result_message = "Desactivación de mantenimiento enviada"
            
        else:
            return jsonify({'success': False, 'error': 'Modo inválido'}), 400
        
        return jsonify({
            'success': True,
            'message': result_message,
            'mode': mode,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        current_app.logger.error(f"Error en test de mantenimiento: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 500

# ✅ RUTA NUEVA: Test de nueva versión
@admin_bp.route('/api/test/new_version', methods=['POST'])
@login_required
def api_test_new_version():
    """Test de notificación de nueva versión"""
    try:
        data = request.get_json() or {}
        version = data.get('version', f"TEST.{datetime.utcnow().strftime('%H%M%S')}")
        
        print(f"🎮 Test de nueva versión: {version}")
        
        # Enviar notificación de nueva versión
        notify_new_game_version_available(version, True)
        
        return jsonify({
            'success': True,
            'message': f'Notificación de nueva versión {version} enviada',
            'version': version,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        current_app.logger.error(f"Error en test de nueva versión: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 500

# ✅ RUTA NUEVA: Test directo de emisión
@admin_bp.route('/api/test/direct_emit', methods=['POST'])
@login_required
def api_test_direct_emit():
    """Test de emisión directa a namespace público"""
    try:
        data = request.get_json() or {}
        message = data.get('message', f"Test directo desde admin - {datetime.now().strftime('%H:%M:%S')}")
        
        print(f"📡 Test de emisión directa: {message}")
        
        # Emisión directa usando public_socketio_utils
        from public_socketio_utils import emit_to_public
        
        test_data = {
            'test_type': 'direct_emission',
            'message': message,
            'timestamp': datetime.utcnow().isoformat(),
            'admin_user': current_user.username,
            'source': 'admin_test'
        }
        
        success = emit_to_public('admin_direct_test', test_data)
        
        return jsonify({
            'success': success,
            'message': 'Emisión directa enviada' if success else 'Error en emisión directa',
            'test_data': test_data,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        current_app.logger.error(f"Error en test de emisión directa: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 500

# ✅ RUTA NUEVA: Estado completo del sistema
@admin_bp.route('/api/test/system_status', methods=['GET'])
@login_required
def api_test_system_status():
    """Obtener estado completo del sistema para testing"""
    try:
        # Estado de SocketIO
        socketio_status = {}
        try:
            from app import socketio
            socketio_status['available'] = True
            socketio_status['type'] = str(type(socketio))
        except Exception as e:
            socketio_status['available'] = False
            socketio_status['error'] = str(e)
        
        # Estado de public_socketio_utils
        public_utils_status = {}
        try:
            from public_socketio_utils import debug_socketio_state, test_public_socketio
            public_utils_status['available'] = True
            public_utils_status['debug'] = debug_socketio_state()
        except Exception as e:
            public_utils_status['available'] = False
            public_utils_status['error'] = str(e)
        
        # Estado de la base de datos
        db_status = {}
        try:
            db_status['news_total'] = NewsMessage.query.count()
            db_status['news_active'] = NewsMessage.query.filter_by(is_active=True).count()
            db_status['versions'] = GameVersion.query.count()
            db_status['launchers'] = LauncherVersion.query.count()
            db_status['available'] = True
        except Exception as e:
            db_status['available'] = False
            db_status['error'] = str(e)
        
        # Estado del sistema
        system_status = {}
        try:
            from models import SystemConfig
            config = SystemConfig.get_config()
            system_status['maintenance_mode'] = config.maintenance_mode
            system_status['debug_mode'] = config.debug_mode
            system_status['auto_update'] = config.auto_update_enabled
        except Exception as e:
            system_status['error'] = str(e)
        
        return jsonify({
            'success': True,
            'status': {
                'socketio': socketio_status,
                'public_utils': public_utils_status,
                'database': db_status,
                'system': system_status
            },
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        current_app.logger.error(f"Error obteniendo estado del sistema: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 500

# ✅ FIX: Mejorar las rutas existentes con mejor manejo de errores

# Actualizar la ruta api_test_notify_public para incluir nuevos tests
@admin_bp.route('/api/test/notify_public_v2', methods=['POST'])
@login_required
def api_test_notify_public_v2():
    """Versión mejorada del test de notificaciones públicas"""
    try:
        data = request.get_json() or {}
        test_type = data.get('type', 'all')
        
        print(f"🧪 Test V2 iniciado - Type: {test_type}")
        
        results = {}
        
        # Test básico de SocketIO
        if test_type in ['all', 'socketio']:
            print("🧪 Probando SocketIO básico...")
            try:
                from public_socketio_utils import test_public_socketio
                results['socketio_test'] = test_public_socketio()
            except Exception as e:
                results['socketio_test'] = False
                results['socketio_error'] = str(e)
        
        # Test de noticias
        if test_type in ['all', 'news']:
            print("🧪 Probando notificaciones de noticias...")
            try:
                active_messages = NewsMessage.query.filter_by(is_active=True).order_by(
                    NewsMessage.priority.desc()
                ).limit(3).all()
                
                if active_messages:
                    notify_news_updated(active_messages)
                    results['news_test'] = True
                    results['news_count'] = len(active_messages)
                else:
                    results['news_test'] = False
                    results['news_error'] = 'No hay noticias activas'
                    
            except Exception as e:
                results['news_test'] = False
                results['news_error'] = str(e)
        
        # Test de mantenimiento
        if test_type in ['all', 'maintenance']:
            print("🧪 Probando notificaciones de mantenimiento...")
            try:
                # Test de notificación de mantenimiento
                test_message = f"🧪 TEST V2 de mantenimiento - {datetime.now().strftime('%H:%M:%S')}"
                notify_maintenance_mode_changed(False, test_message)
                results['maintenance_test'] = True
            except Exception as e:
                results['maintenance_test'] = False
                results['maintenance_error'] = str(e)
        
        # Test de nueva versión
        if test_type in ['all', 'version']:
            print("🧪 Probando notificaciones de nueva versión...")
            try:
                test_version = f"TEST.V2.{datetime.utcnow().strftime('%H%M%S')}"
                notify_new_game_version_available(test_version, True)
                results['version_test'] = True
                results['test_version'] = test_version
            except Exception as e:
                results['version_test'] = False
                results['version_error'] = str(e)
        
        # Test de emisión directa
        if test_type in ['all', 'direct']:
            print("🧪 Probando emisión directa...")
            try:
                from public_socketio_utils import emit_to_public
                direct_data = {
                    'test_type': 'direct_emission_v2',
                    'message': 'Test V2 de emisión directa',
                    'timestamp': datetime.utcnow().isoformat(),
                    'admin_user': current_user.username
                }
                results['direct_test'] = emit_to_public('admin_direct_test_v2', direct_data)
            except Exception as e:
                results['direct_test'] = False
                results['direct_error'] = str(e)
        
        # Debug info
        try:
            from public_socketio_utils import debug_socketio_state
            results['debug_info'] = debug_socketio_state()
        except Exception as e:
            results['debug_error'] = str(e)
        
        return jsonify({
            'success': True,
            'message': f'Test V2 completado (tipo: {test_type})',
            'test_type': test_type,
            'results': results,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        current_app.logger.error(f"Error en test V2: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 500
        
# ==================== PERFIL DE USUARIO ====================

@admin_bp.route('/profile')
@login_required
def profile():
    """Mostrar perfil del usuario actual"""
    try:
        return render_template('admin/profile.html', user=current_user)
    except Exception as e:
        current_app.logger.error(f'Error mostrando perfil: {e}')
        flash('Error cargando perfil', 'error')
        return redirect(url_for('admin.dashboard'))
        
@admin_bp.route('/api/profile/data', methods=['GET'])
@login_required
def get_profile_data():
    """API para obtener datos del perfil"""
    try:
        return jsonify({
            'success': True,
            'profile': {
                'id': current_user.id,
                'username': current_user.username,
                'email': current_user.email,
                'is_admin': current_user.is_admin,
                'created_at': current_user.created_at.isoformat() if current_user.created_at else None,
                'last_login': current_user.last_login.isoformat() if current_user.last_login else None
            }
        })
    except Exception as e:
        current_app.logger.error(f"Error getting profile data: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@admin_bp.route('/api/profile/activity', methods=['GET'])
@login_required
def get_profile_activity():
    """API para obtener actividad del usuario"""
    try:
        # Implementar lógica de actividad según tu modelo de datos
        return jsonify({
            'success': True,
            'activity': {
                'recent_actions': [
                    # Ejemplo: consultar tabla de logs/actividad
                    # {'action': 'Login', 'details': 'Acceso al sistema', 'timestamp': '...'}
                ],
                'session_info': {
                    'ip_address': request.remote_addr,
                    'current_session_start': datetime.now().isoformat(),
                    'user_agent': request.user_agent.string
                }
            }
        })
    except Exception as e:
        current_app.logger.error(f"Error getting profile activity: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@admin_bp.route('/api/profile/update', methods=['POST'])
@login_required
def update_profile():
    """API para actualizar perfil"""
    try:
        data = request.get_json()
        
        # Validar datos
        if not data.get('username') or not data.get('email'):
            return jsonify({'success': False, 'error': 'Username y email son requeridos'}), 400
        
        # Actualizar usuario
        current_user.username = data['username']
        current_user.email = data['email']
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Perfil actualizado correctamente'
        })
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error updating profile: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@admin_bp.route('/api/profile/change-password', methods=['POST'])
@login_required
def change_password():
    """API para cambiar contraseña"""
    try:
        data = request.get_json()
        
        # Validar contraseña actual
        if not current_user.check_password(data.get('current_password', '')):
            return jsonify({'success': False, 'error': 'Contraseña actual incorrecta'}), 400
        
        # Actualizar contraseña
        current_user.set_password(data['new_password'])
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Contraseña cambiada correctamente'
        })
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error changing password: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500        