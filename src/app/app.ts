import { PrologClient } from "./model/prolog-client";
import { UI } from "./ui/ui";

export class App{

    public static run(){
        let prologEngine = PrologClient.getClient()

        UI.init(prologEngine)

    }
}
