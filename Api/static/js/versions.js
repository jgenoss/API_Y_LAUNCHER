/**
 * versions.js - Lógica Vue.js para gestión de versiones del juego
 * Carga todos los datos vía API con funcionalidad reactiva
 */

document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 DOMContentLoaded - Iniciando Versions Vue.js');
    
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
    
    // Crear instancia Vue para Versions
    const versionsApp = new Vue({
        el: '#app',
        delimiters: ['[[', ']]'],
        mixins: [NotificationMixin, HttpMixin, UtilsMixin, SocketMixin],
        
        data() {
            return {
                // Datos de versiones (se cargarán vía API)
                versions: [],
                
                // Estadísticas
                stats: {
                    totalVersions: 0,
                    latestVersion: '',
                    versionsWithFiles: 0,
                    versionsWithUpdates: 0
                },
                
                // Filtros
                filters: {
                    search: '',
                    status: 'all', // 'all', 'active', 'archived'
                    hasFiles: '',
                    hasUpdates: ''
                },
                
                // Versión seleccionada para modal
                selectedVersion: {},
                
                // Estados
                loading: false, // Overlay global
                loadingData: false, // Específico para datos de versiones
                loadingMessage: 'Cargando...',
                
                // Vista
                viewMode: 'list', // 'list' o 'grid'
                
                // SocketIO
                isSocketConnected: false,
                socket: null
            };
        },
        
        computed: {
            /**
             * Versiones filtradas
             */
            filteredVersions() {
                let result = [...this.versions];
                
                // Filtro por búsqueda
                if (this.filters.search) {
                    const search = this.filters.search.toLowerCase();
                    result = result.filter(version => 
                        version.version.toLowerCase().includes(search) ||
                        (version.release_notes && version.release_notes.toLowerCase().includes(search))
                    );
                }
                
                // Filtro por estado
                if (this.filters.status !== 'all') {
                    switch (this.filters.status) {
                        case 'active':
                            result = result.filter(version => version.is_latest);
                            break;
                        case 'archived':
                            result = result.filter(version => !version.is_latest);
                            break;
                    }
                }
                
                // Filtro por archivos
                if (this.filters.hasFiles === 'true') {
                    result = result.filter(version => version.files && version.files.length > 0);
                } else if (this.filters.hasFiles === 'false') {
                    result = result.filter(version => !version.files || version.files.length === 0);
                }
                
                // Filtro por actualizaciones
                if (this.filters.hasUpdates === 'true') {
                    result = result.filter(version => version.update_packages && version.update_packages.length > 0);
                } else if (this.filters.hasUpdates === 'false') {
                    result = result.filter(version => !version.update_packages || version.update_packages.length === 0);
                }
                
                return result;
            },
            
            /**
             * Versión actual
             */
            currentVersion() {
                return this.versions.find(v => v.is_latest);
            },
            
            /**
             * Estadísticas calculadas
             */
            calculatedStats() {
                return {
                    totalVersions: this.versions.length,
                    latestVersion: this.currentVersion ? this.currentVersion.version : 'N/A',
                    versionsWithFiles: this.versions.filter(v => v.files && v.files.length > 0).length,
                    versionsWithUpdates: this.versions.filter(v => v.update_packages && v.update_packages.length > 0).length
                };
            }
        },
        
        mounted() {
            console.log('✅ Versions Vue montado');
            
            // Inicializar SocketIO
            this.initSocket();
            
            // Cargar datos de versiones
            this.loadVersionsData();
            
            // Auto-focus en búsqueda
            this.$nextTick(() => {
                const searchInput = this.$el.querySelector('input[placeholder*="Buscar"]');
                if (searchInput) {
                    searchInput.focus();
                }
            });
            
            console.log('Versions management inicializado correctamente');
        },
        
        methods: {
            /**
             * Cargar datos de versiones desde la API
             */
            async loadVersionsData() {
                this.loadingData = true;
                
                try {
                    const response = await this.apiGet('/admin/api/versions_data');
                    
                    this.versions = response.versions || [];
                    this.stats = response.stats || {};
                    
                    console.log('✅ Versiones cargadas desde API:', this.versions.length);
                    
                } catch (error) {
                    this.showError('Error', 'No se pudieron cargar las versiones.');
                    console.error('Error loading versions data:', error);
                } finally {
                    this.loadingData = false;
                }
            },
            
            /**
             * Aplicar filtros
             */
            applyFilters() {
                // Los filtros se aplican automáticamente a través de computed
                console.log('Filtros aplicados:', this.filters);
            },
            
            /**
             * Limpiar filtros
             */
            clearFilters() {
                this.filters = {
                    search: '',
                    status: 'all',
                    hasFiles: '',
                    hasUpdates: ''
                };
            },
            
            /**
             * Cambiar modo de vista
             */
            setViewMode(mode) {
                this.viewMode = mode;
                this.showInfo('Vista cambiada', `Modo de vista cambiado a ${mode}`);
            },
            
            /**
             * Mostrar detalles de versión en modal
             */
            showVersionDetails(version) {
                this.selectedVersion = { ...version };
                
                // Mostrar modal usando Bootstrap
                const modal = new bootstrap.Modal(document.getElementById(`versionModal${version.id}`));
                modal.show();
            },
            
            /**
             * Establecer versión como actual
             */
            async setAsLatest(version) {
                const confirmed = await this.showConfirmation(
                    '¿Establecer como versión actual?',
                    `¿Estás seguro de que quieres establecer la versión ${version.version} como la versión actual del juego?`,
                    'Sí, establecer como actual'
                );
                
                if (!confirmed) return;
                
                this.setLoading(true, `Estableciendo versión ${version.version} como actual...`);
                
                try {
                    await this.apiPost(`/admin/versions/${version.id}/set_latest`);
                    
                    // Actualizar localmente
                    this.versions.forEach(v => {
                        v.is_latest = v.id === version.id;
                    });
                    
                    this.showSuccess(
                        'Versión actualizada', 
                        `La versión ${version.version} ahora es la versión actual`
                    );
                    
                    // Emitir evento SocketIO
                    if (this.isSocketConnected) {
                        this.emitSocket('version_set_latest', {
                            version: version.version,
                            version_id: version.id
                        });
                    }
                    
                } catch (error) {
                    console.error('Error setting latest version:', error);
                    // handleHttpError en HttpMixin ya muestra el error
                } finally {
                    this.setLoading(false);
                }
            },
            
            /**
             * Eliminar versión
             */
            async deleteVersion(version) {
                if (version.is_latest) {
                    this.showWarning('No se puede eliminar', 'No se puede eliminar la versión actual del juego');
                    return;
                }
                
                const confirmed = await this.showConfirmation(
                    '¿Eliminar versión?',
                    `¿Estás seguro de que quieres eliminar la versión ${version.version}? Esta acción eliminará también todos los archivos y paquetes de actualización asociados y no se puede deshacer.`,
                    'Sí, eliminar versión'
                );
                
                if (!confirmed) return;
                
                this.setLoading(true, `Eliminando versión ${version.version}...`);
                
                try {
                    await this.apiPost(`/admin/versions/${version.id}/delete`);
                    
                    // Remover de la lista local
                    this.versions = this.versions.filter(v => v.id !== version.id);
                    
                    this.showSuccess(
                        'Versión eliminada', 
                        `La versión ${version.version} ha sido eliminada exitosamente`
                    );
                    
                    // Emitir evento SocketIO
                    if (this.isSocketConnected) {
                        this.emitSocket('version_deleted', {
                            version: version.version,
                            version_id: version.id
                        });
                    }
                    
                } catch (error) {
                    console.error('Error deleting version:', error);
                    // handleHttpError en HttpMixin ya muestra el error
                } finally {
                    this.setLoading(false);
                }
            },
            
            /**
             * Obtener clase de badge según estado
             */
            getStatusBadgeClass(version) {
                return version.is_latest ? 'bg-success' : 'bg-secondary';
            },
            
            /**
             * Obtener texto de estado
             */
            getStatusText(version) {
                return version.is_latest ? 'Activa' : 'Archivada';
            },
            
            /**
             * Obtener icono de estado
             */
            getStatusIcon(version) {
                return version.is_latest ? 'bi bi-check-circle' : 'bi bi-archive';
            },
            
            /**
             * Calcular tamaño total de archivos de una versión
             */
            getTotalSize(version) {
                if (!version.files || version.files.length === 0) return 0;
                
                return version.files.reduce((total, file) => {
                    return total + (file.file_size || 0);
                }, 0);
            },
            
            /**
             * Formatear tamaño total
             */
            getTotalSizeFormatted(version) {
                const totalSize = this.getTotalSize(version);
                return totalSize > 0 ? this.formatFileSize(totalSize) : 'No calculado';
            },
            
            /**
             * Navegar a gestión de archivos de una versión
             */
            manageFiles(version) {
                window.location.href = `/admin/files?version_id=${version.id}`;
            },
            
            /**
             * Navegar a crear actualización
             */
            createUpdate(version) {
                window.location.href = `/admin/updates/create?version_id=${version.id}`;
            },
            
            /**
             * Refrescar versiones manualmente
             */
            async refreshVersions() {
                await this.loadVersionsData();
                this.showSuccess('Actualizado', 'Versiones actualizadas correctamente');
            },
            
            /**
             * Manejar notificaciones desde SocketIO
             */
            handleSocketNotification(data) {
                // Llamar al método padre
                SocketMixin.methods.handleSocketNotification.call(this, data);
                
                // Manejar notificaciones específicas de versiones
                if (data.data && data.data.action) {
                    switch (data.data.action) {
                        case 'version_created':
                            this.showInfo('Nueva versión', `Se ha creado la versión ${data.data.version}`);
                            this.loadVersionsData(); // Recargar lista
                            break;
                            
                        case 'version_set_latest':
                            if (data.data.version) {
                                this.showInfo('Versión actualizada', `La versión ${data.data.version} ahora es la actual`);
                                this.loadVersionsData(); // Recargar para sincronizar
                            }
                            break;
                            
                        case 'version_deleted':
                            if (data.data.version) {
                                this.showInfo('Versión eliminada', `La versión ${data.data.version} fue eliminada`);
                                this.loadVersionsData(); // Recargar lista
                            }
                            break;
                            
                        case 'files_uploaded':
                            if (data.data.version_id) {
                                this.showInfo('Archivos actualizados', 'Se han subido nuevos archivos. Recargando versiones...');
                                this.loadVersionsData(); // Recargar para actualizar contadores
                            }
                            break;
                            
                        case 'update_created':
                            if (data.data.version) {
                                this.showInfo('Actualización creada', `Se ha creado un paquete de actualización para la versión ${data.data.version}`);
                                this.loadVersionsData(); // Recargar para actualizar contadores
                            }
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
             * Observar cambios en filtros
             */
            'filters.search': {
                handler: function(newVal, oldVal) {
                    // Los filtros se aplican automáticamente a través de computed
                    console.log('Filtro de búsqueda cambiado:', newVal);
                }
            },
            
            'filters.status': function(newVal) {
                console.log('Filtro de estado cambiado:', newVal);
            },
            
            'filters.hasFiles': function(newVal) {
                console.log('Filtro de archivos cambiado:', newVal);
            },
            
            'filters.hasUpdates': function(newVal) {
                console.log('Filtro de actualizaciones cambiado:', newVal);
            }
        }
    });
    
    // Exponer para debugging en desarrollo
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        window.versionsApp = versionsApp;
        console.log('✅ Versions app disponible en window.versionsApp para debugging');
    }
    
    console.log('✅ Versions Vue.js inicializado exitosamente');
});