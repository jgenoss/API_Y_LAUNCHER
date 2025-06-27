/**
 * launcher.js - Lógica Vue.js para gestión de versiones del launcher
 * Separado completamente del template HTML
 */

document.addEventListener('DOMContentLoaded', function () {
    console.log('🚀 DOMContentLoaded - Iniciando Launcher Vue.js');

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
    if (typeof window.LAUNCHER_DATA === 'undefined') {
        console.error('❌ LAUNCHER_DATA no está disponible');
        window.LAUNCHER_DATA = { launchers: [], baseUrl: '' };
    }

    console.log('✅ Todas las dependencias disponibles');
    console.log('🚀 Datos de launchers:', window.LAUNCHER_DATA);

    // Configurar delimitadores de Vue
    Vue.config.delimiters = ['[[', ']]'];

    // Crear instancia Vue para Launcher Management
    const launcherApp = new Vue({
        el: '#app',
        delimiters: ['[[', ']]'],
        mixins: [NotificationMixin, HttpMixin, UtilsMixin, SocketMixin],

        data() {
            return {
                // Datos del servidor
                launchers: window.LAUNCHER_DATA.launchers || [],
                baseUrl: window.LAUNCHER_DATA.baseUrl || '',

                // Launcher seleccionado para modal
                selectedLauncher: {},

                // Estados
                loading: false,
                loadingMessage: 'Cargando...',

                // SocketIO
                isSocketConnected: false,
                socket: null
            };
        },

        computed: {
            /**
             * Estadísticas calculadas de los launchers
             */
            stats() {
                const totalVersions = this.launchers.length;
                const currentLauncher = this.launchers.find(l => l.is_current);
                const currentVersion = currentLauncher ? currentLauncher.version : null;
                const archivedVersions = this.launchers.filter(l => !l.is_current).length;

                // Calcular tamaño total
                let totalSize = 0;
                this.launchers.forEach(launcher => {
                    if (launcher.file_size) {
                        totalSize += launcher.file_size;
                    }
                });

                return {
                    totalVersions,
                    currentVersion,
                    archivedVersions,
                    totalSizeFormatted: this.formatFileSize(totalSize)
                };
            },

            /**
             * Launcher actual
             */
            currentLauncher() {
                return this.launchers.find(l => l.is_current) || null;
            },
            hasArchivedLaunchers() {
                return this.launchers.filter(l => !l.is_current).length > 0;
            }
        },

        mounted() {
            console.log('✅ Launcher Vue montado');

            // Inicializar SocketIO
            this.initSocket();

            // Procesar datos de launchers para agregar propiedades calculadas
            this.processLauncherData();

            console.log('Launcher management inicializado correctamente');
        },

        methods: {
            /**
             * Procesar datos de launchers para agregar propiedades calculadas
             */
            processLauncherData() {
                this.launchers = this.launchers.map(launcher => {
                    return {
                        ...launcher,
                        file_size_formatted: launcher.file_size ? this.formatFileSize(launcher.file_size) : null,
                        created_at: launcher.created_at // Ya viene como string del servidor
                    };
                });

                console.log('✅ Datos de launchers procesados:', this.launchers.length);
            },

            /**
             * Formatear notas de versión para HTML
             */
            formatReleaseNotes(notes) {
                if (!notes) return '';
                return notes.replace(/\n/g, '<br>');
            },

            /**
             * Obtener URL de descarga
             */
            getDownloadUrl(filename) {
                return `${this.baseUrl}Launcher/${filename}`;
            },

            /**
             * Obtener URL de API
             */
            getApiUrl() {
                return `${this.baseUrl}api/launcher_update`;
            },

            /**
             * Probar descarga de launcher
             */
            async testLauncherDownload(filename) {
                const testUrl = `/Launcher/${filename}`;

                try {
                    const response = await fetch(testUrl, { method: 'HEAD' });

                    if (response.ok) {
                        this.showSuccess(
                            'Test de descarga exitoso',
                            `✅ El launcher ${filename} está disponible para descarga`
                        );
                    } else {
                        this.showError(
                            'Error en test de descarga',
                            `❌ Error ${response.status}: El launcher ${filename} no está disponible`
                        );
                    }
                } catch (error) {
                    this.showError(
                        'Error de conexión',
                        `❌ Error de conexión: ${error.message}`
                    );
                }
            },

            /**
             * Probar endpoint de actualización del launcher
             */
            async testLauncherUpdate() {
                try {
                    const data = await this.apiGet('/api/launcher_update');
                    this.showSuccess(
                        'API funcionando correctamente',
                        `✅ Versión actual: ${data.version} - Archivo: ${data.file_name}`
                    );
                } catch (error) {
                    this.showError(
                        'Error en la API',
                        `❌ Error en la API: ${error.message}`
                    );
                }
            },

            /**
             * Confirmar establecer launcher como actual
             */
            async confirmSetCurrent(event, launcher) {
                event.preventDefault();

                const confirmed = await this.showConfirmation(
                    '¿Establecer como versión actual?',
                    `¿Establecer ${launcher.version} como la versión actual del launcher?`,
                    'Sí, establecer'
                );

                if (confirmed) {
                    window.location.href = event.target.href || event.currentTarget.href;
                }
            },

            /**
             * Mostrar detalles de launcher en modal
             */
            showLauncherDetails(launcher) {
                this.selectedLauncher = { ...launcher };

                // Mostrar modal usando Bootstrap
                const modal = new bootstrap.Modal(document.getElementById('launcherDetailModal'));
                modal.show();
            },

            /**
             * Eliminar versión del launcher
             */
            async deleteLauncher(launcher) {
                if (launcher.is_current) {
                    this.showWarning(
                        'No se puede eliminar',
                        'No se puede eliminar la versión actual del launcher'
                    );
                    return;
                }

                const confirmed = await this.showConfirmation(
                    '¿Eliminar versión del launcher?',
                    `¿Eliminar la versión ${launcher.version} del launcher? Esta acción no se puede deshacer.`,
                    'Sí, eliminar'
                );

                if (!confirmed) return;

                try {
                    // Realizar petición de eliminación real
                    const response = await fetch(`/admin/launcher/${launcher.id}/delete`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        }
                    });

                    const data = await response.json();

                    if (data.success) {
                        // Eliminar launcher de la lista local
                        this.launchers = this.launchers.filter(l => l.id !== launcher.id);

                        this.showSuccess(
                            'Launcher eliminado',
                            data.message
                        );

                        // Emitir evento SocketIO si está conectado
                        if (this.isSocketConnected) {
                            this.emitSocket('launcher_deleted', {
                                version: launcher.version,
                                filename: launcher.filename
                            });
                        }

                        console.log('✅ Launcher eliminado exitosamente:', launcher.version);

                    } else {
                        throw new Error(data.error || 'Error desconocido');
                    }

                } catch (error) {
                    console.error('Error eliminando launcher:', error);
                    this.showError(
                        'Error al eliminar',
                        `Error eliminando launcher: ${error.message}`
                    );
                }
            },

            /**
             * Generar script de actualización
             */
            generateUpdateScript(version = null) {
                const currentVersion = version || 'latest';

                // Construir el nombre del archivo versionado correctamente
                const versionedFileName = currentVersion === 'latest'
                    ? 'PBLauncher_latest.exe'
                    : `PBLauncher_v${currentVersion}.exe`;

                const script = `@echo off
                    echo Actualizando Launcher...
                    curl -L -o LauncherUpdater.exe "${this.baseUrl}Launcher/LauncherUpdater.exe"
                    if exist LauncherUpdater.exe (
                        echo Iniciando actualizador...
                        LauncherUpdater.exe "${this.baseUrl.replace('/Launcher/', '/api')}" "%~dp0PBLauncher.exe" "${versionedFileName}"
                    ) else (
                        echo Error: No se pudo descargar el actualizador
                        pause
                    )`;

                // Crear y descargar script
                this.downloadTextAsFile(
                    script,
                    `update_launcher_${currentVersion}.bat`,
                    'text/plain'
                );
                this.showSuccess(
                    'Script generado',
                    `Script de actualización generado: update_launcher_${currentVersion}.bat`
                );
            },

            /**
             * Limpiar versiones antiguas
             */
            async cleanupOldVersions() {
                const archivedLaunchers = this.launchers.filter(l => !l.is_current);

                if (archivedLaunchers.length === 0) {
                    this.showWarning(
                        'Sin versiones archivadas',
                        'No hay versiones archivadas para eliminar'
                    );
                    return;
                }

                const confirmed = await this.showConfirmation(
                    '¿Limpiar versiones antiguas?',
                    `¿Eliminar todas las ${archivedLaunchers.length} versiones archivadas del launcher? Solo se mantendrá la versión actual.`,
                    'Sí, limpiar todas'
                );

                if (!confirmed) return;

                this.setLoading(true, 'Eliminando versiones archivadas...');

                try {
                    // Realizar petición de limpieza real
                    const response = await fetch('/admin/launcher/cleanup', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        }
                    });

                    const data = await response.json();

                    if (data.success) {
                        // Mantener solo la versión actual en la lista local
                        this.launchers = this.launchers.filter(l => l.is_current);

                        this.showSuccess(
                            'Limpieza completada',
                            data.message
                        );

                        // Mostrar advertencias si las hay
                        if (data.warnings && data.warnings.length > 0) {
                            data.warnings.forEach(warning => {
                                this.showWarning('Advertencia', warning);
                            });
                        }

                        // Emitir evento SocketIO si está conectado
                        if (this.isSocketConnected) {
                            this.emitSocket('launchers_cleaned', {
                                deleted_count: data.deleted_count
                            });
                        }

                        console.log('✅ Limpieza completada:', data.deleted_count, 'launchers eliminados');

                    } else {
                        throw new Error(data.error || 'Error desconocido');
                    }

                } catch (error) {
                    console.error('Error en limpieza:', error);
                    this.showError(
                        'Error en limpieza',
                        `Error limpiando versiones: ${error.message}`
                    );
                } finally {
                    this.setLoading(false);
                }
            },

            /**
             * Exportar historial de versiones
             */
            exportVersionHistory() {
                // MOVER aquí tu código actual de exportVersionHistory()
                const headers = ['Version', 'Filename', 'Status', 'Size', 'Date', 'Created_By'];

                const csvData = this.launchers.map(launcher => {
                    return [
                        launcher.version,
                        launcher.filename,
                        launcher.is_current ? 'En Producción' : 'Archivada',
                        launcher.file_size_formatted || 'N/A',
                        this.formatDate(launcher.created_at),
                        launcher.created_by ? 'Admin' : 'Sistema'
                    ];
                });

                const csvContent = [
                    headers.join(','),
                    ...csvData.map(row => row.map(cell => `"${cell}"`).join(','))
                ].join('\n');

                this.downloadTextAsFile(csvContent, 'launcher_versions.csv', 'text/csv');
                this.showSuccess('Historial exportado', 'Historial exportado como launcher_versions.csv');
            },

            /**
             * Descargar texto como archivo
             */
            downloadTextAsFile(content, filename, mimeType) {
                const blob = new Blob([content], { type: mimeType });
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = filename;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                window.URL.revokeObjectURL(url);
            },
            /**
             * Formatear fecha
             */
            formatDate(dateString, includeTime = false) {
                if (!dateString) return 'N/A';

                try {
                    const date = new Date(dateString);
                    const options = {
                        year: 'numeric',
                        month: '2-digit',
                        day: '2-digit'
                    };

                    if (includeTime) {
                        options.hour = '2-digit';
                        options.minute = '2-digit';
                        options.second = '2-digit';
                    }

                    return date.toLocaleDateString('es-ES', options);
                } catch (error) {
                    console.error('Error formateando fecha:', error);
                    return dateString;
                }
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
                        // ... tu código actual ...

                        case 'launcher_deleted':
                            // Otro usuario eliminó un launcher
                            if (data.data.version) {
                                this.showInfo(
                                    'Launcher eliminado',
                                    `La versión ${data.data.version} fue eliminada por otro usuario`
                                );
                                // Actualizar lista local
                                this.launchers = this.launchers.filter(l => l.version !== data.data.version);
                            }
                            break;

                        case 'launchers_cleaned':
                            this.showInfo(
                                'Versiones archivadas eliminadas',
                                `${data.data.deleted_count} versiones archivadas fueron eliminadas por otro usuario`
                            );
                            // Mantener solo versiones actuales
                            this.launchers = this.launchers.filter(l => l.is_current);
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
             * Observar cambios en el estado de conexión SocketIO
             */
            isSocketConnected(newValue, oldValue) {
                if (newValue !== oldValue) {
                    const status = newValue ? 'conectado' : 'desconectado';
                    console.log(`SocketIO ${status}`);
                }
            }
        }
    });

    // Exponer para debugging en desarrollo
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        window.launcherApp = launcherApp;
        console.log('✅ Launcher app disponible en window.launcherApp para debugging');
    }

    console.log('✅ Launcher Vue.js inicializado exitosamente');
});