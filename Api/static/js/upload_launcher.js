/**
 * upload_launcher.js - Lógica Vue.js para subir nueva versión del launcher
 * Separado completamente del template HTML
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
    
    // Crear instancia Vue para Upload Launcher
    const uploadLauncherApp = new Vue({
        el: '#app',
        delimiters: ['[[', ']]'],
        mixins: [NotificationMixin, HttpMixin, UtilsMixin, SocketMixin],
        
        data() {
            return {
                // Formulario
                form: {
                    version: '',
                    isCurrent: true,
                    releaseNotes: ''
                },
                
                // Opciones avanzadas
                options: {
                    replaceExisting: true,
                    createBackup: true,
                    notifyClients: false
                },
                
                // Archivo seleccionado
                selectedFile: null,
                
                // Estados de validación
                versionError: '',
                
                // Estados de drag & drop
                isDragOver: false,
                
                // Estados de envío
                submitting: false,
                
                // Progreso de upload
                uploadProgress: {
                    visible: false,
                    percentage: 0,
                    status: 'Preparando subida...',
                    animated: true,
                    complete: false,
                    error: false,
                    steps: [
                        'Validando archivo...',
                        'Creando backup de versión actual...',
                        'Subiendo nuevo launcher...',
                        'Actualizando metadatos...',
                        'Regenerando JSON de configuración...',
                        'Finalizando...'
                    ],
                    currentStep: 0
                },
                
                // Vista previa
                preview: {
                    version: '1.0.0.0',
                    status: 'Actual',
                    badgeClass: 'bg-success',
                    date: '',
                    fileName: 'LC.exe',
                    notes: '',
                    notesFormatted: '<em class="text-muted">Sin notas...</em>'
                },
                
                // Versión actual
                currentVersion: {
                    loading: true,
                    error: false,
                    data: null
                },
                
                // SocketIO
                isSocketConnected: false,
                socket: null,
                
                // Loading global
                loading: false,
                loadingMessage: 'Cargando...'
            };
        },
        
        computed: {
            /**
             * Verificar si el formulario es válido
             */
            isFormValid() {
                return this.selectedFile !== null && 
                       this.form.version.trim() !== '' && 
                       this.isValidVersionFormat(this.form.version) && 
                       !this.versionError;
            }
        },
        
        mounted() {
            console.log('✅ Upload Launcher Vue montado');
            
            // Inicializar SocketIO
            this.initSocket();
            
            // Configurar fecha actual para preview
            this.preview.date = new Date().toLocaleDateString('es-ES');
            
            // Cargar información de versión actual
            this.loadCurrentVersion();
            
            // Focus en el campo de versión
            this.$nextTick(() => {
                const versionInput = this.$el.querySelector('input[type="text"]');
                if (versionInput) {
                    versionInput.focus();
                }
            });
            
            console.log('Upload Launcher inicializado correctamente');
        },
        
        methods: {
            /**
             * Validar formato de versión X.Y.Z.W
             * @param {string} version - Versión a validar
             * @returns {boolean}
             */
            isValidVersionFormat(version) {
                if (!version) return false;
                const versionPattern = /^\d+\.\d+\.\d+\.\d+$/;
                return versionPattern.test(version.trim());
            },
            
            /**
             * Auto-completar versión en evento blur
             */
            autoCompleteVersion() {
                let version = this.form.version.trim();
                
                if (version && !this.isValidVersionFormat(version)) {
                    const parts = version.split('.');
                    
                    // Completar con ceros hasta tener 4 partes
                    while (parts.length < 4) {
                        parts.push('0');
                    }
                    
                    // Tomar solo las primeras 4 partes
                    this.form.version = parts.slice(0, 4).join('.');
                }
                
                this.validateVersion();
                this.updatePreview();
            },
            
            /**
             * Validar la versión ingresada
             */
            validateVersion() {
                const version = this.form.version.trim();
                
                if (!version) {
                    this.versionError = '';
                    return;
                }
                
                if (!this.isValidVersionFormat(version)) {
                    this.versionError = 'El formato debe ser: MAYOR.MENOR.PARCHE.BUILD (ej: 1.0.0.0)';
                    return;
                }
                
                // Validar que no sean todos ceros
                if (version === '0.0.0.0') {
                    this.versionError = 'La versión no puede ser 0.0.0.0';
                    return;
                }
                
                // Validar que las partes sean números válidos
                const parts = version.split('.');
                for (let part of parts) {
                    const num = parseInt(part);
                    if (isNaN(num) || num < 0 || num > 9999) {
                        this.versionError = 'Cada parte debe ser un número entre 0 y 9999';
                        return;
                    }
                }
                
                this.versionError = '';
            },
            
            /**
             * Actualizar vista previa en tiempo real
             */
            updatePreview() {
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
                
                // Actualizar notas
                this.preview.notes = this.form.releaseNotes.trim();
                if (this.preview.notes) {
                    this.preview.notesFormatted = this.preview.notes.replace(/\n/g, '<br>');
                } else {
                    this.preview.notesFormatted = '<em class="text-muted">Sin notas...</em>';
                }
                
                // Validar versión
                this.validateVersion();
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
             * Manejar dragover
             */
            handleDragOver(e) {
                this.isDragOver = true;
            },
            
            /**
             * Manejar dragleave
             */
            handleDragLeave(e) {
                this.isDragOver = false;
            },
            
            /**
             * Manejar drop de archivos
             */
            handleDrop(e) {
                this.isDragOver = false;
                
                const files = Array.from(e.dataTransfer.files);
                const exeFile = files.find(file => file.name.toLowerCase().endsWith('.exe'));
                
                if (exeFile) {
                    this.processFileSelection(exeFile);
                } else {
                    this.showError('Archivo inválido', 'Por favor selecciona un archivo ejecutable (.exe)');
                }
            },
            
            /**
             * Manejar selección de archivo desde input
             */
            handleFileSelection(e) {
                if (e.target.files.length > 0) {
                    this.processFileSelection(e.target.files[0]);
                }
            },
            
            /**
             * Procesar archivo seleccionado
             */
            processFileSelection(file) {
                console.log('Archivo seleccionado:', file.name, 'Tamaño:', file.size);
                
                if (!file.name.toLowerCase().endsWith('.exe')) {
                    this.showError('Archivo inválido', 'Solo se permiten archivos ejecutables (.exe)');
                    return;
                }
                
                this.selectedFile = file;
                this.updatePreview();
                
                console.log('Archivo procesado exitosamente');
            },
            
            /**
             * Limpiar archivo seleccionado
             */
            clearFile() {
                this.selectedFile = null;
                if (this.$refs.fileInput) {
                    this.$refs.fileInput.value = '';
                }
                this.updatePreview();
            },
            
            /**
             * Cargar información de versión actual desde API
             */
            async loadCurrentVersion() {
                this.currentVersion.loading = true;
                this.currentVersion.error = false;
                
                try {
                    const data = await this.apiGet('/api/launcher_update');
                    this.currentVersion.data = data;
                    console.log('✅ Versión actual cargada:', data);
                } catch (error) {
                    this.currentVersion.error = true;
                    console.warn('No se pudo cargar la versión actual:', error);
                } finally {
                    this.currentVersion.loading = false;
                }
            },
            
            /**
             * Enviar formulario para subir launcher
             */
            async submitLauncher() {
                console.log('Enviando formulario de launcher...');
                
                // Validación final
                if (!this.isFormValid) {
                    this.showError('Formulario inválido', 'Por favor corrige los errores antes de continuar');
                    return;
                }
                
                // Confirmar antes de subir
                const confirmed = await this.showConfirmation(
                    '¿Subir nueva versión del launcher?',
                    `Se subirá la versión ${this.form.version}${this.form.isCurrent ? ' y se establecerá como actual' : ''}.`,
                    'Sí, subir'
                );
                
                if (!confirmed) return;
                
                this.submitting = true;
                this.startUploadProgress();
                
                try {
                    // Preparar FormData
                    const formData = new FormData();
                    formData.append('version', this.form.version);
                    formData.append('launcher_file', this.selectedFile);
                    formData.append('release_notes', this.form.releaseNotes);
                    
                    if (this.form.isCurrent) {
                        formData.append('is_current', 'on');
                    }
                    if (this.options.replaceExisting) {
                        formData.append('replace_existing', 'on');
                    }
                    if (this.options.createBackup) {
                        formData.append('create_backup', 'on');
                    }
                    if (this.options.notifyClients) {
                        formData.append('notify_clients', 'on');
                    }
                    
                    console.log('FormData preparado');
                    
                    // Enviar petición
                    const response = await axios.post(window.location.href, formData, {
                        headers: {
                            'Content-Type': 'multipart/form-data'
                        }
                    });
                    
                    if (response.status === 200) {
                        this.completeUploadProgress();
                        
                        this.showSuccess(
                            '¡Launcher subido!', 
                            `La versión ${this.form.version} ha sido subida exitosamente`
                        );
                        
                        // Emitir evento SocketIO si está conectado
                        if (this.isSocketConnected) {
                            this.emitSocket('launcher_uploaded', {
                                version: this.form.version,
                                is_current: this.form.isCurrent
                            });
                        }
                        
                        // Redirigir después de un momento
                        setTimeout(() => {
                            window.location.href = '/admin/launcher';
                        }, 2000);
                    }
                    
                } catch (error) {
                    console.error('Error subiendo launcher:', error);
                    this.errorUploadProgress();
                    
                    let errorMessage = 'Error inesperado al subir el launcher';
                    
                    if (error.response) {
                        switch (error.response.status) {
                            case 400:
                                errorMessage = 'Datos del formulario inválidos';
                                break;
                            case 409:
                                errorMessage = 'Esta versión ya existe';
                                break;
                            case 413:
                                errorMessage = 'El archivo es demasiado grande';
                                break;
                            case 422:
                                errorMessage = error.response.data?.message || 'Datos inválidos';
                                break;
                            default:
                                errorMessage = error.response.data?.message || 'Error del servidor';
                        }
                    } else if (error.request) {
                        errorMessage = 'No se pudo conectar con el servidor';
                    }
                    
                    this.showError('Error al subir launcher', errorMessage);
                    
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
                this.uploadProgress.currentStep = 0;
                this.uploadProgress.animated = true;
                this.uploadProgress.complete = false;
                this.uploadProgress.error = false;
                
                // Simular progreso paso a paso
                this.progressInterval = setInterval(() => {
                    if (this.uploadProgress.currentStep < this.uploadProgress.steps.length) {
                        this.uploadProgress.status = this.uploadProgress.steps[this.uploadProgress.currentStep];
                        this.uploadProgress.currentStep++;
                    }
                    
                    this.uploadProgress.percentage += Math.random() * 15;
                    if (this.uploadProgress.percentage > 90) {
                        this.uploadProgress.percentage = 90;
                    }
                }, 1000);
            },
            
            /**
             * Completar progreso de upload
             */
            completeUploadProgress() {
                if (this.progressInterval) {
                    clearInterval(this.progressInterval);
                }
                
                this.uploadProgress.percentage = 100;
                this.uploadProgress.status = '¡Launcher subido exitosamente!';
                this.uploadProgress.animated = false;
                this.uploadProgress.complete = true;
                this.uploadProgress.currentStep = this.uploadProgress.steps.length;
            },
            
            /**
             * Error en progreso de upload
             */
            errorUploadProgress() {
                if (this.progressInterval) {
                    clearInterval(this.progressInterval);
                }
                
                this.uploadProgress.animated = false;
                this.uploadProgress.error = true;
                this.uploadProgress.status = 'Error en la subida del launcher';
            },
            
            /**
             * Manejar notificaciones desde SocketIO
             */
            handleSocketNotification(data) {
                // Llamar al método padre
                SocketMixin.methods.handleSocketNotification.call(this, data);
                
                // Manejar notificaciones específicas si es necesario
                if (data.data && data.data.action === 'launcher_conflict') {
                    this.showWarning(
                        'Conflicto de versión', 
                        'Otra versión del launcher fue subida mientras editabas. Verifica los datos.'
                    );
                }
            },
            
            /**
             * Establecer estado de carga global
             */
            setLoading(isLoading, message = 'Cargando...') {
                this.loading = isLoading;
                this.loadingMessage = message;
            },
            
            /**
             * Probar conexión SocketIO
             */
            testSocketConnection() {
                if (this.isSocketConnected) {
                    this.emitSocket('ping');
                    this.showInfo('Test SocketIO', 'Ping enviado al servidor');
                } else {
                    this.showWarning('Sin conexión', 'SocketIO no está conectado');
                }
            }
        },
        
        watch: {
            /**
             * Observar cambios en el campo versión para validación en tiempo real
             */
            'form.version'(newValue) {
                // Debounce para evitar validación excesiva
                clearTimeout(this.validationTimeout);
                this.validationTimeout = setTimeout(() => {
                    this.updatePreview();
                }, 300);
            },
            
            /**
             * Observar cambios en isCurrent
             */
            'form.isCurrent'() {
                this.updatePreview();
            },
            
            /**
             * Observar cambios en notas
             */
            'form.releaseNotes'() {
                this.updatePreview();
            }
        },
        
        beforeDestroy() {
            // Limpiar intervals
            if (this.progressInterval) {
                clearInterval(this.progressInterval);
            }
            if (this.validationTimeout) {
                clearTimeout(this.validationTimeout);
            }
        }
    });
    
    // Exponer para debugging en desarrollo
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        window.uploadLauncherApp = uploadLauncherApp;
        console.log('✅ Upload Launcher app disponible en window.uploadLauncherApp para debugging');
    }
    
    console.log('✅ Upload Launcher Vue.js inicializado exitosamente');
});