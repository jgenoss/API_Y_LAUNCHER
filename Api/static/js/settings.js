/**
 * settings.js - Lógica Vue.js para Configuración del Sistema
 * Separado completamente del template HTML
 */

document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 DOMContentLoaded - Iniciando Settings Vue.js');
    
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
    
    // Crear instancia Vue para Settings
    const settingsApp = new Vue({
        el: '#app',
        delimiters: ['[[', ']]'],
        mixins: [NotificationMixin, HttpMixin, UtilsMixin, SocketMixin],
        
        data() {
            return {
                // Navegación
                currentCategory: 'general',
                categories: [
                    { id: 'general', name: 'General', icon: 'bi bi-gear' },
                    { id: 'launcher', name: 'Launcher', icon: 'bi bi-app' },
                    { id: 'files', name: 'Archivos', icon: 'bi bi-file-earmark' },
                    { id: 'security', name: 'Seguridad', icon: 'bi bi-shield-check' },
                    { id: 'maintenance', name: 'Mantenimiento', icon: 'bi bi-tools' },
                    { id: 'notifications', name: 'Notificaciones', icon: 'bi bi-bell' }
                ],
                
                // Configuraciones reactivas
                settings: {
                    general: {
                        siteName: 'Launcher Admin Panel',
                        adminEmail: 'admin@localhost',
                        timezone: 'America/Mexico_City',
                        language: 'es',
                        maintenanceMode: false,
                        debugMode: false
                    },
                    launcher: {
                        launcherUrl: 'http://localhost:5000/Launcher/',
                        updateCheckInterval: 300,
                        maxRetries: 3,
                        connectionTimeout: 30,
                        autoUpdate: true,
                        forceSSL: false
                    },
                    files: {
                        maxFileSize: 500,
                        maxTotalSize: 5000,
                        allowedExtensions: '.exe, .dll, .xml, .json, .txt, .zip, .png, .jpg, .gif',
                        autoMD5: true,
                        compressUploads: false
                    },
                    security: {
                        sessionTimeout: 24,
                        maxLoginAttempts: 5,
                        downloadRateLimit: 100,
                        ipBanDuration: 60,
                        allowedIPs: '',
                        enableRateLimit: true,
                        logAllRequests: true
                    },
                    maintenance: {
                        backupInterval: 24,
                        backupRetention: 30,
                        logRetention: 30,
                        logLevel: 'INFO',
                        autoBackup: true,
                        autoCleanup: true
                    },
                    notifications: {
                        webhookUrl: '',
                        alertEmail: '',
                        alertLevel: 'ERROR',
                        notifyNewVersion: true,
                        notifyErrors: true,
                        notifyHighTraffic: false
                    }
                },
                
                // Configuraciones por defecto (para reset)
                defaultSettings: null,
                
                // Estados
                loading: false,
                saving: false,
                hasChanges: false,
                loadingMessage: 'Cargando...',
                
                // Auto-save
                autoSaveTimeout: null,
                autoSaveEnabled: true,
                
                // SocketIO (gestionado por SocketMixin)
                isSocketConnected: false,
                socket: null
            };
        },
        
        computed: {
            /**
             * Verificar si hay cambios sin guardar
             */
            hasUnsavedChanges() {
                return this.hasChanges;
            },
            
            /**
             * Obtener configuración de la categoría actual
             */
            currentCategorySettings() {
                return this.settings[this.currentCategory] || {};
            },
            
            /**
             * Validar configuraciones actuales
             */
            isConfigurationValid() {
                // Validaciones básicas
                const general = this.settings.general;
                if (!general.siteName || !general.adminEmail) return false;
                
                const launcher = this.settings.launcher;
                if (!launcher.launcherUrl || launcher.updateCheckInterval < 60) return false;
                
                const files = this.settings.files;
                if (files.maxFileSize < 1 || files.maxTotalSize < 100) return false;
                
                const security = this.settings.security;
                if (security.sessionTimeout < 1 || security.maxLoginAttempts < 3) return false;
                
                return true;
            }
        },
        
        mounted() {
            console.log('✅ Settings Vue montado');
            
            // Inicializar SocketIO
            this.initSocket();
            
            // Cargar configuraciones desde el servidor
            this.loadSettings();
            
            // Crear copia de configuraciones por defecto
            this.createDefaultSettingsCopy();
            
            // Configurar auto-save
            this.setupAutoSave();
            
            // Warning al salir con cambios sin guardar
            this.setupBeforeUnloadWarning();
            
            console.log('Settings management inicializado correctamente');
        },
        
        beforeDestroy() {
            // Limpiar timeout de auto-save
            if (this.autoSaveTimeout) {
                clearTimeout(this.autoSaveTimeout);
            }
            
            // Remover warning de unload
            window.removeEventListener('beforeunload', this.beforeUnloadHandler);
        },
        
        methods: {
            /**
             * Cargar configuraciones desde el servidor
             */
            async loadSettings() {
                this.setLoading(true, 'Cargando configuraciones...');
                
                try {
                    // Aquí harías la petición real al servidor
                    // const data = await this.apiGet('/admin/api/settings');
                    // this.settings = { ...this.settings, ...data };
                    
                    // Por ahora, simular carga
                    await new Promise(resolve => setTimeout(resolve, 1000));
                    
                    console.log('✅ Configuraciones cargadas desde el servidor');
                    
                } catch (error) {
                    this.showError('Error', 'No se pudieron cargar las configuraciones');
                    console.error('Error loading settings:', error);
                } finally {
                    this.setLoading(false);
                }
            },
            
            /**
             * Crear copia de configuraciones por defecto
             */
            createDefaultSettingsCopy() {
                this.defaultSettings = JSON.parse(JSON.stringify(this.settings));
            },
            
            /**
             * Configurar auto-save
             */
            setupAutoSave() {
                if (!this.autoSaveEnabled) return;
                
                // Auto-save cada 30 segundos si hay cambios
                setInterval(() => {
                    if (this.hasChanges && !this.saving) {
                        console.log('🔄 Auto-guardado de configuraciones...');
                        this.saveSettings(true); // true = silent save
                    }
                }, 30000);
            },
            
            /**
             * Configurar warning antes de salir
             */
            setupBeforeUnloadWarning() {
                this.beforeUnloadHandler = (e) => {
                    if (this.hasChanges) {
                        e.preventDefault();
                        e.returnValue = '¿Estás seguro de que quieres salir? Hay cambios sin guardar.';
                        return e.returnValue;
                    }
                };
                
                window.addEventListener('beforeunload', this.beforeUnloadHandler);
            },
            
            /**
             * Cambiar categoría activa
             */
            showCategory(categoryId) {
                if (this.categories.find(cat => cat.id === categoryId)) {
                    this.currentCategory = categoryId;
                    console.log(`📂 Cambiando a categoría: ${categoryId}`);
                    
                    // Emitir evento SocketIO si está conectado
                    if (this.isSocketConnected) {
                        this.emitSocket('settings_category_changed', {
                            category: categoryId
                        });
                    }
                }
            },
            
            /**
             * Marcar como cambio no guardado
             */
            markAsChanged() {
                this.hasChanges = true;
                
                // Restart auto-save timeout
                if (this.autoSaveTimeout) {
                    clearTimeout(this.autoSaveTimeout);
                }
                
                if (this.autoSaveEnabled) {
                    this.autoSaveTimeout = setTimeout(() => {
                        if (this.hasChanges && !this.saving) {
                            this.saveSettings(true); // Auto-save silencioso
                        }
                    }, 5000); // Auto-save después de 5 segundos de inactividad
                }
            },
            
            /**
             * Guardar configuraciones
             */
            async saveSettings(silent = false) {
                if (!this.isConfigurationValid) {
                    this.showError('Configuración inválida', 'Por favor corrige los errores antes de guardar');
                    return;
                }
                
                // Confirmar si no es silencioso y hay cambios críticos
                if (!silent && this.hasCriticalChanges()) {
                    const confirmed = await this.showConfirmation(
                        '¿Guardar configuración?',
                        'Algunos cambios requieren reiniciar el servidor. ¿Continuar?',
                        'Sí, guardar'
                    );
                    
                    if (!confirmed) return;
                }
                
                this.saving = true;
                if (!silent) this.setLoading(true, 'Guardando configuraciones...');
                
                try {
                    // Preparar datos para envío
                    const settingsToSave = {
                        ...this.settings,
                        timestamp: new Date().toISOString(),
                        updated_by: 'current_user' // Se reemplazaría con el usuario actual
                    };
                    
                    console.log('💾 Guardando configuraciones:', settingsToSave);
                    
                    // Aquí harías la petición real al servidor
                    // await this.apiPost('/admin/api/settings', settingsToSave);
                    
                    // Simular guardado
                    await new Promise(resolve => setTimeout(resolve, 2000));
                    
                    this.hasChanges = false;
                    
                    if (!silent) {
                        this.showSuccess(
                            '¡Configuración guardada!', 
                            'Todos los cambios han sido aplicados exitosamente'
                        );
                    }
                    
                    // Emitir evento SocketIO
                    if (this.isSocketConnected) {
                        this.emitSocket('settings_saved', {
                            categories: Object.keys(this.settings),
                            timestamp: new Date().toISOString()
                        });
                    }
                    
                    console.log('✅ Configuraciones guardadas exitosamente');
                    
                } catch (error) {
                    console.error('Error guardando configuraciones:', error);
                    
                    if (!silent) {
                        let errorMessage = 'Error inesperado al guardar la configuración';
                        
                        if (error.response) {
                            switch (error.response.status) {
                                case 400:
                                    errorMessage = 'Datos de configuración inválidos';
                                    break;
                                case 403:
                                    errorMessage = 'No tienes permisos para cambiar la configuración';
                                    break;
                                case 422:
                                    errorMessage = error.response.data?.message || 'Configuración inválida';
                                    break;
                                default:
                                    errorMessage = error.response.data?.message || 'Error del servidor';
                            }
                        }
                        
                        this.showError('Error al guardar', errorMessage);
                    }
                    
                } finally {
                    this.saving = false;
                    if (!silent) this.setLoading(false);
                }
            },
            
            /**
             * Verificar si hay cambios críticos que requieren reinicio
             */
            hasCriticalChanges() {
                const current = this.settings;
                const defaults = this.defaultSettings;
                
                // Cambios críticos que requieren reinicio
                const criticalPaths = [
                    'general.maintenanceMode',
                    'general.debugMode',
                    'launcher.launcherUrl',
                    'launcher.forceSSL',
                    'security.enableRateLimit',
                    'security.sessionTimeout'
                ];
                
                return criticalPaths.some(path => {
                    const [category, setting] = path.split('.');
                    return current[category][setting] !== defaults[category][setting];
                });
            },
            
            /**
             * Restaurar categoría actual a valores por defecto
             */
            async resetCurrentCategory() {
                const categoryName = this.categories.find(cat => cat.id === this.currentCategory)?.name || this.currentCategory;
                
                const confirmed = await this.showConfirmation(
                    'Restaurar configuración',
                    `¿Restaurar la configuración de "${categoryName}" a los valores por defecto?`,
                    'Sí, restaurar'
                );
                
                if (!confirmed) return;
                
                try {
                    // Restaurar solo la categoría actual
                    if (this.defaultSettings && this.defaultSettings[this.currentCategory]) {
                        this.settings[this.currentCategory] = { 
                            ...this.defaultSettings[this.currentCategory] 
                        };
                    }
                    
                    this.markAsChanged();
                    
                    this.showSuccess(
                        'Configuración restaurada', 
                        `La configuración de "${categoryName}" ha sido restaurada`
                    );
                    
                    console.log(`🔄 Categoría ${this.currentCategory} restaurada a valores por defecto`);
                    
                } catch (error) {
                    this.showError('Error', 'No se pudo restaurar la configuración');
                    console.error('Error resetting category:', error);
                }
            },
            
            /**
             * Restaurar todas las configuraciones a valores por defecto
             */
            async resetToDefaults() {
                const confirmed = await this.showConfirmation(
                    'Restaurar TODA la configuración',
                    '¿Estás seguro de que quieres restaurar TODA la configuración a los valores por defecto? Esta acción no se puede deshacer.',
                    'Sí, restaurar todo'
                );
                
                if (!confirmed) return;
                
                try {
                    if (this.defaultSettings) {
                        this.settings = JSON.parse(JSON.stringify(this.defaultSettings));
                    }
                    
                    this.markAsChanged();
                    
                    this.showSuccess(
                        'Configuración restaurada', 
                        'Toda la configuración ha sido restaurada a valores por defecto'
                    );
                    
                    console.log('🔄 Toda la configuración restaurada a valores por defecto');
                    
                } catch (error) {
                    this.showError('Error', 'No se pudo restaurar la configuración');
                    console.error('Error resetting all settings:', error);
                }
            },
            
            /**
             * Exportar configuraciones como JSON
             */
            exportSettings() {
                try {
                    const exportData = {
                        settings: this.settings,
                        metadata: {
                            exported_at: new Date().toISOString(),
                            version: '1.0.0',
                            source: 'Launcher Admin Panel'
                        }
                    };
                    
                    const blob = new Blob([JSON.stringify(exportData, null, 2)], { 
                        type: 'application/json' 
                    });
                    
                    const url = window.URL.createObjectURL(blob);
                    const link = document.createElement('a');
                    link.href = url;
                    link.download = `launcher_settings_${new Date().toISOString().split('T')[0]}.json`;
                    
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                    
                    window.URL.revokeObjectURL(url);
                    
                    this.showSuccess(
                        'Configuración exportada', 
                        'El archivo de configuración ha sido descargado'
                    );
                    
                    console.log('📥 Configuraciones exportadas exitosamente');
                    
                } catch (error) {
                    this.showError('Error', 'No se pudo exportar la configuración');
                    console.error('Error exporting settings:', error);
                }
            },
            
            /**
             * Importar configuraciones desde archivo JSON
             */
            importSettings() {
                // Trigger file input
                this.$refs.importFileInput.click();
            },
            
            /**
             * Manejar archivo de importación seleccionado
             */
            async handleImportFile(event) {
                const file = event.target.files[0];
                if (!file) return;
                
                this.setLoading(true, 'Importando configuraciones...');
                
                try {
                    const text = await this.readFileAsText(file);
                    const importData = JSON.parse(text);
                    
                    // Validar estructura del archivo
                    if (!importData.settings) {
                        throw new Error('Archivo de configuración inválido: falta sección "settings"');
                    }
                    
                    // Confirmar importación
                    const confirmed = await this.showConfirmation(
                        'Importar configuración',
                        'Esto sobrescribirá la configuración actual. ¿Continuar?',
                        'Sí, importar'
                    );
                    
                    if (!confirmed) return;
                    
                    // Aplicar configuraciones importadas
                    this.settings = { ...this.settings, ...importData.settings };
                    this.markAsChanged();
                    
                    this.showSuccess(
                        'Configuración importada', 
                        'Las configuraciones han sido importadas exitosamente'
                    );
                    
                    console.log('📤 Configuraciones importadas exitosamente');
                    
                } catch (error) {
                    let errorMessage = 'Archivo de configuración inválido';
                    
                    if (error instanceof SyntaxError) {
                        errorMessage = 'El archivo JSON no es válido';
                    } else if (error.message) {
                        errorMessage = error.message;
                    }
                    
                    this.showError('Error al importar', errorMessage);
                    console.error('Error importing settings:', error);
                    
                } finally {
                    this.setLoading(false);
                    // Limpiar input
                    event.target.value = '';
                }
            },
            
            /**
             * Leer archivo como texto
             */
            readFileAsText(file) {
                return new Promise((resolve, reject) => {
                    const reader = new FileReader();
                    reader.onload = e => resolve(e.target.result);
                    reader.onerror = reject;
                    reader.readAsText(file);
                });
            },
            
            /**
             * Limpiar caché del sistema
             */
            async clearCache() {
                const confirmed = await this.showConfirmation(
                    'Limpiar caché',
                    '¿Limpiar toda la caché del sistema? Esto puede afectar temporalmente el rendimiento.',
                    'Sí, limpiar'
                );
                
                if (!confirmed) return;
                
                this.setLoading(true, 'Limpiando caché...');
                
                try {
                    // Aquí harías la petición real al servidor
                    // await this.apiPost('/admin/api/cache/clear');
                    
                    // Simular limpieza de caché
                    await new Promise(resolve => setTimeout(resolve, 3000));
                    
                    this.showSuccess(
                        'Caché limpiada', 
                        'La caché del sistema ha sido limpiada exitosamente'
                    );
                    
                    // Emitir evento SocketIO
                    if (this.isSocketConnected) {
                        this.emitSocket('cache_cleared', {
                            timestamp: new Date().toISOString()
                        });
                    }
                    
                    console.log('🧹 Caché limpiada exitosamente');
                    
                } catch (error) {
                    this.showError('Error', 'No se pudo limpiar la caché');
                    console.error('Error clearing cache:', error);
                } finally {
                    this.setLoading(false);
                }
            },
            
            /**
             * Manejar notificaciones desde SocketIO
             */
            handleSocketNotification(data) {
                // Llamar al método padre
                SocketMixin.methods.handleSocketNotification.call(this, data);
                
                // Manejar notificaciones específicas de configuraciones
                if (data.data && data.data.action) {
                    switch (data.data.action) {
                        case 'settings_updated':
                            this.showInfo(
                                'Configuración actualizada', 
                                'La configuración fue actualizada por otro administrador'
                            );
                            // Recargar configuraciones
                            this.loadSettings();
                            break;
                            
                        case 'cache_cleared':
                            this.showInfo(
                                'Caché limpiada', 
                                'La caché fue limpiada por otro administrador'
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
             * Observar cambios en configuraciones para auto-save
             */
            settings: {
                handler(newSettings, oldSettings) {
                    // Solo marcar como cambiado si no es la carga inicial
                    if (oldSettings && JSON.stringify(newSettings) !== JSON.stringify(oldSettings)) {
                        this.markAsChanged();
                    }
                },
                deep: true
            },
            
            /**
             * Observar cambios de categoría para logging
             */
            currentCategory(newCategory, oldCategory) {
                if (oldCategory) {
                    console.log(`📂 Categoría cambiada: ${oldCategory} → ${newCategory}`);
                }
            },
            
            /**
             * Observar modo de mantenimiento para alertas
             */
            'settings.general.maintenanceMode'(newValue, oldValue) {
                if (oldValue !== undefined && newValue !== oldValue) {
                    const message = newValue 
                        ? 'Modo de mantenimiento ACTIVADO' 
                        : 'Modo de mantenimiento DESACTIVADO';
                    
                    this.showWarning('Cambio crítico', message);
                }
            }
        }
    });
    
    // Exponer para debugging en desarrollo
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        window.settingsApp = settingsApp;
        console.log('✅ Settings app disponible en window.settingsApp para debugging');
    }
    
    console.log('✅ Settings Vue.js inicializado exitosamente');
});