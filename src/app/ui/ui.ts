import { PrologClient } from "../model/prolog-client";
import { PrologData } from "../model/prolog-data";

export class UI {

    public static init(prologEngine: PrologClient): void {
        const dropZone = document.getElementById("drop-zone")!;

        dropZone.addEventListener("dragover", (e) => {
            e.preventDefault();
        });

        dropZone.addEventListener("drop", async (e) => {
            e.preventDefault();

            // Cargar contenido
            const file = e.dataTransfer?.files[0];
            if (!file) {
                return;
            }
            const content = JSON.parse(await file.text());
            const data = new PrologData(content);
            prologEngine.loadData(data);
            prologEngine.queryAll("depth_limited_search([], [], [3, 3, izquierda, 0, 0], 11, SolucionEstados, SolucionViajes).")
            .then(console.log)
            .catch(console.error)
        });

        console.log('UI initialized')
    }
}
