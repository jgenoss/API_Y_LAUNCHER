/**
 * create_update.js - Lógica Vue.js para crear paquete de actualización
 * Separado completamente del template HTML
 */

document.addEventListener('DOMContentLoaded', function () {
    console.log('🚀 DOMContentLoaded - Iniciando Create Update Vue.js');

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

    // Verificar datos del servidor
    if (typeof window.CREATE_UPDATE_DATA === 'undefined') {
        console.error('❌ CREATE_UPDATE_DATA no está disponible');
        return;
    }

    console.log('✅ Todas las dependencias disponibles');
    console.log('📦 Datos de actualización iniciales:', window.CREATE_UPDATE_DATA);

    // Configurar delimitadores de Vue
    Vue.config.delimiters = ['[[', ']]'];

    // Crear instancia Vue para Create Update
    const createUpdateApp = new Vue({
        el: '#app',
        delimiters: ['[[', ']]'],
        mixins: [NotificationMixin, HttpMixin, UtilsMixin, SocketMixin],

        data() {
            return {
                // Datos del servidor
                versions: window.CREATE_UPDATE_DATA.versions || [],
                urls: window.CREATE_UPDATE_DATA.urls || {},
                maxFileSize: window.CREATE_UPDATE_DATA.maxFileSize || (500 * 1024 * 1024),

                // Formulario
                form: {
                    versionId: window.CREATE_UPDATE_DATA.preSelectedVersionId || '',
                    options: {
                        overwriteExisting: true,
                        validateAfterUpload: true,
                        generateMD5: true
                    }
                },

                // Archivo seleccionado
                selectedFile: null,

                // Estados
                uploading: false,
                uploadProgress: 0,
                uploadStatus: '',
                uploadDetails: '',
                uploadError: false,
                isDragOver: false,

                // Errores de validación
                errors: {
                    version: '',
                    file: ''
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
             * Versión seleccionada actual
             */
            selectedVersion() {
                if (!this.form.versionId) return null;
                return this.versions.find(v => v.id === parseInt(this.form.versionId));
            },

            /**
             * Verificar si el formulario es válido
             */
            isFormValid() {
                return this.form.versionId &&
                    this.selectedFile &&
                    !this.errors.version &&
                    !this.errors.file &&
                    !this.uploading;
            },

            /**
             * Verificar si la versión ya tiene actualización
             */
            versionHasUpdate() {
                if (!this.selectedVersion) return false;
                return this.selectedVersion.update_packages &&
                    this.selectedVersion.update_packages.length > 0;
            }
        },

        mounted() {
            console.log('✅ Create Update Vue montado');

            // Inicializar SocketIO
            this.initSocket();

            // Cargar versión preseleccionada si existe
            if (this.form.versionId) {
                this.validateVersion();
            }

            // Focus en select de versión si no hay preselección
            this.$nextTick(() => {
                if (!this.form.versionId) {
                    const versionSelect = this.$el.querySelector('select');
                    if (versionSelect) {
                        versionSelect.focus();
                    }
                }
            });

            console.log('Create Update inicializado correctamente');
        },

        methods: {
            /**
             * Manejar cambio de versión
             */
            onVersionChange() {
                this.validateVersion();

                if (this.versionHasUpdate) {
                    this.showWarning(
                        'Versión ya tiene actualización',
                        'Esta versión ya tiene un paquete de actualización. Se reemplazará si continúas.'
                    );
                }
            },

            /**
             * Validar versión seleccionada
             */
            validateVersion() {
                if (!this.form.versionId) {
                    this.errors.version = 'Debe seleccionar una versión';
                    return false;
                }

                const version = this.selectedVersion;
                if (!version) {
                    this.errors.version = 'Versión seleccionada no es válida';
                    return false;
                }

                this.errors.version = '';
                return true;
            },

            /**
             * Disparar selector de archivos
             */
            triggerFileSelect() {
                this.$refs.fileInput.click();
            },

            /**
             * Manejar cambio de archivo
             */
            onFileChange(event) {
                const file = event.target.files[0];
                if (file) {
                    this.handleFileSelection(file);
                }
            },

            /**
             * Manejar selección de archivo
             */
            handleFileSelection(file) {
                console.log('Archivo seleccionado:', file.name, 'Tamaño:', file.size);

                // Validar tipo de archivo
                if (!file.name.toLowerCase().endsWith('.zip')) {
                    this.errors.file = 'Solo se permiten archivos ZIP';
                    this.selectedFile = null;
                    return;
                }

                // Validar tamaño
                if (file.size > this.maxFileSize) {
                    this.errors.file = `El archivo es demasiado grande. Máximo: ${this.formatFileSize(this.maxFileSize)}`;
                    this.selectedFile = null;
                    return;
                }

                // Validar que no esté vacío
                if (file.size === 0) {
                    this.errors.file = 'El archivo está vacío';
                    this.selectedFile = null;
                    return;
                }

                // Archivo válido
                this.selectedFile = file;
                this.errors.file = '';

                console.log('Archivo válido seleccionado:', {
                    name: file.name,
                    size: this.formatFileSize(file.size),
                    type: file.type
                });
            },

            /**
             * Limpiar archivo seleccionado
             */
            clearFile() {
                this.selectedFile = null;
                this.errors.file = '';
                this.$refs.fileInput.value = '';
            },

            /**
             * Manejar drag over
             */
            onDragOver() {
                this.isDragOver = true;
            },

            /**
             * Manejar drag leave
             */
            onDragLeave() {
                this.isDragOver = false;
            },

            /**
             * Manejar drop
             */
            onDrop(event) {
                this.isDragOver = false;

                const files = Array.from(event.dataTransfer.files);
                const zipFile = files.find(file => file.name.toLowerCase().endsWith('.zip'));

                if (zipFile) {
                    this.handleFileSelection(zipFile);
                } else {
                    this.showError('Archivo inválido', 'Por favor selecciona un archivo ZIP válido');
                }
            },

            /**
             * Formatear notas de versión para mostrar
             */
            formatNotes(notes) {
                if (!notes) return '';
                return notes.replace(/\n/g, '<br>');
            },

            /**
             * Enviar formulario para crear actualización
             */
            async submitUpdate() {
                console.log('Enviando formulario de actualización...');

                // Validación final
                if (!this.validateForm()) {
                    return;
                }

                // Confirmar antes de subir
                let confirmMessage = `¿Crear paquete de actualización para la versión ${this.selectedVersion.version}?`;
                if (this.versionHasUpdate) {
                    confirmMessage += '\n\n⚠️ Esta versión ya tiene un paquete de actualización que será reemplazado.';
                }

                const confirmed = await this.showConfirmation(
                    'Confirmar creación',
                    confirmMessage,
                    'Sí, crear paquete'
                );

                if (!confirmed) return;

                this.startUpload();

                try {
                    // Preparar FormData
                    const formData = new FormData();
                    formData.append('version_id', this.form.versionId);
                    formData.append('update_file', this.selectedFile);

                    // Agregar opciones
                    const optionsMapping = {
                        'overwriteExisting': 'overwrite_existing',
                        'validateAfterUpload': 'validate_after_upload',
                        'generateMD5': 'generate_md5'
                    };

                    Object.keys(this.form.options).forEach(key => {
                        const backendKey = optionsMapping[key];
                        const value = this.form.options[key];
                        formData.append(backendKey, value ? 'true' : 'false');
                        console.log(`📤 Enviando: ${backendKey} = ${value}`);
                    });
                    
                    console.log('Enviando datos:', {
                        version_id: this.form.versionId,
                        file: this.selectedFile.name,
                        options: this.form.options
                    });

                    // Simular progreso
                    this.simulateProgress();

                    // Enviar petición
                    const response = await axios.post(this.urls.createUpdate, formData, {
                        headers: {
                            'Content-Type': 'multipart/form-data'
                        },
                        onUploadProgress: (progressEvent) => {
                            if (progressEvent.lengthComputable) {
                                const progress = Math.round((progressEvent.loaded / progressEvent.total) * 85);
                                this.uploadProgress = progress;
                            }
                        }
                    });

                    // Finalizar progreso
                    this.completeUpload();

                    this.showSuccess(
                        '¡Paquete creado!',
                        `El paquete de actualización para la versión ${this.selectedVersion.version} ha sido creado exitosamente`
                    );

                    // Emitir evento SocketIO
                    if (this.isSocketConnected) {
                        this.emitSocket('update_created', {
                            version: this.selectedVersion.version,
                            filename: `update_${this.selectedVersion.version}.zip`,
                            size: this.selectedFile.size
                        });
                    }

                    // Redirigir después de un momento
                    setTimeout(() => {
                        window.location.href = this.urls.updates;
                    }, 2000);

                } catch (error) {
                    this.handleUploadError(error);
                }
            },

            /**
             * Validar formulario completo
             */
            validateForm() {
                let isValid = true;

                // Validar versión
                if (!this.validateVersion()) {
                    isValid = false;
                }

                // Validar archivo
                if (!this.selectedFile) {
                    this.errors.file = 'Debe seleccionar un archivo ZIP';
                    isValid = false;
                } else if (!this.selectedFile.name.toLowerCase().endsWith('.zip')) {
                    this.errors.file = 'Solo se permiten archivos ZIP';
                    isValid = false;
                } else if (this.selectedFile.size > this.maxFileSize) {
                    this.errors.file = `Archivo demasiado grande. Máximo: ${this.formatFileSize(this.maxFileSize)}`;
                    isValid = false;
                } else {
                    this.errors.file = '';
                }

                if (!isValid) {
                    this.showError('Formulario inválido', 'Por favor corrige los errores antes de continuar');
                }

                return isValid;
            },

            /**
             * Iniciar proceso de upload
             */
            startUpload() {
                this.uploading = true;
                this.uploadProgress = 0;
                this.uploadStatus = 'Preparando subida...';
                this.uploadDetails = `Archivo: ${this.selectedFile.name} (${this.formatFileSize(this.selectedFile.size)})`;
                this.uploadError = false;
            },

            /**
             * Simular progreso de upload
             */
            simulateProgress() {
                const interval = setInterval(() => {
                    if (this.uploadProgress < 85) {
                        this.uploadProgress += Math.random() * 10;
                        this.uploadStatus = 'Subiendo archivo...';
                    } else {
                        clearInterval(interval);
                        this.uploadStatus = 'Procesando archivo...';
                    }
                }, 200);

                // Limpiar intervalo después de 30 segundos por seguridad
                setTimeout(() => clearInterval(interval), 30000);
            },

            /**
             * Completar upload exitoso
             */
            completeUpload() {
                this.uploadProgress = 100;
                this.uploadStatus = '¡Paquete creado exitosamente!';
                this.uploadDetails = 'Redirigiendo a la página de actualizaciones...';
                this.uploadError = false;
            },

            /**
             * Manejar error de upload
             */
            handleUploadError(error) {
                console.error('Error en upload:', error);

                this.uploadError = true;
                this.uploadProgress = 0;

                let errorMessage = 'Error inesperado al crear el paquete';

                if (error.response) {
                    switch (error.response.status) {
                        case 400:
                            errorMessage = 'Datos del formulario inválidos';
                            break;
                        case 413:
                            errorMessage = 'El archivo es demasiado grande';
                            break;
                        case 415:
                            errorMessage = 'Tipo de archivo no soportado';
                            break;
                        case 422:
                            errorMessage = error.response.data?.message || 'Datos inválidos';
                            break;
                        case 500:
                            errorMessage = 'Error interno del servidor';
                            break;
                        default:
                            errorMessage = error.response.data?.message || 'Error del servidor';
                    }
                } else if (error.request) {
                    errorMessage = 'No se pudo conectar con el servidor';
                }

                this.uploadStatus = `Error: ${errorMessage}`;
                this.uploadDetails = 'La subida ha fallado. Revisa los datos e inténtalo nuevamente.';

                this.showError('Error al crear paquete', errorMessage);

                // Resetear estado después de un momento
                setTimeout(() => {
                    this.uploading = false;
                }, 3000);
            },

            /**
             * Manejar notificaciones desde SocketIO
             */
            handleSocketNotification(data) {
                // Llamar al método padre
                SocketMixin.methods.handleSocketNotification.call(this, data);

                // Manejar notificaciones específicas
                if (data.data && data.data.action === 'version_update_conflict') {
                    this.showWarning(
                        'Conflicto de actualización',
                        'Otro usuario está trabajando en esta versión. Verifica los datos antes de continuar.'
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
             * Observar cambios en la versión seleccionada
             */
            'form.versionId'(newValue, oldValue) {
                if (newValue !== oldValue) {
                    this.validateVersion();
                }
            },

            /**
             * Observar cambios en el archivo seleccionado
             */
            selectedFile(newFile, oldFile) {
                if (newFile !== oldFile) {
                    if (newFile) {
                        console.log('Nuevo archivo seleccionado:', newFile.name);
                    } else {
                        console.log('Archivo removido');
                    }
                }
            },

            /**
             * Observar estado de upload
             */
            uploading(isUploading) {
                if (isUploading) {
                    console.log('Upload iniciado');
                } else {
                    console.log('Upload finalizado');
                }
            }
        }
    });

    // Exponer para debugging en desarrollo
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        window.createUpdateApp = createUpdateApp;
        console.log('✅ Create Update app disponible en window.createUpdateApp para debugging');
    }

    console.log('✅ Create Update Vue.js inicializado exitosamente');
});