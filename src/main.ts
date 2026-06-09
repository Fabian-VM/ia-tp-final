import { App } from './app/app'
import { Environment } from './environment';
import './style.css'

// Necesario entrypoint de Tau Prolog
declare global {
    const pl: any;
}

await new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = Environment.PROLOG_ENGINE_PUBLIC_FILE_PATH;
    script.onload = () => resolve(console.log("Tau Prolog loaded"));
    script.onerror = () => reject(new Error(`Could not load Tau Prolog`));
    document.head.appendChild(script);
});

App.run()