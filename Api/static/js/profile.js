/**
 * profile.js - Lógica Vue.js para gestión del perfil de usuario
 * VERSIÓN CORREGIDA - Manejo robusto de inicialización
 */

// ✅ IMPLEMENTAR INICIALIZACIÓN MÁS ROBUSTA
function initializeProfileApp() {
    console.log('🚀 Iniciando Profile Vue.js con validaciones robustas');

    // ✅ VERIFICACIÓN 1: Vue.js disponible
    if (typeof Vue === 'undefined') {
        console.error('❌ Vue.js no está disponible');
        // Reintentar después de un delay
        setTimeout(initializeProfileApp, 500);
        return;
    }
    console.log('✅ Vue.js disponible');

    // ✅ VERIFICACIÓN 2: Elemento DOM existe
    const appElement = document.getElementById('profileApp');
    if (!appElement) {
        console.error('❌ Elemento #profileApp no encontrado en el DOM');
        // Reintentar después de un delay
        setTimeout(initializeProfileApp, 500);
        return;
    }
    console.log('✅ Elemento #profileApp encontrado');

    // ✅ VERIFICACIÓN 3: Mixins disponibles
    if (typeof NotificationMixin === 'undefined' ||
        typeof HttpMixin === 'undefined' ||
        typeof UtilsMixin === 'undefined' ||
        typeof SocketMixin === 'undefined') {
        console.error('❌ Mixins no están disponibles');
        // Reintentar después de un delay
        setTimeout(initializeProfileApp, 500);
        return;
    }
    console.log('✅ Mixins disponibles');

    // ✅ CONFIGURAR DELIMITADORES GLOBALMENTE
    Vue.config.delimiters = ['[[', ']]'];
    Vue.config.silent = false; // Para debugging
    console.log('✅ Delimitadores Vue configurados: [[, ]]');

    console.log('🔧 Creando instancia Vue para Profile...');

    try {
        // ✅ CREAR INSTANCIA USANDO EL PATRÓN DEL PROYECTO
        const profileApp = new Vue({
            el: '#profileApp',
            delimiters: ['[[', ']]'],
            mixins: [NotificationMixin, HttpMixin, UtilsMixin, SocketMixin],

            data() {
                return {
                    // ✅ INICIALIZACIÓN COMPLETA Y ROBUSTA
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
                    loading: false, // Controla el overlay de carga global
                    loadingMessage: 'Cargando...',

                    // ✅ ESTADOS DE CARGA - INICIALIZADOS COMO FALSE
                    profileLoaded: false,
                    activityLoaded: false,
                    updating: false,
                    changingPassword: false,
                    passwordStrength: 0,

                    // ✅ ESTADOS DE ERROR
                    profileError: null,
                    activityError: null
                };
            },

            computed: {
                passwordsMatch() {
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
            },

            // ✅ LIFECYCLE HOOKS CON MANEJO DE ERRORES
            mounted() {
                console.log('✅ Profile Vue montado correctamente');

                try {
                    // Inicializar SocketIO usando el mixin del proyecto
                    this.initSocket();

                    // Cargar datos del perfil con delay para asegurar que todo esté listo
                    setTimeout(() => {
                        this.loadProfileData();
                        this.loadActivity();
                    }, 100);

                    console.log('✅ Profile management inicializado correctamente');
                } catch (error) {
                    console.error('❌ Error durante mounted:', error);
                    this.profileError = 'Error durante la inicialización';
                }
            },

            methods: {
                setLoading(isLoading, message = 'Cargando...') {
                    this.loading = isLoading;
                    this.loadingMessage = message;
                },
                async loadProfileData() {
                    try {
                        this.setLoading(true, 'Cargando datos del dashboard...');
                        console.log('📡 Cargando datos del perfil...');
                        this.loading = false;
                        this.profileError = null;

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
                        this.profileError = error.message;
                        this.showError('Error cargando perfil', error.message);
                        this.profileLoaded = false;
                    } finally {
                        this.loading = false;
                        this.setLoading(false);
                    }
                },

                async loadActivity() {
                    try {
                        console.log('📡 Cargando actividad del usuario...');
                        this.activityError = null;

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
                            this.activityLoaded = true; // Marcar como cargado aunque no haya datos
                        }
                    } catch (error) {
                        console.error('❌ Error loading activity:', error);
                        this.activityError = error.message;
                        this.activityLoaded = true; // Marcar como cargado para evitar estado de carga infinito
                    }
                },

                async updateProfile() {
                    if (this.updating) return;

                    try {
                        this.updating = true;

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
                            this.showSuccess('Perfil actualizado', 'Los datos del perfil se han actualizado correctamente');
                        } else {
                            throw new Error(data.error || 'Error actualizando perfil');
                        }
                    } catch (error) {
                        console.error('❌ Error updating profile:', error);
                        this.showError('Error actualizando perfil', error.message);
                    } finally {
                        this.updating = false;
                    }
                },

                async changePassword() {
                    if (this.changingPassword || !this.passwordsMatch) return;

                    try {
                        this.changingPassword = true;

                        const response = await fetch('/admin/api/profile/change-password', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json'
                            },
                            body: JSON.stringify({
                                current_password: this.passwordData.current_password,
                                new_password: this.passwordData.new_password
                            })
                        });

                        const data = await response.json();

                        if (data.success) {
                            this.showSuccess('Contraseña cambiada', 'La contraseña se ha actualizado correctamente');
                            // Limpiar formulario
                            this.passwordData = {
                                current_password: '',
                                new_password: '',
                                confirm_password: ''
                            };
                            this.passwordStrength = 0;
                        } else {
                            throw new Error(data.error || 'Error cambiando contraseña');
                        }
                    } catch (error) {
                        console.error('❌ Error changing password:', error);
                        this.showError('Error cambiando contraseña', error.message);
                    } finally {
                        this.changingPassword = false;
                    }
                },

                checkPasswordStrength() {
                    const password = this.passwordData.new_password;
                    if (!password) {
                        this.passwordStrength = 0;
                        return;
                    }

                    let strength = 0;

                    // Longitud
                    if (password.length >= 8) strength += 25;
                    if (password.length >= 12) strength += 15;

                    // Caracteres
                    if (/[a-z]/.test(password)) strength += 10;
                    if (/[A-Z]/.test(password)) strength += 10;
                    if (/[0-9]/.test(password)) strength += 10;
                    if (/[^A-Za-z0-9]/.test(password)) strength += 10;

                    this.passwordStrength = Math.min(strength, 100);
                },

                formatDate(dateString) {
                    if (!dateString || dateString === '' || dateString === 'null' || dateString === 'undefined') {
                        return 'N/A';
                    }

                    try {
                        const date = new Date(dateString);

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
                    if (!userAgent || userAgent === '' || userAgent === 'null' || userAgent === 'undefined') {
                        return 'Desconocido';
                    }

                    try {
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
            }
        });

        // ✅ EXPONER PARA DEBUGGING EN DESARROLLO
        if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
            window.profileApp = profileApp;
            console.log('✅ Profile app disponible en window.profileApp para debugging');
        }

        console.log('✅ Profile Vue.js inicializado exitosamente');

    } catch (error) {
        console.error('❌ Error crítico creando instancia Vue:', error);

        // Mostrar error al usuario
        const errorDiv = document.createElement('div');
        errorDiv.className = 'alert alert-danger m-3';
        errorDiv.innerHTML = `
            <h5><i class="fas fa-exclamation-triangle"></i> Error de Inicialización</h5>
            <p>No se pudo inicializar la aplicación de perfil. Por favor, recarga la página.</p>
            <small>Error técnico: ${error.message}</small>
        `;

        const appElement = document.getElementById('profileApp');
        if (appElement) {
            appElement.innerHTML = '';
            appElement.appendChild(errorDiv);
        }
    }
}

// ✅ MÚLTIPLES ESTRATEGIAS DE INICIALIZACIÓN
document.addEventListener('DOMContentLoaded', initializeProfileApp);

// ✅ FALLBACK: Si DOMContentLoaded ya pasó
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeProfileApp);
} else if (document.readyState === 'interactive' || document.readyState === 'complete') {
    // DOM ya está listo
    setTimeout(initializeProfileApp, 100);
}

// ✅ ÚLTIMO RECURSO: Inicializar después de window.onload
window.addEventListener('load', function () {
    // Solo inicializar si no se ha hecho ya
    if (!window.profileApp) {
        setTimeout(initializeProfileApp, 200);
    }
});