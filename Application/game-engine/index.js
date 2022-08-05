import {SocketController} from "./controllers/socketController.js";
import {ControllerHttpRequest} from "./controllers/controllerHttpRequest.js";
import {GameDataService} from "./services/gameData.service.js";
import {GameEngineConfig} from "./services/gameEngineConfig.js";


let gameData = new GameDataService();

let s =new SocketController(gameData);
let httpController = new ControllerHttpRequest(gameData, s);

await s.loadData();

httpController.startServer(GameEngineConfig.HOSTNAME, GameEngineConfig.HTTPPORT);
s.start();
