import {GameInstance} from "./gameInstance.js";

export class GameInstanceManager{
    constructor(gameData) {
        this.MAXPLAYERSBYGAME = 4;
        this.gameInstances = new Map(); // socket host id -> gameInstance
        this.playersInGame = new Map(); // socket player  id -> socket id host connected
        this.villagesMap = new Map(); // village id -> gameInstance
        this.gameData = gameData;
    }

    /**
     * Load player data and create a new game instance
     * @param socketHost client socket of the host player
     * @param userHostData data about the host (id, token, name,...)
     */
    newGameInstance(socketHost, userData, selectedVillage){
        let gi = new GameInstance(this, socketHost, userData, selectedVillage);
        this.gameInstances.set(socketHost.id,gi);
        this.villagesMap.set(selectedVillage.Id, gi);
        this.playersInGame.set(socketHost.id, socketHost.id);
    }


    connectToGame(hostId, socketPlayer, userData){

        let gameInstance = this.gameInstances.get(hostId);
        if(gameInstance===undefined || gameInstance.getNumberPlayers() >= this.MAXPLAYERSBYGAME){
            return null;
        }else{
            this.disconnectPlayer(socketPlayer);
            this.playersInGame.set(socketPlayer.id,hostId);
            gameInstance.addPlayer(socketPlayer,userData);
            return {village: gameInstance.village, players: gameInstance.getPlayerList(userData.Username)};
        }
    }

    /**
     * Delete game instance
     * @param gameInstance
     */
    deleteGameInstance(hostId){
        let gameInstance = this.gameInstances.get(hostId);
        if(gameInstance !== undefined){
            for(let playerSocket of gameInstance.players.keys()){
                this.playersInGame.delete(playerSocket.id);
             }
            this.villagesMap.delete(gameInstance.village.Id);
            this.gameInstances.delete(hostId);
        }
    }

    /**
     * Remove player from game instance and game instance manager
     * @param socketPlayer
     */
    disconnectPlayer(socketPlayerId){
        this.disconnectPlayerFromGameInstance(socketPlayerId);
        this.playersInGame.delete(socketPlayerId);
    }

