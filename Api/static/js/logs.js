/**
 * logs.js - Lógica Vue.js para gestión de logs de descarga
 * Carga todos los datos vía API con filtros y paginación
 */

document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 DOMContentLoaded - Iniciando Logs Vue.js');
    
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
    
    // Crear instancia Vue para Logs
    const logsApp = new Vue({
        el: '#app',
        delimiters: ['[[', ']]'],
        mixins: [NotificationMixin, HttpMixin, UtilsMixin, SocketMixin],
        
        data() {
            return {
                // Datos de logs (se cargarán vía API)
                logs: [],
                
                // Estadísticas
                stats: {
                    totalLogs: 0,
                    successfulLogs: 0,
                    failedLogs: 0,
                    uniqueIps: 0,
                    successRate: 0
                },
                
                // Filtros
                filters: {
                    search: '',
                    type: '',
                    status: '',
                    time: '',
                    ip: '',
                    page: 1,
                    per_page: 100
                },
                
                // Tipos de archivo disponibles
                fileTypes: [],
                
                // Paginación
                pagination: {
                    page: 1,
                    pages: 1,
                    perPage: 100,
                    total: 0,
                    hasNext: false,
                    hasPrev: false
                },
                
                // Log seleccionado para modal
                selectedLog: {},
                
                // Estados
                loading: false, // Overlay global
                loadingData: false, // Específico para datos de logs
                loadingStats: false, // Para estadísticas en tiempo real
                loadingMessage: 'Cargando...',
                
                // Auto-refresh
                autoRefreshInterval: null,
                autoRefreshActive: false,
                
                // Estadísticas en tiempo real
                realTimeStats: {
                    lastHourDownloads: 0,
                    lastHourUniqueIps: 0,
                    popularFiles: [],
                    hourlyActivity: []
                },
                
                // Gráfico
                activityChart: null,
                
                // Modal de limpieza
                cleanupModal: {
                    days: 30,
                    confirmed: false
                },
                
                // SocketIO
                isSocketConnected: false,
                socket: null
            };
        },
        
        computed: {
            /**
             * Logs filtrados localmente (búsqueda rápida)
             */
            filteredLogs() {
                let result = [...this.logs];
                
                // Filtro de búsqueda local (para búsqueda rápida)
                if (this.filters.search) {
                    const search = this.filters.search.toLowerCase();
                    result = result.filter(log => 
                        log.file_requested.toLowerCase().includes(search) ||
                        log.ip_address.includes(search) ||
                        (log.file_type && log.file_type.toLowerCase().includes(search))
                    );
                }
                
                return result;
            },
            
            /**
             * Páginas visibles en paginación
             */
            visiblePages() {
                const total = this.pagination.pages;
                const current = this.pagination.page;
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
                if (this.pagination.total === 0) return 0;
                return (this.pagination.page - 1) * this.pagination.perPage + 1;
            },
            
            endIndex() {
                if (this.pagination.total === 0) return 0;
                const end = this.pagination.page * this.pagination.perPage;
                return Math.min(end, this.pagination.total);
            }
        },
        
        mounted() {
            console.log('✅ Logs Vue montado');
            
            // Inicializar SocketIO
            this.initSocket();
            
            // Cargar datos iniciales
            this.loadLogsData();
            this.loadRealTimeStats();
            
            // Inicializar gráfico
            this.$nextTick(() => {
                this.initActivityChart();
            });
            
            // Auto-focus en búsqueda
            this.$nextTick(() => {
                const searchInput = this.$el.querySelector('input[placeholder*="Buscar"]');
                if (searchInput) {
                    searchInput.focus();
                }
            });
            
            console.log('Logs management inicializado correctamente');
        },
        
        beforeDestroy() {
            // Limpiar intervals
            if (this.autoRefreshInterval) {
                clearInterval(this.autoRefreshInterval);
            }
            
            // Destruir gráfico
            if (this.activityChart) {
                this.activityChart.destroy();
            }
        },
        
        methods: {
            /**
             * Cargar datos de logs desde la API
             */
            async loadLogsData() {
                this.loadingData = true;
                
                try {
                    const params = {
                        page: this.filters.page,
                        per_page: this.filters.per_page,
                        file_type: this.filters.type,
                        search: this.filters.search,
                        status: this.filters.status,
                        time: this.filters.time,
                        ip: this.filters.ip
                    };
                    
                    const response = await this.apiGet('/admin/api/logs_data', params);
                    
                    this.logs = response.logs || [];
                    this.pagination = response.pagination || {};
                    this.stats = response.stats || {};
                    this.fileTypes = response.file_types || [];
                    
                    console.log('✅ Logs cargados desde API:', this.logs.length);
                    
                } catch (error) {
                    this.showError('Error', 'No se pudieron cargar los logs.');
                    console.error('Error loading logs data:', error);
                } finally {
                    this.loadingData = false;
                }
            },
            
            /**
             * Cargar estadísticas en tiempo real
             */
            async loadRealTimeStats() {
                this.loadingStats = true;
                
                try {
                    const data = await this.apiGet('/admin/logs_stats');
                    
                    this.realTimeStats = {
                        lastHourDownloads: data.last_hour_downloads || 0,
                        lastHourUniqueIps: data.last_hour_unique_ips || 0,
                        popularFiles: data.popular_files || [],
                        hourlyActivity: data.hourly_activity || []
                    };
                    
                    // Actualizar gráfico si existe
                    if (this.activityChart && this.realTimeStats.hourlyActivity.length > 0) {
                        this.updateActivityChart();
                    }
                    
                    console.log('✅ Estadísticas en tiempo real cargadas');
                    
                } catch (error) {
                    console.error('Error loading real-time stats:', error);
                } finally {
                    this.loadingStats = false;
                }
            },
            
            /**
             * Aplicar filtros y recargar datos
             */
            applyFilters() {
                // Resetear página al aplicar filtros
                this.filters.page = 1;
                this.loadLogsData();
            },
            
            /**
             * Aplicar filtros con debounce para búsqueda
             */
            applyFiltersDebounced: function() {
                // Se definirá en created() con debounce
            },
            
            /**
             * Limpiar todos los filtros
             */
            clearFilters() {
                this.filters = {
                    search: '',
                    type: '',
                    status: '',
                    time: '',
                    ip: '',
                    page: 1,
                    per_page: 100
                };
                this.loadLogsData();
            },
            
            /**
             * Filtrar por IP específica
             */
            filterByIP(ip) {
                this.filters.ip = ip;
                this.filters.page = 1;
                this.loadLogsData();
                this.showInfo('Filtro aplicado', `Filtrando por IP: ${ip}`);
            },
            
            /**
             * Cambiar página
             */
            changePage(page) {
                if (page >= 1 && page <= this.pagination.pages && page !== this.pagination.page) {
                    this.filters.page = page;
                    this.loadLogsData();
                }
            },
            
            /**
             * Obtener icono según tipo de archivo
             */
            getFileIcon(fileType) {
                const icons = {
                    'update': 'bi bi-download text-primary',
                    'launcher': 'bi bi-app text-success',
                    'launcher_updater': 'bi bi-arrow-repeat text-warning',
                    'game_file': 'bi bi-file-earmark text-info',
                    'banner': 'bi bi-image text-secondary',
                    'messages': 'bi bi-chat-dots text-info',
                    'pbconfig': 'bi bi-gear text-warning'
                };
                
                return icons[fileType] || 'bi bi-file text-secondary';
            },
            
            /**
             * Obtener clase de badge según tipo
             */
            getTypeBadgeClass(fileType) {
                const classes = {
                    'update': 'bg-primary',
                    'launcher': 'bg-success',
                    'launcher_updater': 'bg-warning',
                    'game_file': 'bg-info',
                    'banner': 'bg-secondary',
                    'messages': 'bg-info',
                    'pbconfig': 'bg-warning'
                };
                
                return classes[fileType] || 'bg-secondary';
            },
            
            /**
             * Mostrar detalles de log en modal
             */
            showLogDetails(log) {
                this.selectedLog = { ...log };
                
                // Mostrar modal usando Bootstrap
                const modal = new bootstrap.Modal(document.getElementById('logDetailModal'));
                modal.show();
            },
            
            /**
             * Probar descarga de archivo
             */
            async testDownload(filename, fileType) {
                try {
                    let testUrl = '';
                    
                    // Determinar URL según tipo
                    switch(fileType) {
                        case 'update':
                            testUrl = `/api/updates/${filename}`;
                            break;
                        case 'launcher':
                        case 'launcher_updater':
                            testUrl = `/Launcher/${filename}`;
                            break;
                        case 'game_file':
                            testUrl = `/api/files/${filename}`;
                            break;
                        default:
                            testUrl = `/Launcher/${filename}`;
                    }
                    
                    const response = await fetch(testUrl, { method: 'HEAD' });
                    
                    if (response.ok) {
                        this.showSuccess('Archivo disponible', `✅ ${filename} está disponible para descarga`);
                    } else {
                        this.showWarning('Archivo no disponible', `❌ Error ${response.status}: ${filename} no está disponible`);
                    }
                    
                } catch (error) {
                    this.showError('Error de conexión', `❌ Error probando descarga: ${error.message}`);
                }
            },
            
            /**
             * Refrescar logs manualmente
             */
            async refreshLogs() {
                await this.loadLogsData();
                await this.loadRealTimeStats();
                this.showSuccess('Actualizado', 'Logs actualizados correctamente');
            },
            
            /**
             * Toggle auto-refresh
             */
            toggleAutoRefresh() {
                if (this.autoRefreshActive) {
                    // Desactivar auto-refresh
                    if (this.autoRefreshInterval) {
                        clearInterval(this.autoRefreshInterval);
                        this.autoRefreshInterval = null;
                    }
                    this.autoRefreshActive = false;
                    this.showInfo('Auto-refresh desactivado', 'Ya no se actualizarán automáticamente los logs');
                } else {
                    // Activar auto-refresh cada 30 segundos
                    this.autoRefreshInterval = setInterval(() => {
                        this.loadLogsData();
                        this.loadRealTimeStats();
                    }, 30000);
                    this.autoRefreshActive = true;
                    this.showSuccess('Auto-refresh activado', 'Los logs se actualizarán cada 30 segundos');
                }
            },
            
            /**
             * Exportar logs
             */
            exportLogs() {
                try {
                    // Construir URL de exportación con filtros actuales
                    let exportUrl = '/admin/logs/export';
                    const params = new URLSearchParams();
                    
                    if (this.filters.type) {
                        params.append('file_type', this.filters.type);
                    }
                    params.append('days', 30); // Por defecto últimos 30 días
                    
                    if (params.toString()) {
                        exportUrl += '?' + params.toString();
                    }
                    
                    // Crear enlace temporal y hacer clic
                    const link = document.createElement('a');
                    link.href = exportUrl;
                    link.download = '';
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                    
                    this.showSuccess('Exportación iniciada', 'El archivo se descargará automáticamente.');
                    
                } catch (error) {
                    this.showError('Error', 'No se pudo exportar los logs');
                    console.error('Export error:', error);
                }
            },
            
            /**
             * Mostrar modal de limpieza de logs
             */
            showCleanupModal() {
                const modal = new bootstrap.Modal(document.getElementById('cleanupModal'));
                modal.show();
            },
            
            /**
             * Limpiar logs antiguos
             */
            async cleanupOldLogs() {
                if (!this.cleanupModal.confirmed) {
                    this.showWarning('Confirmación requerida', 'Debes confirmar la acción para eliminar logs antiguos');
                    return;
                }
                
                const confirmed = await this.showConfirmation(
                    '¿Eliminar logs antiguos?',
                    `¿Estás seguro de que quieres eliminar todos los logs anteriores a ${this.cleanupModal.days} días? Esta acción no se puede deshacer.`,
                    'Sí, eliminar'
                );
                
                if (!confirmed) return;
                
                this.setLoading(true, 'Eliminando logs antiguos...');
                
                try {
                    const formData = new FormData();
                    formData.append('days', this.cleanupModal.days);
                    formData.append('confirm', 'true');
                    
                    await axios.post('/admin/logs/cleanup', formData, {
                        headers: {
                            'Content-Type': 'multipart/form-data'
                        }
                    });
                    
                    this.showSuccess('Logs eliminados', 'Los logs antiguos han sido eliminados exitosamente');
                    
                    // Recargar datos
                    await this.loadLogsData();
                    await this.loadRealTimeStats();
                    
                    // Cerrar modal
                    const modal = bootstrap.Modal.getInstance(document.getElementById('cleanupModal'));
                    if (modal) modal.hide();
                    
                    // Reset modal data
                    this.cleanupModal.confirmed = false;
                    
                } catch (error) {
                    console.error('Cleanup error:', error);
                    // handleHttpError en HttpMixin ya muestra el error
                } finally {
                    this.setLoading(false);
                }
            },
            
            /**
             * Inicializar gráfico de actividad
             */
            initActivityChart() {
                const ctx = document.getElementById('activityChart');
                if (!ctx || !window.Chart) {
                    console.warn('Canvas activityChart o Chart.js no encontrado');
                    return;
                }
                
                // Destruir instancia anterior si existe
                if (this.activityChart) {
                    this.activityChart.destroy();
                }
                
                this.activityChart = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: [],
                        datasets: [{
                            label: 'Descargas por Hora',
                            data: [],
                            borderColor: 'rgb(75, 192, 192)',
                            backgroundColor: 'rgba(75, 192, 192, 0.1)',
                            tension: 0.4,
                            fill: true
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                display: false
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    stepSize: 1
                                }
                            }
                        },
                        elements: {
                            point: {
                                radius: 3,
                                hoverRadius: 5
                            }
                        }
                    }
                });
                
                // Cargar datos iniciales si están disponibles
                if (this.realTimeStats.hourlyActivity.length > 0) {
                    this.updateActivityChart();
                }
            },
            
            /**
             * Actualizar gráfico de actividad
             */
            updateActivityChart() {
                if (!this.activityChart || !this.realTimeStats.hourlyActivity.length) return;
                
                this.activityChart.data.labels = this.realTimeStats.hourlyActivity.map(h => h.hour);
                this.activityChart.data.datasets[0].data = this.realTimeStats.hourlyActivity.map(h => h.count);
                this.activityChart.update();
                
                console.log('Gráfico de actividad actualizado');
            },
            
            /**
             * Manejar notificaciones desde SocketIO
             */
            handleSocketNotification(data) {
                // Llamar al método padre
                SocketMixin.methods.handleSocketNotification.call(this, data);
                
                // Manejar notificaciones específicas de logs
                if (data.data && data.data.action) {
                    switch (data.data.action) {
                        case 'new_download':
                            // Nueva descarga registrada
                            this.showInfo('Nueva descarga', `Archivo descargado: ${data.data.filename}`);
                            // Recargar estadísticas en tiempo real
                            this.loadRealTimeStats();
                            break;
                            
                        case 'logs_cleaned':
                            this.showInfo('Logs limpiados', 'Se han eliminado logs antiguos');
                            this.loadLogsData();
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
             * Observar cambios en filtros para aplicarlos con debounce
             */
            'filters.search': {
                handler: function(newVal, oldVal) {
                    // Aplicar filtro de búsqueda con debounce
                    this.applyFiltersDebounced();
                }
            },
            
            'filters.type': function() {
                this.applyFilters();
            },
            
            'filters.status': function() {
                this.applyFilters();
            },
            
            'filters.time': function() {
                this.applyFilters();
            },
            
            'filters.ip': function() {
                this.applyFilters();
            }
        },
        
        created() {
            // Configurar debounce para búsqueda
            this.applyFiltersDebounced = this.debounce(this.applyFilters, 500);
        }
    });
    
    // Exponer para debugging en desarrollo
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        window.logsApp = logsApp;
        console.log('✅ Logs app disponible en window.logsApp para debugging');
    }
    
    console.log('✅ Logs Vue.js inicializado exitosamente');
});