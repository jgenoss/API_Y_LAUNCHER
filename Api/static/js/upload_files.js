/**
 * upload_files.js - Lógica Vue.js para subir archivos del juego
 * Separado completamente del template HTML
 */

document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 DOMContentLoaded - Iniciando Upload Files Vue.js');
    
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
    if (typeof window.UPLOAD_FILES_DATA === 'undefined') {
        console.error('❌ UPLOAD_FILES_DATA no está disponible');
        window.UPLOAD_FILES_DATA = {
            versions: [],
            versionsData: [],
            urls: { submit: '/admin/files/upload' }
        };
    }
    
    console.log('✅ Todas las dependencias disponibles');
    console.log('📁 Datos de upload files:', window.UPLOAD_FILES_DATA);
    
    // Configurar delimitadores de Vue
    Vue.config.delimiters = ['[[', ']]'];
    
    // Crear instancia Vue para Upload Files
    const uploadFilesApp = new Vue({
        el: '#app',
        delimiters: ['[[', ']]'],
        mixins: [NotificationMixin, HttpMixin, UtilsMixin, SocketMixin],
        
        data() {
            return {
                // Datos del servidor
                versions: window.UPLOAD_FILES_DATA.versions || [],
                versionsData: window.UPLOAD_FILES_DATA.versionsData || [],
                urls: window.UPLOAD_FILES_DATA.urls || {},
                
                // Formulario
                form: {},
                
                // Archivos seleccionados
                selectedFiles: [],
                
                // Configuración de rutas
                pathConfig: {
                    basePath: 'bin/',
                    paths: [] // Array de rutas para cada archivo
                },
                
                // Estados
                isDragOver: false,
                uploading: false,
                uploadProgress: 0,
                uploadStatus: 'Preparando subida...',
                uploadError: false,
                
                // Errores de validación
                errors: {
                    files: ''
                },
                
                // Tipos de archivo permitidos
                allowedExtensions: ['.exe', '.dll', '.txt', '.xml', '.json', '.png', '.jpg', '.gif'],
                
                // Loading global
                loading: false,
                loadingMessage: 'Cargando...',
                
                // SocketIO
                isSocketConnected: false,
                socket: null
            };
        },
        
        computed: {
            
            /**
             * Tamaño total de archivos seleccionados
             */
            totalFilesSize() {
                const totalBytes = this.selectedFiles.reduce((sum, file) => sum + file.size, 0);
                return this.formatFileSize(totalBytes);
            },
            
            /**
             * Verificar si el formulario es válido
             */
            isFormValid() {
                return this.selectedFiles.length > 0 && 
                       !this.errors.files &&
                       !this.uploading;
            }
        },
        
        mounted() {
            console.log('✅ Upload Files Vue montado');
            
            // Inicializar SocketIO
            this.initSocket();
            
            // Pre-seleccionar versión latest si existe
            
            console.log('Upload Files inicializado correctamente');
        },
        
        methods: {
            
            /**
             * Triggear selección de archivos
             */
            triggerFileSelect() {
                this.$refs.fileInput.click();
            },
            
            /**
             * Manejar selección de archivos
             */
            handleFileSelect(event) {
                const files = Array.from(event.target.files);
                this.processSelectedFiles(files);
            },
            
            /**
             * Manejar drag over
             */
            handleDragOver(event) {
                event.preventDefault();
                this.isDragOver = true;
            },
            
            /**
             * Manejar drag leave
             */
            handleDragLeave() {
                this.isDragOver = false;
            },
            
            /**
             * Manejar drop de archivos
             */
            handleFileDrop(event) {
                event.preventDefault();
                this.isDragOver = false;
                
                const files = Array.from(event.dataTransfer.files);
                this.processSelectedFiles(files);
            },
            
            /**
             * Procesar archivos seleccionados
             */
            processSelectedFiles(files) {
                console.log('Procesando archivos:', files.length);
                
                // Filtrar archivos válidos
                const validFiles = files.filter(file => this.isValidFile(file));
                
                if (validFiles.length === 0) {
                    this.errors.files = 'No se seleccionaron archivos válidos. Revisa los formatos soportados.';
                    return;
                }
                
                // Validar tamaño total
                const currentSize = this.selectedFiles.reduce((sum, file) => sum + file.size, 0);
                const newSize = validFiles.reduce((sum, file) => sum + file.size, 0);
                const totalSize = currentSize + newSize;
                const maxSize = 500 * 1024 * 1024; // 500MB
                
                if (totalSize > maxSize) {
                    this.errors.files = 'El tamaño total de archivos excede el límite de 500MB';
                    return;
                }
                
                // Agregar archivos a la lista (evitar duplicados)
                validFiles.forEach(file => {
                    const exists = this.selectedFiles.some(existing => 
                        existing.name === file.name && existing.size === file.size
                    );
                    
                    if (!exists) {
                        this.selectedFiles.push(file);
                        // Agregar ruta por defecto
                        this.pathConfig.paths.push(`bin/${file.name}`);
                    }
                });
                
                this.errors.files = '';
                
                // Actualizar input file
                this.updateFileInput();
                
                this.showSuccess(
                    'Archivos agregados',
                    `${validFiles.length} archivo(s) agregado(s) correctamente`
                );
                
                console.log('Archivos procesados exitosamente:', this.selectedFiles.length);
            },
            
            /**
             * Validar si un archivo es válido
             */
            isValidFile(file) {
                const extension = this.getFileExtension(file.name).toLowerCase();
                return this.allowedExtensions.includes(extension);
            },
            
            /**
             * Obtener extensión de archivo
             */
            getFileExtension(filename) {
                const lastDot = filename.lastIndexOf('.');
                return lastDot > 0 ? filename.substring(lastDot) : '';
            },
            
            /**
             * Obtener icono según extensión de archivo
             */
            getFileIcon(filename) {
                const ext = this.getFileExtension(filename).toLowerCase();
                const icons = {
                    '.exe': '<i class="bi bi-app text-primary"></i>',
                    '.dll': '<i class="bi bi-gear text-secondary"></i>',
                    '.xml': '<i class="bi bi-code text-info"></i>',
                    '.json': '<i class="bi bi-code text-info"></i>',
                    '.txt': '<i class="bi bi-file-text text-success"></i>',
                    '.png': '<i class="bi bi-image text-warning"></i>',
                    '.jpg': '<i class="bi bi-image text-warning"></i>',
                    '.gif': '<i class="bi bi-image text-warning"></i>'
                };
                
                return icons[ext] || '<i class="bi bi-file-earmark text-muted"></i>';
            },
            
            /**
             * Remover archivo de la lista
             */
            removeFile(index) {
                this.selectedFiles.splice(index, 1);
                this.pathConfig.paths.splice(index, 1);
                this.updateFileInput();
                
                if (this.selectedFiles.length === 0) {
                    this.errors.files = '';
                }
                
                this.showInfo('Archivo removido', 'El archivo ha sido removido de la lista');
            },
            
            /**
             * Limpiar todos los archivos
             */
            clearAllFiles() {
                this.selectedFiles = [];
                this.pathConfig.paths = [];
                this.errors.files = '';
                this.$refs.fileInput.value = '';
                
                this.showInfo('Archivos limpiados', 'Todos los archivos han sido removidos');
            },
            
            /**
             * Aplicar ruta base a todos los archivos
             */
            applyBasePathToAll() {
                const basePath = this.pathConfig.basePath.endsWith('/') ? 
                    this.pathConfig.basePath : 
                    this.pathConfig.basePath + '/';
                
                this.pathConfig.paths = this.selectedFiles.map(file => 
                    basePath + file.name
                );
                
                this.showSuccess('Rutas actualizadas', 'Se aplicó la ruta base a todos los archivos');
            },
            
            /**
             * Actualizar input file para reflejar la selección
             */
            updateFileInput() {
                const dataTransfer = new DataTransfer();
                this.selectedFiles.forEach(file => dataTransfer.items.add(file));
                this.$refs.fileInput.files = dataTransfer.files;
            },
            
            /**
             * Simular progreso de subida
             */
            simulateUploadProgress() {
                this.uploadProgress = 0;
                this.uploadError = false;
                
                const progressInterval = setInterval(() => {
                    if (this.uploadError) {
                        clearInterval(progressInterval);
                        return;
                    }
                    
                    const increment = Math.random() * 10;
                    this.uploadProgress = Math.min(this.uploadProgress + increment, 95);
                    
                    // Actualizar mensaje según progreso
                    if (this.uploadProgress < 25) {
                        this.uploadStatus = 'Validando archivos...';
                    } else if (this.uploadProgress < 50) {
                        this.uploadStatus = 'Subiendo archivos...';
                    } else if (this.uploadProgress < 75) {
                        this.uploadStatus = 'Procesando en el servidor...';
                    } else {
                        this.uploadStatus = 'Calculando hashes MD5...';
                    }
                }, 200);
                
                return progressInterval;
            },
            
            /**
             * Finalizar progreso de subida con éxito
             */
            completeUploadProgress() {
                this.uploadProgress = 100;
                this.uploadStatus = '¡Archivos subidos exitosamente!';
            },
            
            /**
             * Manejar error en upload
             */
            handleUploadError(error) {
                this.uploadError = true;
                this.uploadStatus = `Error: ${error}`;
            },
            
            /**
             * Enviar formulario para subir archivos
             */
            async submitFiles() {
                console.log('Enviando formulario de archivos...');
                
                if (this.selectedFiles.length === 0) {
                    this.showError('Formulario inválido', 'Selecciona al menos un archivo');
                    return;
                }
                
                // Confirmar antes de subir
                const confirmed = await this.showConfirmation(
                    '¿Subir archivos?',
                    `Se subirán ${this.selectedFiles.length} archivo(s)` +
                    `Tamaño total: ${this.totalFilesSize}`,
                    'Sí, subir'
                );
                
                if (!confirmed) return;
                
                this.uploading = true;
                const progressInterval = this.simulateUploadProgress();
                
                try {
                    // Preparar FormData
                    const formData = new FormData();
                    
                    // Agregar archivos
                    this.selectedFiles.forEach(file => {
                        formData.append('files', file);
                    });
                    
                    // Agregar rutas relativas
                    this.selectedFiles.forEach((file, index) => {
                        const relativePath = this.pathConfig.paths[index] || `bin/${file.name}`;
                        formData.append(`relative_path_${file.name}`, relativePath);
                    });
                    
                    console.log('Enviando datos:', {
                        files_count: this.selectedFiles.length,
                        total_size: this.selectedFiles.reduce((sum, file) => sum + file.size, 0)
                    });
                    
                    // Enviar petición
                    const response = await axios.post(this.urls.submit, formData, {
                        headers: {
                            'Content-Type': 'multipart/form-data'
                        },
                        timeout: 300000 // 5 minutos timeout
                    });
                    
                    clearInterval(progressInterval);
                    
                    if (response.status === 200) {
                        this.completeUploadProgress();
                        
                        this.showSuccess(
                            '¡Archivos subidos!',
                            `${this.selectedFiles.length} archivo(s) subido(s) exitosamente`
                        );
                        
                        // Emitir evento SocketIO si está conectado
                        if (this.isSocketConnected) {
                            this.emitSocket('files_uploaded', {
                                count: this.selectedFiles.length,
                                total_size: this.selectedFiles.reduce((sum, file) => sum + file.size, 0)
                            });
                        }
                        
                        // Redirigir después de un momento
                        setTimeout(() => {
                            window.location.href = '/admin/files';
                        }, 2000);
                    }
                    
                } catch (error) {
                    clearInterval(progressInterval);
                    console.error('Error subiendo archivos:', error);
                    
                    let errorMessage = 'Error inesperado al subir archivos';
                    
                    if (error.response) {
                        switch (error.response.status) {
                            case 400:
                                errorMessage = 'Datos del formulario inválidos';
                                break;
                            case 413:
                                errorMessage = 'Los archivos son demasiado grandes';
                                break;
                            case 422:
                                errorMessage = error.response.data?.message || 'Archivos no válidos';
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
                    
                    this.handleUploadError(errorMessage);
                    this.showError('Error al subir archivos', errorMessage);
                    
                } finally {
                    // No resetear uploading aquí para mantener el estado de progreso visible
                }
            },
            
            /**
             * Resetear formulario completo
             */
            resetForm() {
                this.form.versionId = '';
                this.selectedFiles = [];
                this.pathConfig.paths = [];
                this.errors = { version: '', files: '' };
                this.uploading = false;
                this.uploadProgress = 0;
                this.uploadError = false;
                this.$refs.fileInput.value = '';
                
                this.showInfo('Formulario reseteado', 'Puedes comenzar de nuevo');
            },
            
            /**
             * Manejar notificaciones desde SocketIO
             */
            handleSocketNotification(data) {
                // Llamar al método padre
                SocketMixin.methods.handleSocketNotification.call(this, data);
                
                // Manejar notificaciones específicas
                if (data.data && data.data.action) {
                    switch (data.data.action) {
                        case 'version_created':
                            // Nueva versión disponible, recargar lista
                            this.showInfo(
                                'Nueva versión disponible',
                                `La versión ${data.data.version} está disponible para subir archivos`
                            );
                            break;
                            
                        case 'files_conflict':
                            this.showWarning(
                                'Conflicto de archivos',
                                'Otro usuario está subiendo archivos para esta versión'
                            );
                            break;
                    }
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
             * Observar cambios en archivos seleccionados
             */
            selectedFiles: {
                handler(newFiles) {
                    console.log('Archivos seleccionados cambiados:', newFiles.length);
                    
                    // Sincronizar array de rutas con archivos
                    while (this.pathConfig.paths.length < newFiles.length) {
                        const file = newFiles[this.pathConfig.paths.length];
                        this.pathConfig.paths.push(`bin/${file.name}`);
                    }
                    
                    // Remover rutas excedentes
                    if (this.pathConfig.paths.length > newFiles.length) {
                        this.pathConfig.paths.splice(newFiles.length);
                    }
                },
                deep: true
            }
        }
    });
    
    // Exponer para debugging en desarrollo
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        window.uploadFilesApp = uploadFilesApp;
        console.log('✅ Upload Files app disponible en window.uploadFilesApp para debugging');
    }
    
    console.log('✅ Upload Files Vue.js inicializado exitosamente');
});