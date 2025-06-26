/**
 * hwid.js - Lógica Vue.js para gestión de HWID
 * Carga todos los datos vía API siguiendo el patrón establecido
 */

document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 DOMContentLoaded - Iniciando HWID Management Vue.js');
    
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
    
    // Crear instancia Vue para HWID Management
    const hwidApp = new Vue({
        el: '#app',
        delimiters: ['[[', ']]'],
        mixins: [NotificationMixin, HttpMixin, UtilsMixin, SocketMixin],
        
        data() {
            return {
                // Datos que se cargarán vía API
                devices: [],
                
                // Filtros
                filters: {
                    search: '',
                    status: '', // '', 'banned', 'allowed'
                    page: 1,
                    per_page: 50
                },
                
                // Paginación
                pagination: {
                    page: 1,
                    pages: 1,
                    perPage: 50,
                    total: 0,
                    hasNext: false,
                    hasPrev: false
                },
                
                // Estadísticas
                stats: {
                    totalDevices: 0,
                    bannedDevices: 0,
                    allowedDevices: 0,
                    newDevices24h: 0
                },
                
                // URLs de la API
                urls: {},
                
                // Selección
                selectedDevices: [],
                selectAllChecked: false,
                
                // Modales
                selectedDevice: null,
                newDevice: {
                    hwid: '',
                    serial_number: '',
                    mac_address: '',
                    reason: '',
                    is_banned: false
                },
                banReason: '',
                
                // Estados
                loading: false,
                loadingData: false,
                loadingMessage: 'Cargando...',
                submitting: false,
                
                // SocketIO (gestionado por SocketMixin)
                isSocketConnected: false,
                socket: null
            };
        },
        
        computed: {
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
            },
            
            /**
             * Tasa de baneo como porcentaje
             */
            banRate() {
                if (this.stats.totalDevices === 0) return 0;
                return Math.round((this.stats.bannedDevices / this.stats.totalDevices) * 100);
            }
        },
        
        mounted() {
            console.log('✅ HWID Management Vue montado');
            
            // Inicializar SocketIO
            this.initSocket();
            
            // Cargar datos de HWID desde la API
            this.loadHwidData();
            
            // Auto-focus en búsqueda
            this.$nextTick(() => {
                const searchInput = this.$el.querySelector('input[placeholder*="Buscar"]');
                if (searchInput) {
                    searchInput.focus();
                }
            });
            
            console.log('HWID Management inicializado correctamente');
        },
        
        methods: {
            /**
             * Cargar datos de HWID desde la API con los filtros actuales
             */
            async loadHwidData() {
                this.loadingData = true;
                this.selectedDevices = [];
                this.updateSelectAllState();
                
                try {
                    const params = {
                        page: this.filters.page,
                        per_page: this.filters.per_page,
                        search: this.filters.search,
                        status: this.filters.status
                    };
                    
                    const response = await this.apiGet('/admin/api/hwid_data', params);
                    this.devices = response.devices;
                    this.pagination = response.pagination;
                    this.urls = response.urls;
                    this.stats = response.stats;
                    
                    console.log('✅ Dispositivos HWID cargados desde API:', this.devices.length);
                } catch (error) {
                    this.showError('Error', 'No se pudieron cargar los dispositivos.');
                    console.error('Error loading HWID data:', error);
                } finally {
                    this.loadingData = false;
                }
            },
            
            /**
             * Aplicar filtros y recargar datos
             */
            applyFilters() {
                this.filters.page = 1;
                this.loadHwidData();
            },
            
            /**
             * Cambiar página y recargar datos
             */
            changePage(page) {
                if (page >= 1 && page <= this.pagination.pages && page !== this.pagination.page) {
                    this.filters.page = page;
                    this.loadHwidData();
                }
            },
            
            /**
             * Refrescar datos manualmente
             */
            async refreshData() {
                await this.loadHwidData();
                this.showSuccess('Actualizado', 'Datos de dispositivos actualizados correctamente');
            },
            
            /**
             * Seleccionar/deseleccionar todos los dispositivos visibles
             */
            selectAll() {
                if (this.selectedDevices.length === this.devices.length) {
                    this.selectedDevices = [];
                } else {
                    this.selectedDevices = this.devices.map(device => device.id);
                }
                this.updateSelectAllState();
            },
            
            /**
             * Toggle select all checkbox
             */
            toggleSelectAll() {
                if (this.selectAllChecked) {
                    this.selectedDevices = this.devices.map(device => device.id);
                } else {
                    this.selectedDevices = [];
                }
            },
            
            /**
             * Actualizar estado del checkbox "Seleccionar todo"
             */
            updateSelectAllState() {
                const visibleIds = this.devices.map(device => device.id);
                const selectedOnPage = this.selectedDevices.filter(id => visibleIds.includes(id));
                
                this.selectAllChecked = visibleIds.length > 0 && selectedOnPage.length === visibleIds.length;
            },
            
            /**
             * Mostrar modal para agregar dispositivo
             */
            showAddDeviceModal() {
                this.newDevice = {
                    hwid: '',
                    serial_number: '',
                    mac_address: '',
                    reason: '',
                    is_banned: false
                };
                
                const modal = new bootstrap.Modal(document.getElementById('addDeviceModal'));
                modal.show();
                
                // Focus en el campo HWID después de mostrar el modal
                this.$nextTick(() => {
                    const hwidInput = document.getElementById('newHwid');
                    if (hwidInput) {
                        hwidInput.focus();
                    }
                });
            },
            
            /**
             * Agregar nuevo dispositivo
             */
            async addDevice() {
                if (!this.newDevice.hwid.trim()) {
                    this.showWarning('HWID requerido', 'Debes ingresar un HWID válido');
                    return;
                }
                
                this.submitting = true;
                
                try {
                    const response = await this.apiPost(this.urls.addDevice, this.newDevice);
                    
                    this.showSuccess('Dispositivo agregado', response.message);
                    
                    // Cerrar modal
                    const modal = bootstrap.Modal.getInstance(document.getElementById('addDeviceModal'));
                    modal.hide();
                    
                    // Recargar datos
                    await this.loadHwidData();
                    
                    // Emitir evento SocketIO
                    if (this.isSocketConnected) {
                        this.emitSocket('device_added', {
                            hwid: this.newDevice.hwid,
                            is_banned: this.newDevice.is_banned
                        });
                    }
                    
                } catch (error) {
                    console.error('Error agregando dispositivo:', error);
                } finally {
                    this.submitting = false;
                }
            },
            
            /**
             * Mostrar modal para banear dispositivo
             */
            showBanModal(device) {
                this.selectedDevice = device;
                this.banReason = '';
                
                const modal = new bootstrap.Modal(document.getElementById('banDeviceModal'));
                modal.show();
                
                // Focus en el campo razón después de mostrar el modal
                this.$nextTick(() => {
                    const reasonInput = document.getElementById('banReason');
                    if (reasonInput) {
                        reasonInput.focus();
                    }
                });
            },
            
            /**
             * Banear dispositivo
             */
            async banDevice() {
                if (!this.banReason.trim()) {
                    this.showWarning('Razón requerida', 'Debes especificar una razón para el baneo');
                    return;
                }
                
                this.submitting = true;
                
                try {
                    const url = this.urls.banDevice.replace('0', this.selectedDevice.id);
                    await this.apiPost(url, { reason: this.banReason });
                    
                    this.showSuccess('Dispositivo baneado', 'El dispositivo ha sido baneado exitosamente');
                    
                    // Cerrar modal
                    const modal = bootstrap.Modal.getInstance(document.getElementById('banDeviceModal'));
                    modal.hide();
                    
                    // Recargar datos
                    await this.loadHwidData();
                    
                    // Emitir evento SocketIO
                    if (this.isSocketConnected) {
                        this.emitSocket('device_banned', {
                            hwid: this.selectedDevice.hwid,
                            reason: this.banReason
                        });
                    }
                    
                } catch (error) {
                    console.error('Error baneando dispositivo:', error);
                } finally {
                    this.submitting = false;
                }
            },
            
            /**
             * Desbanear dispositivo
             */
            async unbanDevice(device) {
                const confirmed = await this.showConfirmation(
                    '¿Desbanear dispositivo?',
                    `¿Estás seguro de que quieres desbanear el dispositivo con HWID "${device.hwid.substring(0, 16)}..."?`,
                    'Sí, desbanear'
                );
                
                if (!confirmed) return;
                
                try {
                    const url = this.urls.unbanDevice.replace('0', device.id);
                    await this.apiPost(url);
                    
                    this.showSuccess('Dispositivo desbaneado', 'El dispositivo ha sido desbaneado exitosamente');
                    
                    // Recargar datos
                    await this.loadHwidData();
                    
                    // Emitir evento SocketIO
                    if (this.isSocketConnected) {
                        this.emitSocket('device_unbanned', {
                            hwid: device.hwid
                        });
                    }
                    
                } catch (error) {
                    console.error('Error desbaneando dispositivo:', error);
                }
            },
            
            /**
             * Eliminar dispositivo
             */
            async deleteDevice(device) {
                const confirmed = await this.showConfirmation(
                    '¿Eliminar dispositivo?',
                    `¿Estás seguro de que quieres eliminar el dispositivo con HWID "${device.hwid.substring(0, 16)}..."? Esta acción no se puede deshacer.`,
                    'Sí, eliminar'
                );
                
                if (!confirmed) return;
                
                try {
                    const url = this.urls.deleteDevice.replace('0', device.id);
                    await this.apiPost(url);
                    
                    this.showSuccess('Dispositivo eliminado', 'El dispositivo ha sido eliminado exitosamente');
                    
                    // Recargar datos
                    await this.loadHwidData();
                    
                    // Emitir evento SocketIO
                    if (this.isSocketConnected) {
                        this.emitSocket('device_deleted', {
                            hwid: device.hwid
                        });
                    }
                    
                } catch (error) {
                    console.error('Error eliminando dispositivo:', error);
                }
            },
            
            /**
             * Acciones en lote
             */
            async bulkAction(action) {
                if (this.selectedDevices.length === 0) {
                    this.showWarning('Sin selección', 'No hay dispositivos seleccionados');
                    return;
                }
                
                const count = this.selectedDevices.length;
                const actionText = {
                    'ban': 'banear',
                    'unban': 'desbanear',
                    'delete': 'eliminar'
                };
                
                let reason = '';
                
                // Si es una acción de baneo, pedir razón
                if (action === 'ban') {
                    const { value: inputReason } = await Swal.fire({
                        title: `¿Banear ${count} dispositivos?`,
                        input: 'textarea',
                        inputLabel: 'Razón del baneo',
                        inputPlaceholder: 'Especifica la razón para banear estos dispositivos...',
                        inputAttributes: {
                            'aria-label': 'Razón del baneo'
                        },
                        showCancelButton: true,
                        confirmButtonText: 'Sí, banear',
                        cancelButtonText: 'Cancelar',
                        confirmButtonColor: '#d33',
                        inputValidator: (value) => {
                            if (!value.trim()) {
                                return 'Debes especificar una razón para el baneo';
                            }
                        }
                    });
                    
                    if (!inputReason) return;
                    reason = inputReason;
                } else {
                    // Para otras acciones, confirmación simple
                    const confirmed = await this.showConfirmation(
                        `¿${actionText[action].charAt(0).toUpperCase() + actionText[action].slice(1)} dispositivos?`,
                        `¿Estás seguro de que quieres ${actionText[action]} ${count} dispositivos seleccionados?${action === 'delete' ? ' Esta acción no se puede deshacer.' : ''}`,
                        `Sí, ${actionText[action]}`
                    );
                    
                    if (!confirmed) return;
                }
                
                try {
                    await this.apiPost(this.urls.bulkAction, {
                        action: action,
                        device_ids: this.selectedDevices,
                        reason: reason
                    });
                    
                    this.showSuccess(
                        'Acción completada',
                        `${count} dispositivos ${actionText[action]}dos exitosamente`
                    );
                    
                    // Limpiar selección y recargar datos
                    this.selectedDevices = [];
                    await this.loadHwidData();
                    
                    // Emitir evento SocketIO
                    if (this.isSocketConnected) {
                        this.emitSocket(`bulk_${action}`, {
                            count: count,
                            action: action
                        });
                    }
                    
                } catch (error) {
                    console.error(`Error en acción en lote ${action}:`, error);
                }
            },
            
            /**
             * Mostrar detalles de dispositivo en modal
             */
            showDeviceDetails(device) {
                this.selectedDevice = { ...device };
                
                const modal = new bootstrap.Modal(document.getElementById('deviceDetailModal'));
                modal.show();
            },
            
            /**
             * Manejar notificaciones desde SocketIO
             */
            handleSocketNotification(data) {
                // Llamar al método padre
                SocketMixin.methods.handleSocketNotification.call(this, data);
                
                // Manejar notificaciones específicas de HWID
                if (data.data && data.data.action) {
                    switch (data.data.action) {
                        case 'device_added':
                        case 'device_banned':
                        case 'device_unbanned':
                        case 'device_deleted':
                            // Recargar datos cuando otro admin modifica dispositivos
                            this.loadHwidData();
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
             * Observar cambios en filtros para aplicar debounce en búsqueda
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
            
            /**
             * Observar cambios en selectedDevices para actualizar selectAll
             */
            selectedDevices: {
                handler() {
                    this.updateSelectAllState();
                },
                deep: true
            }
        }
    });
    
    // Exponer para debugging en desarrollo
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        window.hwidApp = hwidApp;
        console.log('✅ HWID app disponible en window.hwidApp para debugging');
    }
    
    console.log('✅ HWID Management Vue.js inicializado exitosamente');
});