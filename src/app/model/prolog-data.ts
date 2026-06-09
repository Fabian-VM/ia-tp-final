import { PrologFactCollection } from "./prolog-fact-collection";

export class PrologData {
    private readonly student: string
    private readonly course: string
    private readonly facts: PrologFactCollection

    constructor(object: any) {
        if (!object.student?.trim()) {
            throw new Error("El estudiante no puede estar vacío");
        }

        if (!object.course?.trim()) {
            throw new Error("La materia no puede estar vacía");
        }

        this.student = object.student
        this.course = object.course
        this.facts = new PrologFactCollection(object.facts)
    }

    getStudent(): string {
        return this.student;
    }

    getCourse(): string {
        return this.course;
    }

    getFacts(): PrologFactCollection {
        return this.facts;
    }

}