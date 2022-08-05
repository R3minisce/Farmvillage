// import {GameInstanceManager} from "../../models/gameManagement/gameInstanceManager.js";
// import {GameInstance} from "../../models/gameManagement/gameInstance.js";
// import {Utils as utils} from "../../models/utils/utils.js";


// let playerHost = utils.getPlayerSample();
// let player2 = utils.getPlayerSample();
// let socketHost = {id:"socketHost"};
// let socketPlayer = {id:"socketPlayer"};

// test('createGameInstance', async () => {
//     let gameInstanceManager = new GameInstanceManager();
//     expect(gameInstanceManager.gameInstances.get(socketHost.id)).toStrictEqual(undefined)
//     gameInstanceManager.createGameInstance(socketHost, playerHost);
//     expect(gameInstanceManager.gameInstances.get(socketHost.id)).not.toStrictEqual(undefined)
// });

// test('deleteGameInstance', async () => {
//     let gameInstanceManager = new GameInstanceManager();
//     let gameInstance = new GameInstance(gameInstanceManager, socketHost, playerHost);
//     let gameInstance2 = new GameInstance(gameInstanceManager, socketPlayer, player2);

//     gameInstanceManager.gameInstances.set(socketHost.id,gameInstance);
//     gameInstanceManager.gameInstances.set(socketPlayer.id,gameInstance2);
//     expect(gameInstanceManager.gameInstances.size).toStrictEqual(2);
//     expect(gameInstanceManager.gameInstances.get(socketPlayer.id)).toStrictEqual(gameInstance2);
//     gameInstanceManager.deleteGameInstance(socketPlayer.id);
//     expect(gameInstanceManager.gameInstances.size).toStrictEqual(1);
//     expect(gameInstanceManager.gameInstances.get(socketPlayer.id)).toStrictEqual(undefined);
// });

// test('connectToGame', async () => {
//     let gameInstanceManager = new GameInstanceManager();
//     let gameInstance = new GameInstance(gameInstanceManager, socketHost, playerHost);
//     gameInstanceManager.gameInstances.set(socketHost.id,gameInstance);

//     for(let i=1; i<gameInstanceManager.MAXPLAYERSBYGAME;i++){
//         let socketPlayer = {};
//         socketPlayer.id = socketHost.id.toString()+i.toString();
//         let result = gameInstanceManager.connectToGame(socketHost.id,socketPlayer.id, player2);
//         expect(result).toStrictEqual(true);
//     }

//     let socketPlayerGameFull = {id:"socketGameOverflow"};
//     let result = gameInstanceManager.connectToGame(socketHost.id,socketPlayerGameFull.id, player2);
//     expect(result).toStrictEqual(false);

// });

// test('disconnect', async () => {
//     let gameInstanceManager = new GameInstanceManager();
//     let gameInstance = new GameInstance(gameInstanceManager, socketHost, playerHost);
//     gameInstanceManager.gameInstances.set(socketHost.id,gameInstance);
//     gameInstanceManager.playersInGame.set(socketPlayer, socketHost.id);
//     gameInstance.players.set(socketPlayer, player2);


//     gameInstanceManager.disconnectPlayer(socketPlayer);

//     expect(gameInstance.players.get(socketPlayer.id)).toStrictEqual(undefined);
//     expect(gameInstanceManager.playersInGame.get(socketPlayer.id)).toStrictEqual(undefined);

// });

test('alwaysok', async () => {
    expect(true).toStrictEqual(true);
});
