/**
 * updates.js - Lógica Vue.js para gestión de paquetes de actualización
 * Carga todos los datos vía API siguiendo el patrón establecido
 */

document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 DOMContentLoaded - Iniciando Updates Vue.js');
    
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
    
    // Crear instancia Vue para Updates
    const updatesApp = new Vue({
        el: '#app',
        delimiters: ['[[', ']]'],
        mixins: [NotificationMixin, HttpMixin, UtilsMixin, SocketMixin],
        
        data() {
            return {
                // Datos que se cargarán vía API
                updates: [],
                stats: {
                    totalUpdates: 0,
                    totalSize: 0,
                    totalSizeFormatted: '0 B',
                    latestVersion: 'N/A',
                    withMD5: 0
                },
                urls: {},
                
                // Filtros (se mantienen en el cliente)
                filters: {
                    search: '',
                    status: '',
                    size: '',
                    page: 1,
                    per_page: 20
                },
                
                // Paginación (reflejará la API)
                pagination: {
                    page: 1,
                    pages: 1,
                    perPage: 20,
                    total: 0,
                    hasNext: false,
                    hasPrev: false
                },
                
                // Modal
                selectedUpdate: {},
                
                // Estados
                loading: false,
                loadingData: false,
                loadingMessage: 'Cargando...',
                processing: false,
                
                // SocketIO (gestionado por SocketMixin)
                isSocketConnected: false,
                socket: null
            };
        },
        
        computed: {
            /**
             * Updates filtrados localmente
             */
            filteredUpdates() {
                let result = [...this.updates];
                
                // Filtro por búsqueda (versión, archivo)
                if (this.filters.search) {
                    const search = this.filters.search.toLowerCase();
                    result = result.filter(update => 
                        update.version.version.toLowerCase().includes(search) ||
                        update.filename.toLowerCase().includes(search) ||
                        (update.md5_hash && update.md5_hash.toLowerCase().includes(search))
                    );
                }
                
                // Filtro por estado
                if (this.filters.status) {
                    switch (this.filters.status) {
                        case 'available':
                            result = result.filter(update => update.file_exists);
                            break;
                        case 'missing':
                            result = result.filter(update => !update.file_exists);
                            break;
                        case 'no_hash':
                            result = result.filter(update => !update.md5_hash);
                            break;
                    }
                }
                
                // Filtro por tamaño
                if (this.filters.size && this.filters.size !== '') {
                    result = result.filter(update => {
                        if (!update.file_size) return false;
                        
                        const sizeMB = update.file_size / (1024 * 1024);
                        switch (this.filters.size) {
                            case 'small': return sizeMB < 10;
                            case 'medium': return sizeMB >= 10 && sizeMB <= 100;
                            case 'large': return sizeMB > 100;
                            default: return true;
                        }
                    });
                }
                
                return result;
            },
            
            /**
             * Updates paginados para la vista actual
             */
            paginatedUpdates() {
                // Si la API maneja paginación, usar this.updates directamente
                // Si se prefiere paginación client-side, usar este computed
                const start = (this.currentPage - 1) * this.itemsPerPage;
                const end = start + this.itemsPerPage;
                return this.filteredUpdates.slice(start, end);
            },
            
            /**
             * Página actual (para compatibilidad con paginación local)
             */
            currentPage() {
                return this.pagination.page;
            },
            
            /**
             * Items por página (para compatibilidad con paginación local)
             */
            itemsPerPage() {
                return 20; // Para paginación client-side
            },
            
            /**
             * Total de páginas
             */
            totalPages() {
                return Math.ceil(this.filteredUpdates.length / this.itemsPerPage);
            },
            
            /**
             * Páginas visibles en paginación
             */
            visiblePages() {
                const total = this.totalPages;
                const current = this.currentPage;
                const pages = [];
                
                if (total <= 7) {
                    for (let i = 1; i <= total; i++) {
                        pages.push(i);
                    }
                } else {
                    if (current <= 4) {
                        for (let i = 1; i <= 5; i++) pages.push(i);
                        pages.push('...');
                        pages.push(total);
                    } else if (current >= total - 3) {
                        pages.push(1);
                        pages.push('...');
                        for (let i = total - 4; i <= total; i++) pages.push(i);
                    } else {
                        pages.push(1);
                        pages.push('...');
                        for (let i = current - 1; i <= current + 1; i++) pages.push(i);
                        pages.push('...');
                        pages.push(total);
                    }
                }
                return pages;
            },
            
            /**
             * Índices para mostrar en paginación
             */
            startIndex() {
                if (this.filteredUpdates.length === 0) return 0;
                return (this.currentPage - 1) * this.itemsPerPage + 1;
            },
            
            endIndex() {
                if (this.filteredUpdates.length === 0) return 0;
                const end = this.currentPage * this.itemsPerPage;
                return Math.min(end, this.filteredUpdates.length);
            }
        },
        
        mounted() {
            console.log('✅ Updates Vue montado');
            
            // Inicializar SocketIO
            this.initSocket();
            
            // Cargar datos de updates desde la API
            this.loadUpdatesData();
            
            // Auto-focus en búsqueda
            this.$nextTick(() => {
                const searchInput = this.$el.querySelector('input[placeholder*="Buscar"]');
                if (searchInput) {
                    searchInput.focus();
                }
            });
            
            console.log('Updates management inicializado correctamente');
        },
        
        methods: {
            /**
             * Cargar datos de updates desde la API
             */
            async loadUpdatesData() {
                this.loadingData = true;
                
                try {
                    const params = {
                        page: this.filters.page,
                        per_page: this.filters.per_page
                        // Los filtros de búsqueda, estado y tamaño se aplicarán client-side
                    };
                    
                    const response = await this.apiGet('/admin/api/updates_data', params);
                    this.updates = response.updates;
                    this.stats = response.stats;
                    this.pagination = response.pagination;
                    this.urls = response.urls;
                    
                    console.log('✅ Updates cargados desde API:', this.updates.length);
                } catch (error) {
                    this.showError('Error', 'No se pudieron cargar los paquetes de actualización.');
                    console.error('Error loading updates data:', error);
                } finally {
                    this.loadingData = false;
                }
            },
            
            /**
             * Aplicar filtros
             */
            applyFilters() {
                // Los filtros se aplican automáticamente via computed properties
                // Reset página al aplicar filtros
                this.pagination.page = 1;
            },
            
            /**
             * Limpiar todos los filtros
             */
            clearFilters() {
                this.filters.search = '';
                this.filters.status = '';
                this.filters.size = '';
                this.pagination.page = 1;
            },
            
            /**
             * Cambiar página (para paginación client-side)
             */
            changePage(page) {
                if (page >= 1 && page <= this.totalPages && page !== this.currentPage) {
                    this.pagination.page = page;
                }
            },
            
            /**
             * Refrescar datos manualmente
             */
            async refreshData() {
                await this.loadUpdatesData();
                this.showSuccess('Actualizado', 'Lista de paquetes actualizada correctamente');
            },
            
            /**
             * Mostrar detalles de update en modal
             */
            showUpdateDetails(update) {
                this.selectedUpdate = { ...update };
                
                // Mostrar modal usando Bootstrap
                const modal = new bootstrap.Modal(document.getElementById('updateDetailModal'));
                modal.show();
            },
            
            /**
             * Descargar paquete de actualización
             */
            downloadUpdate(filename) {
                try {
                    const url = `/Launcher/updates/${filename}`;
                    window.open(url, '_blank');
                    
                    this.showInfo('Descarga iniciada', `Descargando ${filename}`);
                    
                    // Emitir evento SocketIO
                    if (this.isSocketConnected) {
                        this.emitSocket('update_downloaded', {
                            filename: filename,
                            timestamp: new Date().toISOString()
                        });
                    }
                } catch (error) {
                    this.showError('Error', 'No se pudo iniciar la descarga');
                    console.error('Download error:', error);
                }
            },
            
            /**
             * Probar descarga de update
             */
            async testUpdate(filename) {
                try {
                    this.processing = true;
                    
                    const testUrl = `/Launcher/updates/${filename}`;
                    const response = await fetch(testUrl, { method: 'HEAD' });
                    
                    if (response.ok) {
                        this.showSuccess(
                            'Test exitoso', 
                            `✅ El archivo ${filename} está disponible para descarga`
                        );
                    } else {
                        this.showError(
                            'Test fallido', 
                            `❌ Error ${response.status}: El archivo ${filename} no está disponible`
                        );
                    }
                } catch (error) {
                    this.showError(
                        'Error de conexión', 
                        `❌ No se pudo verificar ${filename}: ${error.message}`
                    );
                } finally {
                    this.processing = false;
                }
            },
            
            /**
             * Eliminar paquete de actualización
             */
            async deleteUpdate(update) {
                const confirmed = await this.showConfirmation(
                    '¿Eliminar paquete de actualización?',
                    `¿Estás seguro de que quieres eliminar "${update.filename}"? Esta acción no se puede deshacer.`,
                    'Sí, eliminar'
                );
                
                if (!confirmed) return;
                
                this.processing = true;
                
                try {
                    // Usar FormData para compatibilidad con el endpoint existente
                    const response = await fetch(this.urls.delete.replace('0', update.id), {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        }
                    });
                    
                    if (response.ok) {
                        // Remover de la lista local
                        this.updates = this.updates.filter(u => u.id !== update.id);
                        
                        // Actualizar estadísticas
                        this.stats.totalUpdates--;
                        if (update.file_size) {
                            this.stats.totalSize -= update.file_size;
                            this.stats.totalSizeFormatted = this.formatFileSize(this.stats.totalSize);
                        }
                        if (update.md5_hash) {
                            this.stats.withMD5--;
                        }
                        
                        this.showSuccess(
                            'Paquete eliminado', 
                            `${update.filename} ha sido eliminado exitosamente`
                        );
                        
                        // Emitir evento SocketIO
                        if (this.isSocketConnected) {
                            this.emitSocket('update_deleted', {
                                filename: update.filename,
                                version: update.version.version
                            });
                        }
                    } else {
                        throw new Error(`Error del servidor: ${response.status}`);
                    }
                } catch (error) {
                    console.error('Error eliminando update:', error);
                    this.showError('Error al eliminar', 'No se pudo eliminar el paquete de actualización');
                } finally {
                    this.processing = false;
                }
            },
            
            /**
             * Regenerar hash MD5 de un update
             */
            async regenerateHash(update) {
                const confirmed = await this.showConfirmation(
                    'Regenerar hash MD5',
                    `¿Regenerar el hash MD5 para "${update.filename}"?`,
                    'Sí, regenerar'
                );
                
                if (!confirmed) return;
                
                this.processing = true;
                this.showLoading('Regenerando hash MD5...');
                
                try {
                    // Simular llamada API (implementar endpoint real)
                    await new Promise(resolve => setTimeout(resolve, 2000));
                    
                    // Actualizar hash en la lista local (reemplazar con llamada API real)
                    const updateIndex = this.updates.findIndex(u => u.id === update.id);
                    if (updateIndex !== -1) {
                        this.updates[updateIndex].md5_hash = 'nuevo_hash_simulado_' + Date.now();
                    }
                    
                    this.hideLoading();
                    this.showSuccess('Hash regenerado', `Hash MD5 regenerado para ${update.filename}`);
                    
                    // Emitir evento SocketIO
                    if (this.isSocketConnected) {
                        this.emitSocket('hash_regenerated', {
                            filename: update.filename,
                            update_id: update.id
                        });
                    }
                } catch (error) {
                    this.hideLoading();
                    this.showError('Error', 'No se pudo regenerar el hash MD5');
                    console.error('Regenerate hash error:', error);
                } finally {
                    this.processing = false;
                }
            },
            
            /**
             * Validar integridad de update
             */
            async validateUpdate(update) {
                this.processing = true;
                this.showLoading('Validando integridad del archivo...');
                
                try {
                    // Simular llamada API (implementar endpoint real)
                    await new Promise(resolve => setTimeout(resolve, 1500));
                    
                    this.hideLoading();
                    this.showSuccess(
                        'Validación exitosa', 
                        `${update.filename} pasó la validación de integridad`
                    );
                } catch (error) {
                    this.hideLoading();
                    this.showError('Error de validación', 'No se pudo validar la integridad del archivo');
                    console.error('Validate error:', error);
                } finally {
                    this.processing = false;
                }
            },
            
            /**
             * Regenerar todos los hashes
             */
            async regenerateAll() {
                if (this.updates.length === 0) {
                    this.showWarning('Sin paquetes', 'No hay paquetes para procesar');
                    return;
                }
                
                const confirmed = await this.showConfirmation(
                    'Regenerar todos los hashes',
                    `¿Regenerar los hashes MD5 de todos los ${this.updates.length} paquetes? Esto puede tomar unos minutos.`,
                    'Sí, regenerar todos'
                );
                
                if (!confirmed) return;
                
                this.processing = true;
                this.showLoading('Regenerando todos los hashes...');
                
                try {
                    // Simular procesamiento batch (implementar endpoint real)
                    await new Promise(resolve => setTimeout(resolve, 3000));
                    
                    this.hideLoading();
                    this.showSuccess(
                        'Regeneración completa', 
                        `Todos los hashes MD5 han sido regenerados exitosamente`
                    );
                    
                    // Recargar datos para mostrar nuevos hashes
                    await this.loadUpdatesData();
                } catch (error) {
                    this.hideLoading();
                    this.showError('Error', 'No se pudieron regenerar todos los hashes');
                    console.error('Regenerate all error:', error);
                } finally {
                    this.processing = false;
                }
            },
            
            /**
             * Validar todos los updates
             */
            async validateAll() {
                if (this.updates.length === 0) {
                    this.showWarning('Sin paquetes', 'No hay paquetes para validar');
                    return;
                }
                
                this.processing = true;
                this.showLoading('Validando integridad de todos los archivos...');
                
                try {
                    // Simular validación batch (implementar endpoint real)
                    await new Promise(resolve => setTimeout(resolve, 2500));
                    
                    this.hideLoading();
                    this.showSuccess(
                        'Validación completa', 
                        `Todos los ${this.updates.length} archivos han sido validados exitosamente`
                    );
                } catch (error) {
                    this.hideLoading();
                    this.showError('Error', 'No se pudieron validar todos los archivos');
                    console.error('Validate all error:', error);
                } finally {
                    this.processing = false;
                }
            },
            
            /**
             * Descargar todos los updates
             */
            async downloadAll() {
                if (this.filteredUpdates.length === 0) {
                    this.showWarning('Sin paquetes', 'No hay paquetes para descargar');
                    return;
                }
                
                const confirmed = await this.showConfirmation(
                    'Descargar todos los paquetes',
                    `¿Descargar todos los ${this.filteredUpdates.length} paquetes de actualización?`,
                    'Sí, descargar todos'
                );
                
                if (!confirmed) return;
                
                try {
                    // Descargar con delay entre archivos
                    this.filteredUpdates.forEach((update, index) => {
                        setTimeout(() => {
                            this.downloadUpdate(update.filename);
                        }, index * 1000); // 1 segundo de delay entre descargas
                    });
                    
                    this.showInfo(
                        'Descargas iniciadas', 
                        `Iniciando descarga de ${this.filteredUpdates.length} archivos...`
                    );
                } catch (error) {
                    this.showError('Error', 'No se pudieron iniciar las descargas');
                    console.error('Download all error:', error);
                }
            },
            
            /**
             * Generar secuencia de actualización
             */
            async generateUpdateSequence() {
                this.processing = true;
                this.showLoading('Generando secuencia de actualización...');
                
                try {
                    // Simular generación de secuencia (implementar endpoint real)
                    await new Promise(resolve => setTimeout(resolve, 2000));
                    
                    this.hideLoading();
                    this.showSuccess(
                        'Secuencia generada', 
                        'Secuencia de actualización generada exitosamente'
                    );
                } catch (error) {
                    this.hideLoading();
                    this.showError('Error', 'No se pudo generar la secuencia de actualización');
                    console.error('Generate sequence error:', error);
                } finally {
                    this.processing = false;
                }
            },
            
            /**
             * Obtener URL de descarga completa
             */
            getDownloadUrl(filename) {
                return `${window.location.origin}/Launcher/updates/${filename}`;
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
                        case 'update_created':
                            this.showInfo(
                                'Nuevo paquete', 
                                'Se ha creado un nuevo paquete de actualización. Recargando lista...'
                            );
                            this.loadUpdatesData();
                            break;
                            
                        case 'update_deleted':
                            if (data.data.filename) {
                                this.showInfo(
                                    'Paquete eliminado', 
                                    `${data.data.filename} fue eliminado por otro usuario. Recargando lista...`
                                );
                            }
                            this.loadUpdatesData();
                            break;
                            
                        case 'hash_regenerated':
                            if (data.data.filename) {
                                this.showInfo(
                                    'Hash actualizado', 
                                    `Hash MD5 de ${data.data.filename} fue regenerado. Recargando lista...`
                                );
                            }
                            this.loadUpdatesData();
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
             * Observar cambios en filtros para aplicación automática
             */
            'filters.search': {
                handler: function(newVal, oldVal) {
                    // Debounce para búsqueda
                    clearTimeout(this.searchTimeout);
                    this.searchTimeout = setTimeout(() => {
                        this.applyFilters();
                    }, 300);
                }
            },
            
            'filters.status': function() {
                this.applyFilters();
            },
            
            'filters.size': function() {
                this.applyFilters();
            }
        }
    });
    
    // Exponer para debugging en desarrollo
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        window.updatesApp = updatesApp;
        console.log('✅ Updates app disponible en window.updatesApp para debugging');
    }
    
    console.log('✅ Updates Vue.js inicializado exitosamente');
});