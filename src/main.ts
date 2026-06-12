import { App } from './app/app'
import { Environment } from './environment';
import './style.css'

// Necesario entrypoint de Tau Prolog
declare global {
    const pl: any;
}

await new Promise<void>((resolve, reject) => {
    const script = document.createElement('script');
    script.src = Environment.PROLOG_ENGINE_PUBLIC_FILE_PATH;

    script.onload = () => {
        console.log("Tau Prolog loaded");
        resolve();
    };

    script.onerror = () => {
        reject(new Error(`Could not load Tau Prolog`));
    };

    document.head.appendChild(script);
});

App.run()