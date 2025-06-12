/**
 * messages.js - Lógica Vue.js para gestión de mensajes y noticias
 * Carga datos del servidor y maneja estado reactivo
 */

document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 DOMContentLoaded - Iniciando Messages Vue.js');
    
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
    if (typeof window.MESSAGES_DATA === 'undefined') {
        console.error('❌ MESSAGES_DATA no está disponible');
        window.MESSAGES_DATA = {
            messages: [],
            urls: {}
        };
    }
    
    console.log('✅ Todas las dependencias disponibles');
    console.log('📨 Datos de mensajes iniciales:', window.MESSAGES_DATA);
    
    // Configurar delimitadores de Vue
    Vue.config.delimiters = ['[[', ']]'];
    
    // Crear instancia Vue para Messages
    const messagesApp = new Vue({
        el: '#app',
        delimiters: ['[[', ']]'],
        mixins: [NotificationMixin, HttpMixin, UtilsMixin, SocketMixin],
        
        data() {
            return {
                // Datos del servidor
                messages: window.MESSAGES_DATA.messages || [],
                urls: window.MESSAGES_DATA.urls || {},
                
                // Filtros
                filters: {
                    search: '',
                    type: '',
                    status: ''
                },
                
                // Selección
                selectedMessages: [],
                selectAllChecked: false,
                
                // Modal
                selectedMessage: null,
                
                // Estados
                loading: false, // Controla el overlay de carga global
                loadingMessage: 'Cargando...',
                updating: false,
                
                // SocketIO (gestionado por SocketMixin)
                isSocketConnected: false,
                socket: null
            };
        },
        
        computed: {
            /**
             * Estadísticas calculadas de los mensajes
             */
            statistics() {
                const total = this.messages.length;
                const active = this.messages.filter(m => m.is_active).length;
                const updates = this.messages.filter(m => m.type === 'Actualización').length;
                const news = this.messages.filter(m => m.type === 'Noticia').length;
                
                return {
                    totalMessages: total,
                    activeMessages: active,
                    updateMessages: updates,
                    newsMessages: news
                };
            },
            
            /**
             * Mensajes filtrados según los criterios aplicados
             */
            filteredMessages() {
                let result = [...this.messages];
                
                // Filtro por búsqueda (mensaje y tipo)
                if (this.filters.search) {
                    const search = this.filters.search.toLowerCase();
                    result = result.filter(message => 
                        message.message.toLowerCase().includes(search) ||
                        message.type.toLowerCase().includes(search)
                    );
                }
                
                // Filtro por tipo
                if (this.filters.type) {
                    result = result.filter(message => message.type === this.filters.type);
                }
                
                // Filtro por estado
                if (this.filters.status) {
                    const isActive = this.filters.status === 'active';
                    result = result.filter(message => message.is_active === isActive);
                }
                
                return result;
            }
        },
        
        mounted() {
            console.log('✅ Messages Vue montado');
            
            // Inicializar SocketIO
            this.initSocket();
            
            // Procesar mensajes para agregar propiedades reactivas
            this.processMessages();
            
            // Auto-focus en búsqueda
            this.$nextTick(() => {
                const searchInput = this.$el.querySelector('input[placeholder*="Buscar"]');
                if (searchInput) {
                    searchInput.focus();
                }
            });
            
            console.log('Messages management inicializado correctamente');
        },
        
        methods: {
            /**
             * Procesar mensajes para agregar propiedades reactivas
             */
            processMessages() {
                this.messages = this.messages.map(message => ({
                    ...message,
                    showFull: false // Para el toggle de texto completo
                }));
            },
            
            /**
             * Aplicar filtros
             */
            applyFilters() {
                // Los filtros son reactivos, no necesitamos hacer nada más
                this.updateSelection();
            },
            
            /**
             * Limpiar todos los filtros
             */
            clearFilters() {
                this.filters.search = '';
                this.filters.type = '';
                this.filters.status = '';
                this.updateSelection();
            },
            
            /**
             * Toggle select all messages
             */
            toggleSelectAll() {
                if (this.selectAllChecked) {
                    this.selectedMessages = this.filteredMessages.map(message => message.id);
                } else {
                    this.selectedMessages = [];
                }
            },
            
            /**
             * Actualizar estado de selección
             */
            updateSelection() {
                const visibleIds = this.filteredMessages.map(message => message.id);
                const selectedOnPage = this.selectedMessages.filter(id => visibleIds.includes(id));
                
                this.selectAllChecked = visibleIds.length > 0 && selectedOnPage.length === visibleIds.length;
            },
            
            /**
             * Obtener icono según tipo de mensaje
             */
            getTypeIcon(type) {
                const icons = {
                    'Actualización': 'bi bi-arrow-up-circle text-info',
                    'Noticia': 'bi bi-newspaper text-primary',
                    'Mantenimiento': 'bi bi-tools text-warning',
                    'Evento': 'bi bi-calendar-event text-success',
                    'Promoción': 'bi bi-gift text-danger',
                    'Aviso': 'bi bi-exclamation-triangle text-warning'
                };
                
                return icons[type] || 'bi bi-chat-dots text-secondary';
            },
            
            /**
             * Obtener clase de badge según tipo de mensaje
             */
            getTypeBadgeClass(type) {
                const classes = {
                    'Actualización': 'badge bg-info',
                    'Noticia': 'badge bg-primary',
                    'Mantenimiento': 'badge bg-warning',
                    'Evento': 'badge bg-success',
                    'Promoción': 'badge bg-danger',
                    'Aviso': 'badge bg-warning'
                };
                
                return classes[type] || 'badge bg-secondary';
            },
            
            /**
             * Obtener icono para vista previa según tipo
             */
            getPreviewIcon(type) {
                if (type === 'Actualización') {
                    return '/static/hot.gif';
                }
                return '/static/new.gif';
            },
            
            /**
             * Toggle mostrar mensaje completo
             */
            toggleFullMessage(message) {
                message.showFull = !message.showFull;
            },
            
            /**
             * Cambiar estado de mensaje (activo/inactivo)
             */
            async toggleMessageStatus(message) {
                const confirmed = await this.showConfirmation(
                    '¿Cambiar estado del mensaje?',
                    `¿Estás seguro de que quieres ${message.is_active ? 'activar' : 'desactivar'} este mensaje?`,
                    'Sí, cambiar'
                );
                
                if (!confirmed) {
                    // Revertir el cambio si se cancela
                    message.is_active = !message.is_active;
                    return;
                }
                
                this.updating = true;
                
                try {
                    // Enviar petición al servidor
                    const url = this.urls.toggleStatus.replace('0', message.id);
                    await this.apiPost(url);
                    
                    const status = message.is_active ? 'activado' : 'desactivado';
                    this.showSuccess('Estado actualizado', `Mensaje ${status} exitosamente`);
                    
                    // Emitir evento SocketIO
                    if (this.isSocketConnected) {
                        this.emitSocket('message_toggled', {
                            message_id: message.id,
                            is_active: message.is_active
                        });
                    }
                    
                } catch (error) {
                    // Revertir el cambio en caso de error
                    message.is_active = !message.is_active;
                    console.error('Error toggling message status:', error);
                    // handleHttpError en HttpMixin ya muestra el error
                } finally {
                    this.updating = false;
                }
            },
            
            /**
             * Mostrar detalles de mensaje en modal
             */
            showMessageDetails(message) {
                this.selectedMessage = { ...message };
                
                // Mostrar modal usando Bootstrap
                const modal = new bootstrap.Modal(document.getElementById('messageDetailModal'));
                modal.show();
            },
            
            /**
             * Eliminar mensaje individual
             */
            async deleteMessage(message) {
                const confirmed = await this.showConfirmation(
                    '¿Eliminar mensaje?',
                    `¿Estás seguro de que quieres eliminar este mensaje "${message.type}"? Esta acción no se puede deshacer.`,
                    'Sí, eliminar'
                );
                
                if (!confirmed) return;
                
                this.updating = true;
                
                try {
                    const url = this.urls.deleteMessage.replace('0', message.id);
                    await this.apiPost(url);
                    
                    // Remover mensaje de la lista local
                    this.messages = this.messages.filter(m => m.id !== message.id);
                    
                    // Remover de selección si estaba seleccionado
                    this.selectedMessages = this.selectedMessages.filter(id => id !== message.id);
                    
                    this.showSuccess('Mensaje eliminado', 'El mensaje ha sido eliminado exitosamente');
                    
                    // Emitir evento SocketIO
                    if (this.isSocketConnected) {
                        this.emitSocket('message_deleted', {
                            message_id: message.id,
                            type: message.type
                        });
                    }
                    
                } catch (error) {
                    console.error('Error deleting message:', error);
                    // handleHttpError en HttpMixin ya muestra el error
                } finally {
                    this.updating = false;
                }
            },
            
            /**
             * Eliminar mensajes seleccionados
             */
            async deleteSelected() {
                if (this.selectedMessages.length === 0) {
                    this.showWarning('Sin selección', 'No hay mensajes seleccionados para eliminar');
                    return;
                }
                
                const count = this.selectedMessages.length;
                const confirmed = await this.showConfirmation(
                    '¿Eliminar mensajes seleccionados?',
                    `¿Estás seguro de que quieres eliminar ${count} mensaje${count > 1 ? 's' : ''}? Esta acción no se puede deshacer.`,
                    'Sí, eliminar todos'
                );
                
                if (!confirmed) return;
                
                this.updating = true;
                
                try {
                    const formData = new FormData();
                    this.selectedMessages.forEach(id => {
                        formData.append('message_ids', id);
                    });
                    
                    await axios.post(this.urls.deleteSelected, formData, {
                        headers: {
                            'Content-Type': 'multipart/form-data'
                        }
                    });
                    
                    // Remover mensajes de la lista local
                    this.messages = this.messages.filter(message => !this.selectedMessages.includes(message.id));
                    
                    // Limpiar selección
                    this.selectedMessages = [];
                    this.updateSelection();
                    
                    this.showSuccess(
                        'Mensajes eliminados', 
                        `${count} mensaje${count > 1 ? 's han' : ' ha'} sido eliminado${count > 1 ? 's' : ''} exitosamente`
                    );
                    
                    // Emitir evento SocketIO
                    if (this.isSocketConnected) {
                        this.emitSocket('messages_deleted', { count });
                    }
                    
                } catch (error) {
                    console.error('Error deleting messages:', error);
                    // handleHttpError en HttpMixin ya muestra el error
                } finally {
                    this.updating = false;
                }
            },
            
            /**
             * Activar mensajes seleccionados
             */
            async activateSelected() {
                if (this.selectedMessages.length === 0) {
                    this.showWarning('Sin selección', 'No hay mensajes seleccionados para activar');
                    return;
                }
                
                const count = this.selectedMessages.length;
                const confirmed = await this.showConfirmation(
                    '¿Activar mensajes seleccionados?',
                    `¿Activar ${count} mensaje${count > 1 ? 's' : ''} seleccionado${count > 1 ? 's' : ''}?`,
                    'Sí, activar'
                );
                
                if (!confirmed) return;
                
                this.updating = true;
                
                try {
                    // Activar mensajes localmente
                    let activatedCount = 0;
                    for (const messageId of this.selectedMessages) {
                        const message = this.messages.find(m => m.id === messageId);
                        if (message && !message.is_active) {
                            const url = this.urls.toggleStatus.replace('0', messageId);
                            await this.apiPost(url);
                            message.is_active = true;
                            activatedCount++;
                        }
                    }
                    
                    this.showSuccess(
                        'Mensajes activados', 
                        `${activatedCount} mensaje${activatedCount > 1 ? 's han' : ' ha'} sido activado${activatedCount > 1 ? 's' : ''}`
                    );
                    
                    // Limpiar selección
                    this.selectedMessages = [];
                    this.updateSelection();
                    
                } catch (error) {
                    console.error('Error activating messages:', error);
                    // handleHttpError en HttpMixin ya muestra el error
                } finally {
                    this.updating = false;
                }
            },
            
            /**
             * Alternar todos los mensajes (activo/inactivo)
             */
            async toggleAllMessages() {
                const allActive = this.messages.every(message => message.is_active);
                const action = allActive ? 'desactivar' : 'activar';
                
                const confirmed = await this.showConfirmation(
                    `¿${action.charAt(0).toUpperCase() + action.slice(1)} todos los mensajes?`,
                    `¿Estás seguro de que quieres ${action} todos los mensajes?`,
                    `Sí, ${action} todos`
                );
                
                if (!confirmed) return;
                
                this.updating = true;
                
                try {
                    let updatedCount = 0;
                    for (const message of this.messages) {
                        if (message.is_active === allActive) {
                            const url = this.urls.toggleStatus.replace('0', message.id);
                            await this.apiPost(url);
                            message.is_active = !allActive;
                            updatedCount++;
                        }
                    }
                    
                    this.showSuccess(
                        'Mensajes actualizados', 
                        `${updatedCount} mensaje${updatedCount > 1 ? 's han' : ' ha'} sido ${action}${updatedCount > 1 ? 's' : ''}`
                    );
                    
                } catch (error) {
                    console.error('Error toggling all messages:', error);
                    // handleHttpError en HttpMixin ya muestra el error
                } finally {
                    this.updating = false;
                }
            },
            
            /**
             * Duplicar mensaje
             */
            duplicateMessage(message) {
                // Aquí se podría implementar una funcionalidad de duplicación
                // Por ahora, redirigir a crear mensaje con parámetros
                const params = new URLSearchParams({
                    type: message.type,
                    message: message.message,
                    priority: message.priority
                });
                
                window.location.href = `${this.urls.createMessage}?${params.toString()}`;
            },
            
            /**
             * Editar mensaje
             */
            editMessage(message) {
                // Aquí se podría implementar un modal de edición o redirigir
                this.showInfo('Función de edición', 'La edición de mensajes se implementará próximamente');
            },
            
            /**
             * Cambiar prioridad de mensaje
             */
            async changePriority(message) {
                // Usar SweetAlert2 para input
                const { value: newPriority } = await Swal.fire({
                    title: 'Cambiar Prioridad',
                    text: `Prioridad actual: ${message.priority}`,
                    input: 'number',
                    inputValue: message.priority,
                    inputAttributes: {
                        min: 1,
                        max: 5,
                        step: 1
                    },
                    showCancelButton: true,
                    confirmButtonText: 'Cambiar',
                    cancelButtonText: 'Cancelar',
                    inputValidator: (value) => {
                        if (!value || value < 1 || value > 5) {
                            return 'La prioridad debe ser un número entre 1 y 5';
                        }
                    }
                });
                
                if (newPriority && newPriority !== message.priority) {
                    message.priority = parseInt(newPriority);
                    this.showSuccess('Prioridad actualizada', `Nueva prioridad: ${newPriority}`);
                    
                    // Aquí se podría enviar al servidor
                    // await this.apiPost(`/admin/messages/${message.id}/priority`, { priority: newPriority });
                }
            },
            
            /**
             * Vista previa en launcher
             */
            previewInLauncher() {
                window.open('/api/message', '_blank');
            },
            
            /**
             * Exportar mensajes como CSV
             */
            exportMessages() {
                const messages = this.filteredMessages.map(message => ({
                    tipo: message.type,
                    mensaje: message.message.replace(/"/g, '""'), // Escapar comillas
                    estado: message.is_active ? 'Activo' : 'Inactivo',
                    prioridad: message.priority,
                    fecha: this.formatDate(message.created_at)
                }));
                
                const csv = 'Tipo,Mensaje,Estado,Prioridad,Fecha\n' +
                    messages.map(m => `"${m.tipo}","${m.mensaje}","${m.estado}","${m.prioridad}","${m.fecha}"`).join('\n');
                
                this.downloadFile('data:text/csv;charset=utf-8,' + encodeURIComponent(csv), 'mensajes.csv');
                
                this.showSuccess('Exportación completada', 'Mensajes exportados como mensajes.csv');
            },
            
            /**
             * Generar JSON del mensaje para mostrar en modal
             */
            getMessageJSON(message) {
                return JSON.stringify({
                    type: message.type,
                    message: message.message
                }, null, 2);
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
                        case 'message_created':
                            this.showInfo('Nuevo mensaje', 'Se ha creado un nuevo mensaje. Recargando lista...');
                            // Aquí podrías recargar los datos o agregar el nuevo mensaje
                            break;
                            
                        case 'message_updated':
                            if (data.data.message_id) {
                                const message = this.messages.find(m => m.id === data.data.message_id);
                                if (message && data.data.is_active !== undefined) {
                                    message.is_active = data.data.is_active;
                                }
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
             * Observar cambios en selectedMessages para actualizar selectAll
             */
            selectedMessages: {
                handler() {
                    this.updateSelection();
                },
                deep: true
            },
            
            /**
             * Observar cambios en filtros para limpiar selección
             */
            'filters.search'() {
                this.selectedMessages = [];
            },
            
            'filters.type'() {
                this.selectedMessages = [];
            },
            
            'filters.status'() {
                this.selectedMessages = [];
            }
        }
    });
    
    // Exponer para debugging en desarrollo
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        window.messagesApp = messagesApp;
        console.log('✅ Messages app disponible en window.messagesApp para debugging');
    }
    
    console.log('✅ Messages Vue.js inicializado exitosamente');
});