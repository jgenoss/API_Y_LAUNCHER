/**
 * upload_launcher.js - Lógica Vue.js para subir nueva versión del launcher
 * Separado completamente del template HTML
 * Con validaciones mejoradas y control de versiones
 */

document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 DOMContentLoaded - Iniciando Upload Launcher Vue.js');
    
    // Verificaciones de dependencias
    if (typeof Vue === 'undefined') {
        console.error('❌ Vue.js no está disponible');
        return;
    }
    
    const appElement = document.getElementById('app');
    if (!appElement) {
        console.error('❌ Elemento #app no encontrado en el DOM');
        return;
    }
    
    if (typeof NotificationMixin === 'undefined') {
        console.error('❌ Mixins no están disponibles');
        return;
    }
    
    console.log('✅ Todas las dependencias disponibles');
    
    // Configurar delimitadores de Vue
    Vue.config.delimiters = ['[[', ']]'];
    
    // Configuración del launcher
    const LAUNCHER_CONFIG = {
        maxFileSize: 500 * 1024 * 1024, // 500MB
        minFileSize: 1024, // 1KB
        allowedExtensions: ['.exe'],
        versionPattern: /^(\d+)\.(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:[-.]?(alpha|beta|rc|pre|dev)\.?(\d+)?)?$/,
        uploadTimeout: 300000, // 5 minutos
        debounceTime: 500 // 500ms para verificaciones
    };
    
    // Crear instancia Vue para Upload Launcher
    const uploadLauncherApp = new Vue({
        el: '#app',
        delimiters: ['[[', ']]'],
        mixins: [NotificationMixin, HttpMixin, UtilsMixin, SocketMixin],
        
        data() {
            return {
                // Formulario principal
                form: {
                    version: '',
                    isCurrent: true,
                    releaseNotes: ''
                },
                
                // Opciones avanzadas
                options: {
                    replaceExisting: true,
                    createBackup: true,
                    updateJson: true,
                    notifyClients: false
                },
                
                // Archivo seleccionado
                selectedFile: null,
                
                // Estados de validación
                versionError: '',
                fileError: '',
                
                // Estados de drag & drop
                isDragOver: false,
                
                // Estados de envío
                submitting: false,
                
                // Progreso de upload
                uploadProgress: {
                    visible: false,
                    percentage: 0,
                    stage: 'Preparando...',
                    eta: '',
                    speed: ''
                },
                
                // Vista previa
                preview: {
                    version: '1.0.0.0',
                    status: 'Actual',
                    badgeClass: 'bg-success',
                    fileName: 'Sin archivo...',
                    fileSize: '0 B',
                    date: new Date().toLocaleDateString('es-ES'),
                    notes: '',
                    notesFormatted: '<em class="text-muted">Sin notas...</em>'
                },
                
                // Verificación de versiones
                versionCheck: {
                    checking: false,
                    exists: false,
                    existingVersion: null,
                    isCurrent: false,
                    lastChecked: null
                },
                
                // Warnings y validaciones
                warnings: {
                    replaceExisting: false,
                    makeCurrentWarning: false,
                    noBackupWarning: false,
                    versionDowngrade: false
                },
                
                // Versión actual del sistema
                currentVersion: {
                    loading: false,
                    data: null,
                    error: false
                },
                
                // SocketIO
                isSocketConnected: false,
                socket: null,
                
                // Timeouts para debouncing
                timeouts: {
                    versionCheck: null,
                    preview: null
                }
            };
        },
        
        computed: {
            /**
             * Verificar si el formulario es válido
             */
            isFormValid() {
                return this.form.version && 
                       this.selectedFile && 
                       !this.versionError && 
                       !this.fileError && 
                       !this.submitting;
            },
            
            /**
             * Verificar si hay warnings críticos
             */
            hasCriticalWarnings() {
                return this.warnings.replaceExisting || 
                       this.warnings.makeCurrentWarning || 
                       this.warnings.versionDowngrade;
            },
            
            /**
             * Texto del botón de envío
             */
            submitButtonText() {
                if (this.submitting) {
                    return 'Procesando...';
                }
                
                if (this.versionCheck.exists && this.options.replaceExisting) {
                    return 'Reemplazar Versión';
                }
                
                return 'Subir Launcher';
            },
            
            /**
             * Clase CSS del botón según el estado
             */
            submitButtonClass() {
                if (this.submitting) {
                    return 'btn btn-primary disabled';
                }
                
                if (this.hasCriticalWarnings) {
                    return 'btn btn-warning';
                }
                
                return 'btn btn-primary';
            }
        },
        
        watch: {
            // Vigilar cambios en la versión
            'form.version': {
                handler(newVersion) {
                    this.versionError = '';
                    
                    if (newVersion && newVersion.length >= 5) {
                        // Debounce la verificación de versión
                        if (this.timeouts.versionCheck) {
                            clearTimeout(this.timeouts.versionCheck);
                        }
                        
                        this.timeouts.versionCheck = setTimeout(() => {
                            this.checkVersionExists();
                        }, LAUNCHER_CONFIG.debounceTime);
                    }
                    
                    this.updatePreview();
                },
                immediate: false
            },
            
            // Vigilar cambios en opciones críticas
            'form.isCurrent': function() {
                this.checkWarnings();
                this.updatePreview();
            },
            
            'options.createBackup': function() {
                this.checkWarnings();
            },
            
            'options.replaceExisting': function() {
                this.checkWarnings();
            },
            
            // Vigilar cambios en notas de release
            'form.releaseNotes': function() {
                this.updatePreview();
            }
        },
        
        mounted() {
            console.log('✅ Upload Launcher Vue montado');
            
            // Cargar versión actual
            this.loadCurrentVersion();
            
            // Inicializar SocketIO
            this.initSocket();
            
            // Actualizar vista previa inicial
            this.updatePreview();
            
            // Configurar eventos de ventana
            this.setupWindowEvents();
            
            console.log('Upload Launcher inicializado correctamente');
        },
        
        beforeDestroy() {
            // Limpiar timeouts
            Object.values(this.timeouts).forEach(timeout => {
                if (timeout) clearTimeout(timeout);
            });
            
            // Limpiar eventos de ventana
            this.cleanupWindowEvents();
        },
        
        methods: {
            /**
             * Inicializar SocketIO
             */
            initSocket() {
                if (typeof io !== 'undefined' && !this.socket) {
                    try {
                        this.socket = io();
                        this.isSocketConnected = true;
                        
                        this.socket.on('connect', () => {
                            console.log('🔌 SocketIO conectado');
                            this.isSocketConnected = true;
                        });
                        
                        this.socket.on('disconnect', () => {
                            console.log('🔌 SocketIO desconectado');
                            this.isSocketConnected = false;
                        });
                        
                    } catch (error) {
                        console.warn('⚠️ No se pudo conectar SocketIO:', error);
                    }
                }
            },
            
            /**
             * Manejar eventos de drag & drop
             */
            handleDragEnter(e) {
                e.preventDefault();
                e.stopPropagation();
                this.isDragOver = true;
            },
            
            handleDragOver(e) {
                e.preventDefault();
                e.stopPropagation();
            },
            
            handleDragLeave(e) {
                e.preventDefault();
                e.stopPropagation();
                this.isDragOver = false;
            },
            
            handleDrop(e) {
                e.preventDefault();
                e.stopPropagation();
                this.isDragOver = false;
                
                const files = e.dataTransfer.files;
                if (files.length > 0) {
                    this.handleFileSelect(files[0]);
                }
            },
            
            /**
             * Manejar selección de archivo
             */
            handleFileSelect(file) {
                if (!file) {
                    // Si es un evento, obtener el archivo
                    if (file && file.target && file.target.files) {
                        file = file.target.files[0];
                    }
                }
                
                this.selectFile(file);
            },
            
            /**
             * Seleccionar archivo y validar
             */
            selectFile(file) {
                this.fileError = '';
                
                if (!file) {
                    this.selectedFile = null;
                    this.updatePreview();
                    return;
                }
                
                // Validaciones del archivo
                const validation = this.validateFile(file);
                if (!validation.valid) {
                    this.fileError = validation.error;
                    this.showError('Archivo inválido', validation.error);
                    return;
                }
                
                // Archivo válido
                this.selectedFile = file;
                
                console.log('✅ Archivo seleccionado:', {
                    name: file.name,
                    size: this.formatFileSize(file.size),
                    type: file.type
                });
                
                this.updatePreview();
            },
            
            /**
             * Validar archivo seleccionado
             */
            validateFile(file) {
                if (!file) {
                    return { valid: false, error: 'No se seleccionó archivo' };
                }
                
                // Verificar tamaño
                if (file.size > LAUNCHER_CONFIG.maxFileSize) {
                    return { 
                        valid: false, 
                        error: `Archivo demasiado grande. Máximo: ${this.formatFileSize(LAUNCHER_CONFIG.maxFileSize)}` 
                    };
                }
                
                if (file.size < LAUNCHER_CONFIG.minFileSize) {
                    return { valid: false, error: 'Archivo demasiado pequeño (mínimo 1KB)' };
                }
                
                // Verificar extensión
                const extension = '.' + file.name.split('.').pop().toLowerCase();
                if (!LAUNCHER_CONFIG.allowedExtensions.includes(extension)) {
                    return { 
                        valid: false, 
                        error: `Extensión no permitida. Solo: ${LAUNCHER_CONFIG.allowedExtensions.join(', ')}` 
                    };
                }
                
                return { valid: true };
            },
            
            /**
             * Validar formato de versión
             */
            validateVersion() {
                this.versionError = '';
                
                if (!this.form.version) {
                    return;
                }
                
                // Verificar formato con regex
                if (!LAUNCHER_CONFIG.versionPattern.test(this.form.version)) {
                    this.versionError = 'Formato inválido. Use: X.Y.Z.W (ej: 1.2.3.4)';
                    return;
                }
                
                // Verificar rangos numéricos
                const parts = this.form.version.split('.');
                for (let part of parts) {
                    const num = parseInt(part);
                    if (isNaN(num) || num < 0 || num > 9999) {
                        this.versionError = 'Cada parte debe ser un número entre 0 y 9999';
                        return;
                    }
                }
                
                console.log('✅ Versión válida:', this.form.version);
            },
            
            /**
             * Verificar si la versión ya existe
             */
            async checkVersionExists() {
                if (!this.form.version || this.versionError) {
                    return;
                }
                
                this.versionCheck.checking = true;
                this.versionCheck.exists = false;
                this.warnings.replaceExisting = false;
                
                try {
                    // Usar método compatible con tu estructura
                    const response = await axios.get(`/admin/api/launcher/check-version/${encodeURIComponent(this.form.version)}`);
                    
                    if (response.data.exists) {
                        this.versionCheck.exists = true;
                        this.versionCheck.existingVersion = response.data.version;
                        this.versionCheck.isCurrent = response.data.is_current;
                        this.versionCheck.lastChecked = new Date();
                        this.warnings.replaceExisting = true;
                        
                        console.log('⚠️ Versión existente detectada:', response.data);
                        
                        // Warning especial si es la versión actual
                        if (response.data.is_current) {
                            this.showWarning(
                                'Versión Actual Detectada',
                                `La versión ${this.form.version} ya existe y es la versión ACTUAL en producción.`
                            );
                        }
                    } else {
                        console.log('✅ Versión nueva:', this.form.version);
                    }
                    
                } catch (error) {
                    console.error('Error verificando versión:', error);
                    // No mostrar error al usuario, solo log
                } finally {
                    this.versionCheck.checking = false;
                    this.checkWarnings();
                }
            },
            
            /**
             * Verificar warnings antes de proceder
             */
            checkWarnings() {
                // Reset warnings
                this.warnings.makeCurrentWarning = false;
                this.warnings.noBackupWarning = false;
                this.warnings.versionDowngrade = false;
                
                // Warning si va a marcar como current sin backup
                if (this.form.isCurrent && !this.options.createBackup) {
                    this.warnings.noBackupWarning = true;
                }
                
                // Warning si va a cambiar la versión actual
                if (this.form.isCurrent) {
                    this.warnings.makeCurrentWarning = true;
                }
                
                // Warning si es un downgrade
                if (this.currentVersion.data && this.form.version) {
                    try {
                        if (this.compareVersions(this.form.version, this.currentVersion.data.version) < 0) {
                            this.warnings.versionDowngrade = true;
                        }
                    } catch (e) {
                        // Ignore comparison errors
                    }
                }
            },
            
            /**
             * Comparar versiones semánticas
             */
            compareVersions(version1, version2) {
                const parseVersion = (v) => v.split('.').map(n => parseInt(n) || 0);
                const v1 = parseVersion(version1);
                const v2 = parseVersion(version2);
                
                for (let i = 0; i < Math.max(v1.length, v2.length); i++) {
                    const a = v1[i] || 0;
                    const b = v2[i] || 0;
                    
                    if (a < b) return -1;
                    if (a > b) return 1;
                }
                
                return 0;
            },
            
            /**
             * Actualizar vista previa en tiempo real
             */
            updatePreview() {
                // Debounce la actualización
                if (this.timeouts.preview) {
                    clearTimeout(this.timeouts.preview);
                }
                
                this.timeouts.preview = setTimeout(() => {
                    // Actualizar versión
                    this.preview.version = this.form.version || '1.0.0.0';
                    
                    // Actualizar estado
                    if (this.form.isCurrent) {
                        this.preview.status = 'Actual';
                        this.preview.badgeClass = 'bg-success';
                    } else {
                        this.preview.status = 'Archivada';
                        this.preview.badgeClass = 'bg-secondary';
                    }
                    
                    // Actualizar archivo
                    if (this.selectedFile) {
                        this.preview.fileName = this.selectedFile.name;
                        this.preview.fileSize = this.formatFileSize(this.selectedFile.size);
                    } else {
                        this.preview.fileName = 'Sin archivo...';
                        this.preview.fileSize = '0 B';
                    }
                    
                    // Actualizar notas
                    this.preview.notes = this.form.releaseNotes.trim();
                    if (this.preview.notes) {
                        this.preview.notesFormatted = this.preview.notes.replace(/\n/g, '<br>');
                    } else {
                        this.preview.notesFormatted = '<em class="text-muted">Sin notas...</em>';
                    }
                    
                    // Validar versión
                    this.validateVersion();
                }, 100);
            },
            
            /**
             * Activar input de archivo
             */
            triggerFileInput() {
                if (this.$refs.fileInput) {
                    this.$refs.fileInput.click();
                }
            },
            
            /**
             * Limpiar archivo seleccionado
             */
            clearFile() {
                this.selectedFile = null;
                this.fileError = '';
                
                if (this.$refs.fileInput) {
                    this.$refs.fileInput.value = '';
                }
                
                this.updatePreview();
                console.log('🗑️ Archivo limpiado');
            },
            
            /**
             * Cargar información de versión actual
             */
            async loadCurrentVersion() {
                this.currentVersion.loading = true;
                this.currentVersion.error = false;
                
                try {
                    const response = await axios.get('/admin/api/launcher/current');
                    
                    if (response.data.found) {
                        this.currentVersion.data = response.data;
                        console.log('✅ Versión actual cargada:', response.data);
                    } else {
                        console.log('ℹ️ No hay versión actual configurada');
                    }
                    
                } catch (error) {
                    this.currentVersion.error = true;
                    console.warn('⚠️ No se pudo cargar la versión actual:', error);
                } finally {
                    this.currentVersion.loading = false;
                }
            },
            
            /**
             * Validación completa antes de envío
             */
            async validateBeforeSubmit() {
                console.log('🔍 Validando antes de envío...');
                
                // Validación básica del formulario
                if (!this.isFormValid) {
                    this.showError('Formulario Inválido', 'Por favor corrige todos los errores antes de continuar.');
                    return false;
                }
                
                // Re-verificar versión si es necesario
                if (!this.versionCheck.checking) {
                    await this.checkVersionExists();
                }
                
                // Si existe y no está marcado reemplazar
                if (this.versionCheck.exists && !this.options.replaceExisting) {
                    this.showError(
                        'Versión Ya Existe',
                        `La versión ${this.form.version} ya existe. Active "Reemplazar si existe" para sobrescribirla.`
                    );
                    return false;
                }
                
                // Confirmación especial para versión actual
                if (this.versionCheck.exists && this.versionCheck.isCurrent) {
                    const confirmed = await this.showConfirmation(
                        '⚠️ REEMPLAZAR VERSIÓN ACTUAL',
                        `¿Está ABSOLUTAMENTE SEGURO de que desea reemplazar la versión ${this.form.version} que está actualmente en PRODUCCIÓN?\n\nEsta acción afectará a todos los usuarios conectados.`
                    );
                    
                    if (!confirmed) {
                        console.log('❌ Usuario canceló reemplazo de versión actual');
                        return false;
                    }
                }
                
                // Confirmación si va a marcar como current
                if (this.form.isCurrent && !this.versionCheck.isCurrent) {
                    const confirmed = await this.showConfirmation(
                        'Cambiar Versión Actual',
                        `¿Desea establecer la versión ${this.form.version} como la nueva versión OFICIAL?\n\nEsto desactivará automáticamente la versión actual y notificará a todos los clientes.`
                    );
                    
                    if (!confirmed) {
                        console.log('❌ Usuario canceló cambio de versión actual');
                        return false;
                    }
                }
                
                console.log('✅ Validación completada exitosamente');
                return true;
            },
            
            /**
             * Enviar formulario principal
             */
            async submitLauncher() {
                console.log('🚀 Iniciando envío de launcher...');
                
                // Validación previa completa
                const isValid = await this.validateBeforeSubmit();
                if (!isValid) {
                    return;
                }
                
                this.submitting = true;
                this.startUploadProgress();
                
                try {
                    // Preparar FormData
                    const formData = new FormData();
                    formData.append('launcher_file', this.selectedFile);
                    formData.append('version', this.form.version);
                    formData.append('release_notes', this.form.releaseNotes);
                    
                    // Opciones booleanas (usando el formato que tu backend espera)
                    if (this.form.isCurrent) formData.append('is_current', 'on');
                    if (this.options.replaceExisting) formData.append('replace_existing', 'on');
                    if (this.options.createBackup) formData.append('create_backup', 'on');
                    if (this.options.updateJson) formData.append('update_json', 'on');
                    if (this.options.notifyClients) formData.append('notify_clients', 'on');
                    
                    // Log detallado de la operación
                    console.log('📤 Enviando con opciones:', {
                        version: this.form.version,
                        fileName: this.selectedFile.name,
                        fileSize: this.formatFileSize(this.selectedFile.size),
                        isCurrent: this.form.isCurrent,
                        replaceExisting: this.options.replaceExisting,
                        createBackup: this.options.createBackup,
                        versionExists: this.versionCheck.exists
                    });
                    
                    // Realizar petición con axios (compatible con tu estructura)
                    const response = await axios.post(window.location.href, formData, {
                        headers: {
                            'Content-Type': 'multipart/form-data'
                        },
                        timeout: LAUNCHER_CONFIG.uploadTimeout,
                        onUploadProgress: (progressEvent) => {
                            const percentCompleted = Math.round((progressEvent.loaded * 100) / progressEvent.total);
                            this.updateUploadProgress(percentCompleted, progressEvent);
                        }
                    });
                    
                    if (response.status === 200) {
                        // Proceso completado exitosamente
                        this.completeUploadProgress();
                        
                        // Determinar mensaje de éxito
                        let successMessage = `La versión ${this.form.version} ha sido procesada exitosamente.`;
                        
                        if (this.form.isCurrent) {
                            successMessage += ' Esta es ahora la versión OFICIAL del launcher.';
                        } else {
                            successMessage += ' Ha sido guardada como versión archivada.';
                        }
                        
                        this.showSuccess('🎉 Launcher Subido Exitosamente', successMessage);
                        
                        // Emitir evento SocketIO para notificaciones en tiempo real
                        if (this.isSocketConnected) {
                            this.emitSocket('launcher_uploaded', {
                                version: this.form.version,
                                is_current: this.form.isCurrent,
                                replaced_existing: this.versionCheck.exists,
                                timestamp: new Date().toISOString()
                            });
                            
                            console.log('📡 Evento SocketIO emitido');
                        }
                        
                        // Redirigir después de mostrar éxito
                        setTimeout(() => {
                            window.location.href = '/admin/launcher';
                        }, 3000);
                    }
                    
                } catch (error) {
                    this.errorUploadProgress();
                    console.error('❌ Error subiendo launcher:', error);
                    
                    // Determinar mensaje de error específico
                    let errorMessage = 'Error inesperado al subir el launcher.';
                    
                    if (error.response) {
                        const status = error.response.status;
                        const data = error.response.data;
                        
                        switch (status) {
                            case 400:
                                errorMessage = 'Datos del formulario inválidos. Verifique todos los campos.';
                                break;
                            case 409:
                                errorMessage = 'Esta versión ya existe y no se permite reemplazar.';
                                break;
                            case 413:
                                errorMessage = `El archivo es demasiado grande. Máximo permitido: ${this.formatFileSize(LAUNCHER_CONFIG.maxFileSize)}.`;
                                break;
                            case 422:
                                errorMessage = data?.message || 'Los datos de la versión son inválidos.';
                                break;
                            case 500:
                                errorMessage = 'Error interno del servidor. Contacte al administrador.';
                                break;
                            default:
                                errorMessage = data?.message || `Error del servidor (${status}).`;
                        }
                    } else if (error.request) {
                        errorMessage = 'No se pudo conectar con el servidor. Verifique su conexión a internet.';
                    } else if (error.code === 'ECONNABORTED') {
                        errorMessage = 'La subida tardó demasiado tiempo. Intente con un archivo más pequeño.';
                    }
                    
                    this.showError('Error al Subir Launcher', errorMessage);
                    
                } finally {
                    this.submitting = false;
                }
            },
            
            /**
             * Iniciar progreso de upload
             */
            startUploadProgress() {
                this.uploadProgress.visible = true;
                this.uploadProgress.percentage = 0;
                this.uploadProgress.stage = 'Preparando...';
                this.uploadProgress.eta = '';
                this.uploadProgress.speed = '';
                this.uploadStartTime = Date.now();
                
                console.log('📊 Progreso de upload iniciado');
            },
            
            /**
             * Actualizar progreso de upload
             */
            updateUploadProgress(percentage, progressEvent = null) {
                this.uploadProgress.percentage = Math.min(percentage, 100);
                
                // Determinar etapa según progreso
                if (percentage < 25) {
                    this.uploadProgress.stage = 'Subiendo archivo...';
                } else if (percentage < 75) {
                    this.uploadProgress.stage = 'Procesando...';
                } else if (percentage < 95) {
                    this.uploadProgress.stage = 'Validando...';
                } else {
                    this.uploadProgress.stage = 'Finalizando...';
                }
                
                // Calcular velocidad y ETA si hay datos del evento
                if (progressEvent && progressEvent.loaded && progressEvent.total && this.uploadStartTime) {
                    const elapsed = (Date.now() - this.uploadStartTime) / 1000;
                    const speed = progressEvent.loaded / elapsed;
                    const remaining = progressEvent.total - progressEvent.loaded;
                    const eta = remaining / speed;
                    
                    this.uploadProgress.speed = this.formatFileSize(speed) + '/s';
                    this.uploadProgress.eta = this.formatTime(eta);
                }
            },
            
            /**
             * Completar progreso de upload
             */
            completeUploadProgress() {
                this.uploadProgress.percentage = 100;
                this.uploadProgress.stage = '¡Completado!';
                this.uploadProgress.eta = '';
                
                // Ocultar después de un momento
                setTimeout(() => {
                    this.uploadProgress.visible = false;
                }, 2000);
                
                console.log('✅ Progreso de upload completado');
            },
            
            /**
             * Marcar error en progreso de upload
             */
            errorUploadProgress() {
                this.uploadProgress.stage = 'Error al subir';
                this.uploadProgress.percentage = 0;
                
                // Ocultar después de un momento
                setTimeout(() => {
                    this.uploadProgress.visible = false;
                }, 3000);
                
                console.log('❌ Error en progreso de upload');
            },
            
            /**
             * Formatear tamaño de archivo
             */
            formatFileSize(bytes) {
                if (bytes === 0) return '0 B';
                
                const k = 1024;
                const sizes = ['B', 'KB', 'MB', 'GB'];
                const i = Math.floor(Math.log(bytes) / Math.log(k));
                
                return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
            },
            
            /**
             * Formatear tiempo en segundos
             */
            formatTime(seconds) {
                if (!seconds || !isFinite(seconds)) return '';
                
                const mins = Math.floor(seconds / 60);
                const secs = Math.floor(seconds % 60);
                
                if (mins > 0) {
                    return `${mins}m ${secs}s`;
                } else {
                    return `${secs}s`;
                }
            },
            
            /**
             * Mostrar confirmación con promesa
             */
            showConfirmation(title, message) {
                return new Promise((resolve) => {
                    // Si tienes un modal de confirmación personalizado, úsalo aquí
                    // Por ahora usar confirm() nativo con mejor formato
                    const result = confirm(`${title}\n\n${message}`);
                    resolve(result);
                });
            },
            
            /**
             * Emitir evento SocketIO
             */
            emitSocket(event, data) {
                if (this.socket && this.isSocketConnected) {
                    this.socket.emit(event, data);
                    console.log('📡 Evento SocketIO emitido:', event, data);
                }
            },
            
            /**
             * Configurar eventos de ventana
             */
            setupWindowEvents() {
                // Prevenir pérdida de datos al cerrar ventana
                this.beforeUnloadHandler = (e) => {
                    if (this.submitting) {
                        e.preventDefault();
                        e.returnValue = 'Hay una subida en progreso. ¿Está seguro de que desea salir?';
                        return e.returnValue;
                    }
                };
                
                window.addEventListener('beforeunload', this.beforeUnloadHandler);
            },
            
            /**
             * Limpiar eventos de ventana
             */
            cleanupWindowEvents() {
                if (this.beforeUnloadHandler) {
                    window.removeEventListener('beforeunload', this.beforeUnloadHandler);
                }
            }
        }
    });
    
    console.log('✅ Upload Launcher Vue inicializado exitosamente');
});