type FactValue = string | number;
type FactArguments = [FactValue, ...FactValue[]];

export class PrologFactCollection {
    private readonly facts = new Map<string, FactArguments[]>();

    constructor(data: Record<string, FactArguments[]>) {
        for (const [functor, tuples] of Object.entries(data)) {
            if (!functor.trim()) {
                throw new Error("El functor no puede estar vacío");
            }

            if (!Array.isArray(tuples) || tuples.length === 0) {
                throw new Error(
                    `El functor "${functor}" debe tener al menos un hecho`
                );
            }

            for (const tuple of tuples) {
                if (!Array.isArray(tuple) || tuple.length === 0) {
                    throw new Error(
                        `El functor "${functor}" contiene un hecho vacío`
                    );
                }

                for (const value of tuple) {
                    if (
                        typeof value !== "string" &&
                        typeof value !== "number"
                    ) {
                        throw new Error(
                            `Valor inválido en "${functor}": ${value}`
                        );
                    }
                }
            }

            this.facts.set(functor, tuples);
        }
    }

    get(functor: string): FactArguments[] | undefined {
        return this.facts.get(functor);
    }

    entries(): IterableIterator<[string, FactArguments[]]> {
        return this.facts.entries();
    }

    toString(): string {
        const lines: string[] = [];

        for (const [functor, tuples] of this.facts) {
            for (const tuple of tuples) {
                lines.push(`${functor}(${tuple.join(", ")}).`);
            }
        }

        return lines.join("\n");
    }
}