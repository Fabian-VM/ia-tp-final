import { Environment } from "../../environment";
import type { PrologData } from "./prolog-data";

export class PrologClient {

    private static instance: PrologClient | null = null;
    private session: any;
    private tauPrologImports = `
        :- use_module(library(charsio)).
        :- use_module(library(concurrent)).
        :- use_module(library(core)).
        :- use_module(library(dom)).
        :- use_module(library(format)).
        :- use_module(library(js)).
        :- use_module(library(lists)).
        :- use_module(library(os)).
        :- use_module(library(promises)).
        :- use_module(library(random)).
        :- use_module(library(statistics)).
    `

    private constructor(){
        this.init()
    }

    public static getClient(): PrologClient {
        if (!PrologClient.instance) {
            PrologClient.instance = new PrologClient();
        }
        return PrologClient.instance;
    }

    public async loadData(data: PrologData): Promise<void> {
        return await this.loadPrologCode(data.getFacts().toString());
    }

    public async queryOnce(query: string): Promise<any> {
        const results = await this.queryAll(query);
        return results.length > 0
            ? results[0]
            : null;
    }
    
    public async queryAll(query: string): Promise<any[]> {
        return new Promise((resolve, reject) => {
            const results: any[] = [];

            this.session.query(query, {
                success: () => {
                    const next = () => {
                        this.session.answer((answer: any) => {

                            if (answer === false) {
                                resolve(results);
                                return;
                            }

                            // Éxito sin variables
                            if (answer && answer.links && Object.keys(answer.links).length === 0) {
                                results.push(true);
                                resolve(results);
                                return;
                            }

                            // Respuesta con variables
                            if (answer?.links) {
                                const row: Record<string, any> = {};

                                for (const [name, term] of Object.entries(answer.links)) {
                                    row[name] = this.termToValue(term);
                                }

                                results.push(row);
                                next();
                                return;
                            }

                            results.push(this.termToValue(answer));
                            resolve(results);
                        });
                    };

                    next();
                },

            error: (err: any) => {
                console.error("Error en consulta Prolog:", query);
                console.error("Tau error:", err);
                reject(err);
            }            });
        });
    }
    private async init(): Promise<void> {
        this.session = pl.create()
        await this.loadPrologCode(this.tauPrologImports)
        await this.loadPrologCode(await this.readFile(Environment.PROLOG_PROGRAM_PUBLIC_FILE_PATH))
    }

    private async readFile(path: string): Promise<string> {
        const response = await fetch(path);
        if (!response.ok) {
            throw new Error('Error reading '+path);
        }
        return await response.text();
    }

    private async loadPrologCode(program: string): Promise<void> {
        return new Promise((resolve, reject) => {
            this.session.consult(program, {
                success: () => resolve(),
                error: (err: any) => reject(err)
            });
        });
    }

    private termToValue(term: any): any {
        if (!term) return null;

        // Número
        if ("value" in term) {
            return term.value;
        }

        // Lista vacía
        if (term.id === "[]") {
            return [];
        }

        // Lista
        if (term.id === ".") {
            const result = [];

            let current = term;

            while (current.id === ".") {
                result.push(this.termToValue(current.args[0]));
                current = current.args[1];
            }

            return result;
        }

        // Átomo
        if (!term.args || term.args.length === 0) {
            return term.id;
        }

        // Estructura compuesta
        return {
            functor: term.id,
            args: term.args.map((arg: any) => this.termToValue(arg))
        };
    }

}