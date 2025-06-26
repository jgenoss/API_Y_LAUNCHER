/**
 * create_message.js - Lógica Vue.js para crear nuevo mensaje
 * Separado completamente del template HTML
 */

document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 DOMContentLoaded - Iniciando Create Message Vue.js');
    
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
    if (typeof window.CREATE_MESSAGE_DATA === 'undefined') {
        console.error('❌ CREATE_MESSAGE_DATA no está disponible');
        window.CREATE_MESSAGE_DATA = {
            urls: {},
            urlParams: {}
        };
    }
    
    console.log('✅ Todas las dependencias disponibles');
    console.log('📨 Datos de creación de mensaje:', window.CREATE_MESSAGE_DATA);
    
    // Configurar delimitadores de Vue
    Vue.config.delimiters = ['[[', ']]'];
    
    // Templates predefinidos para diferentes tipos de mensaje
    const messageTemplates = {
        update: {
            type: 'Actualización',
            message: 'Nueva versión disponible con mejoras de rendimiento y corrección de errores. ¡Actualiza ahora para obtener la mejor experiencia de juego!',
            priority: 4
        },
        maintenance: {
            type: 'Mantenimiento',
            message: 'Mantenimiento programado del servidor el [FECHA] de [HORA] a [HORA]. El juego no estará disponible durante este período.',
            priority: 3
        },
        event: {
            type: 'Evento',
            message: '¡Evento especial este fin de semana! Participa y gana recompensas exclusivas. No te pierdas esta oportunidad única.',
            priority: 4
        },
        news: {
            type: 'Noticia',
            message: 'Descubre las últimas novedades del juego. Nuevos contenidos, características y mejoras están llegando pronto.',
            priority: 2
        },
        promotion: {
            type: 'Promoción',
            message: '¡Oferta especial por tiempo limitado! Obtén descuentos en objetos premium y mejora tu experiencia de juego.',
            priority: 3
        }
    };
    
    // Crear instancia Vue para Create Message
    const createMessageApp = new Vue({
        el: '#app',
        delimiters: ['[[', ']]'],
        mixins: [NotificationMixin, HttpMixin, UtilsMixin, SocketMixin],
        
        data() {
            return {
                // Formulario
                form: {
                    type: '',
                    message: '',
                    priority: 3,
                    isActive: true
                },
                
                // Validación
                errors: {},
                
                // Estados
                submitting: false,
                
                // Datos del servidor
                urls: window.CREATE_MESSAGE_DATA.urls || {},
                
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
                return this.form.type.trim() !== '' && 
                       this.form.message.trim() !== '' && 
                       this.form.message.length <= 500 &&
                       this.form.priority >= 1 && 
                       this.form.priority <= 5 &&
                       Object.keys(this.errors).length === 0;
            },
            
            /**
             * Vista previa JSON del mensaje
             */
            jsonPreview() {
                return JSON.stringify({
                    type: this.form.type || '',
                    message: this.form.message || ''
                }, null, 2);
            }
        },
        
        mounted() {
            console.log('✅ Create Message Vue montado');
            
            // Inicializar SocketIO
            this.initSocket();
            
            // Cargar parámetros de URL si existen (para duplicar mensaje)
            this.loadUrlParams();
            
            // Focus en el campo de tipo
            this.$nextTick(() => {
                const typeSelect = this.$el.querySelector('select[id="type"]');
                if (typeSelect) {
                    typeSelect.focus();
                }
            });
            
            console.log('Create Message inicializado correctamente');
        },
        
        methods: {
            /**
             * Cargar parámetros de URL para pre-llenar el formulario
             */
            loadUrlParams() {
                const params = window.CREATE_MESSAGE_DATA.urlParams || {};
                
                if (params.type) {
                    this.form.type = params.type;
                }
                if (params.message) {
                    this.form.message = params.message;
                }
                if (params.priority) {
                    this.form.priority = parseInt(params.priority);
                }
                
                console.log('Parámetros de URL cargados:', params);
            },
            
            /**
             * Usar plantilla predefinida
             */
            useTemplate(templateKey) {
                const template = messageTemplates[templateKey];
                if (!template) {
                    console.error('Template no encontrado:', templateKey);
                    return;
                }
                
                this.form.type = template.type;
                this.form.message = template.message;
                this.form.priority = template.priority;
                
                // Limpiar errores
                this.errors = {};
                
                this.showInfo('Plantilla aplicada', `Plantilla "${templateKey}" cargada exitosamente`);
            },
            
            /**
             * Limpiar formulario
             */
            clearForm() {
                this.form = {
                    type: '',
                    message: '',
                    priority: 3,
                    isActive: true
                };
                this.errors = {};
                
                this.showInfo('Formulario limpiado', 'El formulario ha sido reiniciado');
            },
            
            /**
             * Validar campo específico
             */
            validateField(field) {
                const newErrors = { ...this.errors };
                
                switch (field) {
                    case 'type':
                        if (!this.form.type.trim()) {
                            newErrors.type = 'El tipo de mensaje es obligatorio';
                        } else {
                            delete newErrors.type;
                        }
                        break;
                        
                    case 'message':
                        if (!this.form.message.trim()) {
                            newErrors.message = 'El mensaje es obligatorio';
                        } else if (this.form.message.length > 500) {
                            newErrors.message = 'El mensaje no puede exceder 500 caracteres';
                        } else {
                            delete newErrors.message;
                        }
                        break;
                        
                    case 'priority':
                        if (this.form.priority < 1 || this.form.priority > 5) {
                            newErrors.priority = 'La prioridad debe estar entre 1 y 5';
                        } else {
                            delete newErrors.priority;
                        }
                        break;
                }
                
                this.errors = newErrors;
            },
            
            /**
             * Validar todo el formulario
             */
            validateForm() {
                this.validateField('type');
                this.validateField('message');
                this.validateField('priority');
                
                return Object.keys(this.errors).length === 0;
            },
            
            /**
             * Obtener clase CSS para el contador de caracteres
             */
            getCharCountClass() {
                const length = this.form.message.length;
                
                if (length > 450) {
                    return 'text-danger fw-bold';
                } else if (length > 400) {
                    return 'text-warning fw-bold';
                } else {
                    return 'text-muted';
                }
            },
            
            /**
             * Obtener icono para la vista previa según el tipo
             */
            getPreviewIcon() {
                if (this.form.type === 'Actualización') {
                    return '/static/hot.gif';
                }
                return '/static/new.gif';
            },
            
            /**
             * Obtener texto para la vista previa
             */
            getPreviewText() {
                if (this.form.message.trim()) {
                    return this.form.message;
                }
                return 'Escribe tu mensaje para ver la vista previa';
            },
            
            /**
             * Obtener clase CSS para el texto de la vista previa
             */
            getPreviewTextClass() {
                if (this.form.message.trim()) {
                    return 'message-content small';
                }
                return 'message-content small text-muted';
            },
            
            /**
             * Enviar formulario para crear mensaje
             */
            async submitMessage() {
                console.log('Enviando formulario de mensaje...');
                
                // Validación final
                if (!this.validateForm()) {
                    this.showError('Formulario inválido', 'Por favor corrige los errores antes de continuar');
                    return;
                }
                
                this.submitting = true;
                
                try {
                    // Confirmar antes de crear
                    const confirmed = await this.showConfirmation(
                        '¿Crear nuevo mensaje?',
                        `Se creará un mensaje de tipo "${this.form.type}"${this.form.isActive ? ' y se activará inmediatamente' : ''}.`,
                        'Sí, crear'
                    );
                    
                    if (!confirmed) {
                        this.submitting = false;
                        return;
                    }
                    
                    // Preparar datos
                    const formData = new FormData();
                    formData.append('type', this.form.type);
                    formData.append('message', this.form.message);
                    formData.append('priority', this.form.priority);
                    if (this.form.isActive) {
                        formData.append('is_active', 'on');
                    }
                    
                    console.log('Enviando datos:', {
                        type: this.form.type,
                        message: this.form.message,
                        priority: this.form.priority,
                        is_active: this.form.isActive
                    });
                    
                    // Enviar petición
                    const response = await axios.post(this.urls.createMessage || window.location.href, formData, {
                        headers: {
                            'Content-Type': 'multipart/form-data'
                        }
                    });
                    
                    if (response.status === 200) {
                        this.showSuccess(
                            '¡Mensaje creado!', 
                            `El mensaje "${this.form.type}" ha sido creado exitosamente`
                        );
                        
                        // Emitir evento SocketIO si está conectado
                        if (this.isSocketConnected) {
                            this.emitSocket('message_created', {
                                type: this.form.type,
                                is_active: this.form.isActive,
                                priority: this.form.priority
                            });
                        }
                        
                        // Redirigir después de un momento
                        setTimeout(() => {
                            window.location.href = this.urls.messages || '/admin/messages';
                        }, 1500);
                    }
                    
                } catch (error) {
                    console.error('Error creando mensaje:', error);
                    
                    let errorMessage = 'Error inesperado al crear el mensaje';
                    
                    if (error.response) {
                        // Error del servidor
                        switch (error.response.status) {
                            case 400:
                                errorMessage = 'Datos del formulario inválidos';
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
                    
                    this.showError('Error al crear mensaje', errorMessage);
                    
                } finally {
                    this.submitting = false;
                }
            },
            
            /**
             * Manejar notificaciones desde SocketIO
             */
            handleSocketNotification(data) {
                // Llamar al método padre
                SocketMixin.methods.handleSocketNotification.call(this, data);
                
                // Manejar notificaciones específicas si es necesario
                if (data.data && data.data.action === 'message_conflict') {
                    this.showWarning(
                        'Conflicto de mensaje', 
                        'Otro mensaje fue creado mientras editabas. Verifica los datos.'
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
             * Observar cambios en los campos para validación en tiempo real
             */
            'form.type'(newValue) {
                if (newValue) {
                    this.validateField('type');
                }
            },
            
            'form.message'(newValue) {
                // Debounce para evitar validación excesiva
                clearTimeout(this.messageValidationTimeout);
                this.messageValidationTimeout = setTimeout(() => {
                    this.validateField('message');
                }, 300);
            },
            
            'form.priority'(newValue) {
                if (newValue) {
                    this.validateField('priority');
                }
            }
        }
    });
    
    // Exponer para debugging en desarrollo
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        window.createMessageApp = createMessageApp;
        console.log('✅ Create Message app disponible en window.createMessageApp para debugging');
    }
    
    console.log('✅ Create Message Vue.js inicializado exitosamente');
});