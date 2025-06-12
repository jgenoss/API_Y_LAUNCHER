document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 DOMContentLoaded - Iniciando Profile Vue.js');

    // ✅ VERIFICACIONES DE DEPENDENCIAS (igual que en dashboard.js y launcher.js)
    if (typeof Vue === 'undefined') {
        console.error('❌ Vue.js no está disponible');
        return;
    }
    console.log('✅ Vue.js disponible');

    const appElement = document.getElementById('profileApp');
    if (!appElement) {
        console.error('❌ Elemento #profileApp no encontrado en el DOM');
        return;
    }
    console.log('✅ Elemento #profileApp encontrado');

    if (typeof NotificationMixin === 'undefined') {
        console.error('❌ NotificationMixin no está disponible');
        return;
    }
    console.log('✅ Mixins disponibles');

    // ✅ CONFIGURAR DELIMITADORES GLOBALMENTE (igual que en el proyecto)
    Vue.config.delimiters = ['[[', ']]'];
    console.log('✅ Delimitadores Vue configurados: [[, ]]');

    console.log('🔧 Creando instancia Vue para Profile...');

    // ✅ CREAR INSTANCIA USANDO EL PATRÓN DEL PROYECTO
    const profileApp = new Vue({
        el: '#profileApp',
        delimiters: ['[[', ']]'], // ✅ IMPORTANTE: Consistente con tu proyecto
        mixins: [NotificationMixin, HttpMixin, UtilsMixin, SocketMixin], // ✅ Usar los mixins del proyecto
        
        data() {
            return {
                // ✅ Inicialización más robusta para evitar errores de undefined
                profile: {
                    id: null,
                    username: '',
                    email: '',
                    is_admin: false,
                    created_at: '',
                    last_login: null
                },
                passwordData: {
                    current_password: '',
                    new_password: '',
                    confirm_password: ''
                },
                activity: {
                    recent_actions: [],
                    session_info: {
                        ip_address: '',
                        current_session_start: '',
                        user_agent: ''
                    }
                },
                updating: false,
                changingPassword: false,
                passwordStrength: 0,
                // ✅ Estados de carga
                profileLoaded: false,
                activityLoaded: false,
                loading: false // ✅ Requerido por mixins
            };
        },

        computed: {
            passwordsMatch() {
                // ✅ Verificación más robusta
                if (!this.passwordData || !this.passwordData.new_password || !this.passwordData.confirm_password) {
                    return false;
                }
                return this.passwordData.new_password === this.passwordData.confirm_password;
            },
            
            passwordStrengthClass() {
                if (this.passwordStrength < 30) return 'strength-weak';
                if (this.passwordStrength < 70) return 'strength-medium';
                return 'strength-strong';
            },
            
            passwordStrengthText() {
                if (this.passwordStrength < 30) return 'Débil';
                if (this.passwordStrength < 70) return 'Media';
                return 'Fuerte';
            }
            
            // ✅ ELIMINADAS: isProfileReady e isActivityReady 
            // Usar directamente profileLoaded y activityLoaded en templates
        },

        mounted() {
            console.log('✅ Profile Vue montado');
            
            // ✅ Inicializar SocketIO usando el mixin del proyecto
            this.initSocket();
            
            // Cargar datos del perfil
            this.loadProfileData();
            this.loadActivity();
            
            console.log('Profile management inicializado correctamente');
        },

        methods: {
            async loadProfileData() {
                try {
                    console.log('📡 Cargando datos del perfil...');
                    this.loading = true; // ✅ Usar loading del mixin
                    
                    const response = await fetch('/admin/api/profile/data');
                    
                    if (!response.ok) {
                        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                    }
                    
                    const data = await response.json();
                    
                    if (data.success && data.profile) {
                        this.profile = {
                            ...this.profile, // Mantener estructura
                            ...data.profile  // Sobrescribir con datos reales
                        };
                        this.profileLoaded = true;
                        console.log('✅ Datos del perfil cargados:', this.profile);
                    } else {
                        throw new Error(data.error || 'Error desconocido cargando perfil');
                    }
                } catch (error) {
                    console.error('❌ Error loading profile:', error);
                    // ✅ Usar el sistema de notificaciones del mixin
                    this.showError('Error cargando perfil', error.message);
                    this.profileLoaded = false;
                } finally {
                    this.loading = false;
                }
            },

            async loadActivity() {
                try {
                    console.log('📡 Cargando actividad del usuario...');
                    const response = await fetch('/admin/api/profile/activity');
                    
                    if (!response.ok) {
                        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                    }
                    
                    const data = await response.json();
                    
                    if (data.success && data.activity) {
                        this.activity = {
                            ...this.activity, // Mantener estructura
                            ...data.activity  // Sobrescribir con datos reales
                        };
                        this.activityLoaded = true;
                        console.log('✅ Actividad cargada:', this.activity);
                    } else {
                        console.log('⚠️ No se pudo cargar actividad:', data.error);
                        // No mostrar error para actividad, no es crítico
                        this.activityLoaded = true; // Marcar como cargado aunque falle
                    }
                } catch (error) {
                    console.error('❌ Error loading activity:', error);
                    // No mostrar error al usuario para actividad
                    this.activityLoaded = true; // Marcar como cargado aunque falle
                }
            },

            async updateProfile() {
                if (this.updating) return;
                
                this.updating = true;
                
                try {
                    const response = await fetch('/admin/api/profile/update', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({
                            username: this.profile.username,
                            email: this.profile.email
                        })
                    });
                    
                    const data = await response.json();
                    
                    if (data.success) {
                        // ✅ Usar sistema de notificaciones del mixin
                        this.showSuccess('Perfil actualizado', data.message);
                        // Actualizar datos locales
                        this.profile.username = data.profile.username;
                        this.profile.email = data.profile.email;
                    } else {
                        this.showError('Error actualizando perfil', data.error);
                    }
                    
                } catch (error) {
                    console.error('Error updating profile:', error);
                    this.showError('Error de conexión', 'No se pudo conectar con el servidor');
                } finally {
                    this.updating = false;
                }
            },

            async changePassword() {
                if (this.changingPassword || !this.passwordsMatch) return;
                
                this.changingPassword = true;
                
                try {
                    const response = await fetch('/admin/api/profile/change-password', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify(this.passwordData)
                    });
                    
                    const data = await response.json();
                    
                    if (data.success) {
                        // ✅ Usar sistema de notificaciones del mixin
                        this.showSuccess('Contraseña actualizada', data.message);
                        // Limpiar formulario
                        this.passwordData = {
                            current_password: '',
                            new_password: '',
                            confirm_password: ''
                        };
                        this.passwordStrength = 0;
                    } else {
                        this.showError('Error cambiando contraseña', data.error);
                    }
                    
                } catch (error) {
                    console.error('Error changing password:', error);
                    this.showError('Error de conexión', 'No se pudo conectar con el servidor');
                } finally {
                    this.changingPassword = false;
                }
            },

            checkPasswordStrength() {
                const password = this.passwordData.new_password;
                let strength = 0;
                
                // Longitud
                if (password.length >= 6) strength += 20;
                if (password.length >= 8) strength += 20;
                
                // Mayúsculas
                if (/[A-Z]/.test(password)) strength += 20;
                
                // Minúsculas
                if (/[a-z]/.test(password)) strength += 10;
                
                // Números
                if (/[0-9]/.test(password)) strength += 20;
                
                // Caracteres especiales
                if (/[^A-Za-z0-9]/.test(password)) strength += 10;
                
                this.passwordStrength = Math.min(strength, 100);
            },

            formatDate(dateString) {
                // ✅ Manejo robusto de fechas
                if (!dateString || dateString === '' || dateString === 'null' || dateString === 'undefined') {
                    return 'N/A';
                }
                
                try {
                    const date = new Date(dateString);
                    
                    // Verificar que la fecha sea válida
                    if (isNaN(date.getTime())) {
                        return 'Fecha inválida';
                    }
                    
                    return date.toLocaleString('es-ES', {
                        year: 'numeric',
                        month: 'long',
                        day: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit'
                    });
                } catch (error) {
                    console.error('Error formatting date:', error);
                    return 'Error en fecha';
                }
            },

            getUserAgent(userAgent) {
                // ✅ Manejo robusto de user agent
                if (!userAgent || userAgent === '' || userAgent === 'null' || userAgent === 'undefined') {
                    return 'Desconocido';
                }
                
                try {
                    // Simplificar user agent
                    if (userAgent.includes('Chrome')) return 'Google Chrome';
                    if (userAgent.includes('Firefox')) return 'Mozilla Firefox';
                    if (userAgent.includes('Safari')) return 'Safari';
                    if (userAgent.includes('Edge')) return 'Microsoft Edge';
                    
                    return 'Otro navegador';
                } catch (error) {
                    console.error('Error parsing user agent:', error);
                    return 'Desconocido';
                }
            }

            // ✅ NOTA: Los métodos showSuccess, showError, etc. vienen del NotificationMixin
            // No necesito definirlos aquí
        }
    });

    // ✅ EXPONER PARA DEBUGGING (igual que en launcher.js)
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        window.profileApp = profileApp;
        console.log('✅ Profile app disponible en window.profileApp para debugging');
    }

    console.log('✅ Profile Vue.js inicializado exitosamente');
});