    /**
     * Disconnect player from game instance
     * @param socketPlayer
     */
    disconnectPlayerFromGameInstance(socketPlayerId){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketPlayerId);
        if(gameInstance !== undefined){
            gameInstance.removePlayer(socketPlayerId, "disconnection");
        }
    }

    getGameInstanceBySocketPlayerId(socketId){
        return this.gameInstances.get(this.playersInGame.get(socketId));
    }

    /**
     * Send error message to client
     * @param socket
     * @param message
     */
    sendErrorMessage(socket, message){
        try{
            socket.emit("error", {'message':message});
        }catch (err){}
    }

    // ----- PLAYER EVENTS ---
    movementEvent(socketPlayer,message){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketPlayer.id);
        if(gameInstance !== undefined){
            gameInstance.updatePlayerMovement(socketPlayer,message);
        }
    }

    attackEvent(socketPlayer,message){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketPlayer.id);
        if(gameInstance !== undefined){
            gameInstance.playerAttacked(socketPlayer,message);
        }
    }
    playerTakeDmgEvent(socketPlayer,message){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketPlayer.id);
        if(gameInstance !== undefined){
            gameInstance.playerTakeDmg(socketPlayer,message);
        }
    }
    // ----- AI EVENTS ----

    AISpawnEvent(socketPlayer, message){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketPlayer.id);
        if(gameInstance !== undefined){
            gameInstance.spawnAI(socketPlayer,message);
        }
    }
    AIMovementEvent(socketPlayer, message){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketPlayer.id);
        if(gameInstance !== undefined){
            gameInstance.updateAIMovement(socketPlayer,message);
        }
    }
    AIAttackEvent(socketPlayer, message){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketPlayer.id);
        if(gameInstance !== undefined){
            gameInstance.AIAttacked(socketPlayer,message);
        }
    }
    AITakeDmgEvent(socketPlayer, message){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketPlayer.id);
        if(gameInstance !== undefined){
            gameInstance.AITakeDmg(socketPlayer,message);
        }
    }


    //-------------- FROM HTTP ---------

    upgradeBuilding(socketId, buildingId){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketId);
        if(gameInstance!== undefined){
           return gameInstance.upgradeBuilding(socketId, buildingId, this.gameData.getBuildingStatsById(buildingId));
        }
        return null;
    }
    getBuildingInfo(socketId, buildingId){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketId);
        if(gameInstance!== undefined){
            return gameInstance.getBuildingInfo(buildingId);
        }
        return null;
    }
    depositResourceForUpgrade(socketId, buildingId, resourceLabel, resourceQuantity){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketId);
        if(gameInstance!== undefined){
            return gameInstance.depositResourceForUpgrade(socketId, buildingId, resourceLabel, resourceQuantity);
        }
        return null;
    }
    addOrRemoveResourceFromBuilding(socketId, buildingId, resourceLabel, resourceQuantity){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketId);
        if(gameInstance!== undefined){
            return gameInstance.addOrRemoveResourceFromBuilding(socketId, buildingId, resourceLabel, resourceQuantity);
        }
        return null;
    }
    pickBox(socketId, buildingId){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketId);
        if(gameInstance!== undefined){
            return gameInstance.pickBox(socketId, buildingId);
        }
        return null;
    }
    getPlayerInventory(socketId){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketId);
        if(gameInstance!== undefined){
            return gameInstance.getPlayerInventory(socketId);
        }
        return null;
    }
    addVillagerToBuilding(socketId, buildingId){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketId);
        if(gameInstance!== undefined){
            return gameInstance.addVillagerToBuilding(buildingId);
        }
        return null;
    }
    removeVillagerFromBuilding(socketId,buildingId){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketId);
        if(gameInstance!== undefined){
            return gameInstance.removeVillagerFromBuilding(buildingId);
        }
        return null;
    }
    repairBuilding(socketId,buildingId){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketId);
        if(gameInstance!== undefined){
            return gameInstance.repairBuilding(socketId, buildingId);
        }
        return null;
    }
    buildingTakeDmg(socketPlayer, message){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketPlayer.id);
        if(gameInstance !== undefined){
            gameInstance.buildingTakeDmg(socketPlayer,message);
        }
    }
    healAI(socketId,AIId){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketId);
        if(gameInstance!== undefined){
            return gameInstance.healAI(socketId, AIId);
        }
        return null;
    }
    buyItem(socketId,itemData, fromVeggie){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketId);
        if(gameInstance!== undefined){
            return gameInstance.buyItem(socketId, itemData, fromVeggie);
        }
        return null;
    }
    buyItemFromBank(socketId,itemData){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketId);
        if(gameInstance!== undefined){
            return gameInstance.buyItemFromBank(socketId, itemData);
        }
        return null;
    }
    buyVillager(socketId){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketId);
        if(gameInstance!== undefined){
            return gameInstance.buyVillager(socketId);
        }
        return null;
    }
    buyAlly(socketId){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketId);
        if(gameInstance!== undefined){
            return gameInstance.buyAlly(socketId);
        }
        return null;
    }
    getResourcesRequest(socketId){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketId);
        if(gameInstance!== undefined){
            gameInstance.broadcastResourcesToAll();
        }
    }

    async addResourcesToBoomcraft(socketId, label, quantity){
        let gameInstance = this.getGameInstanceBySocketPlayerId(socketId);
        if(gameInstance!== undefined){
            return await gameInstance.addResourcesToBoomcraft(socketId, label, quantity);
        }
        return null;
    }
    // ------------------------------------- FROM API HTTP -----------------------------------------
    externalAddAlly(villageId, quantity){
        let gameInstance = this.villagesMap.get(villageId);
        if(gameInstance!== undefined){
            gameInstance.externalAddAlly(quantity);
            return true;
        }
        return null;
    }
    externalAddEvent(villageId, extEvent){
        let gameInstance = this.villagesMap.get(villageId);
        if(gameInstance!== undefined){
            gameInstance.externalAddEvent(extEvent);
            return true;
        }
        return null;
    }
    externalAddResources(villageId, resources){
        let gameInstance = this.villagesMap.get(villageId);
        if(gameInstance!== undefined){
            gameInstance.externalAddResources(resources);
            return true;
        }
        return null;
    }
}
