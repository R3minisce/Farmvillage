import {GameEvent} from "../models/data/gameEvent.js";

export class GameEventsList{
    static eventsList = [
        // new GameEvent("invasion", 30, 300, 0.7,1),
        // new GameEvent("invasion", 60, 900, 0.4,2),
        // new GameEvent("calamity", 60, 600, 0.7,1),
        // new GameEvent("calamity", 60, 1200, 0.3,2)
        new GameEvent("invasion", 30, 200, 1,1),
        new GameEvent("invasion", 60, 426, 0.9,2),
        new GameEvent("calamity", 60, 300, 1,1),
        new GameEvent("calamity", 60, 480, 0.9,2)
    ];
}