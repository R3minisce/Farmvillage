import { PlayerService } from "../../services/player.service.js";
import { AI } from "../data/AI.js";
import { Utils as Utils } from "../utils/utils.js";
import { VillageService } from "../../services/village.service.js";
import { GameEventsList } from "../../services/gameEventsList.js";
import { Resource } from "../data/resource.js";
import { ApiConfig } from "../../services/apiConfig.js";
import { VeggiecrushService } from "../../services/veggiecrush.service.js";
import { BoomcraftService } from "../../services/boomcraft.service.js";

export class GameInstance {
    constructor(gameInstanceManager, socketHost, hostData, selectedVillage) {
        this.gameInstanceManager = gameInstanceManager;
        this.village = selectedVillage;
        this.hostId = socketHost.id;
        this.players = new Map(); // socket player ->  user data
        this.allyAi = new Map();
        this.enemyAi = new Map();
        this.loops = [];
        this.killsCpt = 0;
        this.initAllies();
        this.addPlayer(socketHost, hostData);

        /* player data
                id: string
                username: string
                player: Player
         */

        this.loopSpawnAllyAI();
        this.loopSpawnEnemyAI();
        this.loopBuildingsProduction();
        this.loopSaveGameInstance();
        this.loopVillageTimer();
        this.applyHealEventsFromDb();
        this.applyAddResourcesEventsFromDb();
        this.manageGameEvents();
    }

    /**
     * Get the number of players in the game instance
     * @returns {number} number of players
     */
    getNumberPlayers() {
        return this.players.size;
    }

    initAllies() {
        for (let ally of this.village.Allies) {
            this.allyAi.set(ally.Id, ally);
        }
    }

    /**
     * Add a new player into the game instance
     * @param socketPlayer client socket of the new player
     * @param user user data of the new player
     */
    addPlayer(socketPlayer, user) {
        this.players.set(socketPlayer, user);
        this.broadcastMessageToOthers(socketPlayer, 'player update', { action: "connection", username: user.Username, hp:user.Player.Hp});
    }

    /**
     * Remove player from the game instance
     * @param socketPlayerId  id of client socket of the player to remove
     */
    removePlayer(socketPlayerId, type) {
        let keys = Array.from(this.players.keys());
        let currentSocket = keys.find(p => p.id === socketPlayerId);
        if(currentSocket !== undefined){
            this.broadcastMessageToAll("player left", { username: this.players.get(currentSocket).Username, type: type });
            PlayerService.updatePlayer(this.players.get(currentSocket).Player).then(()=>{}).catch(err=>{});
            this.players.delete(currentSocket);
            if (socketPlayerId == this.hostId) {
                this.broadcastMessageToAll("game ended", { type: type });
                if (type === "death") {
                    this.village.Status = "destroyed";
                }
                this.closeInstance().then(r => this.deleteInstance());
            }
        }
    }

    /**
     * Close and save game instance
     */
    async closeInstance() {
        for (let l of this.loops) {
            clearInterval(l);
        }

        let err = false;
        await VillageService.updateVillage(this.village).catch(error => {
            err = true;
        });
        if (!err) {
            for (let p of this.players.values()) {
                await PlayerService.updatePlayer(p.Player);
            }
        }
    }

    /**
     * Remove this game instance from the game instance manager
     */
    deleteInstance() {
        this.gameInstanceManager.deleteGameInstance(this.hostId);
    }


    broadcastMessageToOthers(socketSender, label, message) {
        for (let socketClient of this.players.keys()) {
            if (socketClient.id !== socketSender.id) {
                try {
                    socketClient.emit(label, message);
                } catch (e) {
                }
            }
        }
    }

    broadcastMessageToAll(label, message) {
        for (let socketClient of this.players.keys()) {
            socketClient.emit(label, message);
        }
    }

    // --- PLAYER EVENTS ---

    updatePlayerMovement(socketPlayer, message) {
        let user =  this.players.get(socketPlayer);
        if(user !== undefined){            
            let data = {
                action: "move",
                username: this.players.get(socketPlayer).Username,
                direction: message.direction,
                position: message.position
            }
            this.broadcastMessageToOthers(socketPlayer, "player update", data);
        }
    }

    getPlayerInventory(socketId) {
        let keys = Array.from(this.players.keys());
        let currentPlayerSocket = keys.find(p => p.id === socketId);
        if (currentPlayerSocket === undefined)
            return null;
        let playerData = this.players.get(currentPlayerSocket).Player;
        if (playerData === undefined)
            return null;
        return playerData.Inventory;
    }

    playerAttacked(socketPlayer, message) {
        this.broadcastMessageToOthers(socketPlayer, "player update", {
            action: "attack",
            username: this.players.get(socketPlayer).Username
        });
    }

    playerTakeDmg(socketPlayer, message) {
        let currentPlayer = this.getPlayerByUsername(message.username);
        if (currentPlayer !== null) {
            currentPlayer.takeDmg(message.damage);
            this.broadcastMessageToOthers(socketPlayer, "player update", {
                action: "damage",
                damage: message.damage,
                username: message.username
            });
            if (currentPlayer.isDead()) {
                let socketPlayerDead = this.getSocketByUsername(message.username);
                if(socketPlayerDead !== null){
                    this.playerDeath(socketPlayerDead, currentPlayer);
                }
            }
        }
    }
    getSocketByUsername(username){
        let iter = this.players.entries();
        for (let i = 0; i < this.players.size; i++) {
            let current = iter.next().value;
            if (current[1].Username === username) {
                return current[0];
            }
        }
        return null;
    }

    playerDeath(socketPlayer, player) {
        this.removePlayer(socketPlayer.id, "death");
    }

    // AI EVENTS
    /**
     * Propage création ennemi depuis le host
     * @param socketPlayer
     * @param message
     */
    spawnAI(socketPlayer, message) {
        let ai = new AI();
        ai.initFromObj(message);
        switch (ai.type) {
            case "ally": {
                this.allyAi.set(ai.Id, ai);
                let inn = this.village.Buildings.find(b => b.Id === "B_08");
                if (inn !== undefined) {
                    if (!inn.isFull()) {
                        this.village.addAlly(ai);
                        inn.CurrentStorage += 1;
                    }
                }
                break;
            }
            case "enemy": {
                this.enemyAi.set(ai.Id, ai);
                break;
            }
            default:
                break;
        }
        this.broadcastMessageToOthers(socketPlayer, "AI", message)
        this.broadcastResourcesToAll();
    }

    updateAIMovement(socketPlayer, message) {
        let currentAI = this.allyAi.get(message.id);
        if (currentAI === undefined) {
            currentAI = this.enemyAi.get(message.id);
        }
        if (currentAI !== undefined) {
            currentAI.Direction = message.direction;
            currentAI.Position = message.position;
        }
        this.broadcastMessageToOthers(socketPlayer, "AI", message);
    }

    AIAttacked(socketPlayer, message) {
        this.broadcastMessageToOthers(socketPlayer, "AI", message);
    }

    AITakeDmg(socketPlayer, message) {
        let target = this.allyAi.get(message.id);
        if (target === undefined) {
            target = this.enemyAi.get(message.id);
        }
        if (target !== undefined) {
            target.takeDmg(message.damage);
            this.broadcastMessageToOthers(socketPlayer, "AI", {
                action: "damage",
                damage: message.damage,
                id: message.id,
                type: message.type
            });
            if (target.isDead()) {
                if (target.Type === "enemy") {
                    this.enemyAi.delete(target.Id);
                    this.addGoldToPlayers(8);
                    this.killsCpt ++;

                    let generatePotion = ApiConfig.POTIONDROP * 100 >= Utils.getRandomInt(1, 100);
                    if (generatePotion) {
                        let userSender = this.players.get(socketPlayer);
                        if (userSender !== undefined) {
                            let veggieLink = userSender.checkIfLinkExists(ApiConfig.VEGGIECRUSH);
                            if (veggieLink !== undefined) {
                                let randomPotion = Utils.getRandomInt(1, 4);
                                VeggiecrushService.addPotion(randomPotion, 1, veggieLink.refresh_token).then().catch(() => {
                                });
                            }
                        }
                    }

                    if(this.killsCpt === 10){
                        this.killsCpt = 0;
                        for(let user of this.players.values()){
                            let boomcraftLink = user.checkIfLinkExists(ApiConfig.BOOMCRAFT);
                            if (boomcraftLink !== undefined) {
                                BoomcraftService.getResources(boomcraftLink.id).then(resp => {
                                    let inventoryBoomcraft = JSON.parse(JSON.stringify(resp.data));
                                    if (inventoryBoomcraft.resource !== undefined) {
                                        let gold = inventoryBoomcraft.resource.find(r => r.resource === "gold");
                                        if (gold !== undefined) {
                                            let newQuantity = gold.quantity + 50;
                                            BoomcraftService.putResources(gold.id_res, newQuantity).then(() => {
                                            }).catch(() => {
                                            });
                                        }
                                        let iron = inventoryBoomcraft.resource.find(r => r.resource === "iron");
                                        if (iron !== undefined) {
                                            let newQuantity = iron.quantity + 50;
                                            BoomcraftService.putResources(iron.id_res, newQuantity).then(() => {
                                            }).catch(() => {
                                            });
                                        }
                                        let food = inventoryBoomcraft.resource.find(r => r.resource === "food");
                                        if (food !== undefined) {
                                            let newQuantity = food.quantity + 50;
                                            BoomcraftService.putResources(food.id_res, newQuantity).then(() => {
                                            }).catch(() => {
                                            });
                                        }
                                        let wood = inventoryBoomcraft.resource.find(r => r.resource === "wood");
                                        if (wood !== undefined) {
                                            let newQuantity = wood.quantity + 50;
                                            BoomcraftService.putResources(wood.id_res, newQuantity).then(() => {
                                            }).catch(() => {
                                            });
                                        }
                                        let stone = inventoryBoomcraft.resource.find(r => r.resource === "stone");
                                        if (stone !== undefined) {
                                            let newQuantity = stone.quantity + 50;
                                            BoomcraftService.putResources(stone.id_res, newQuantity).then(() => {
                                            }).catch(() => {
                                            });
                                        }
                                    }
                                }).catch((err) => {
                                });
                            }
                        }
                    }

                } else {
                    if (target.Type === "ally") {
                        this.allyAi.delete(target.Id);
                        this.village.removeAlly(target);
                        let inn = this.village.Buildings.find(b => b.Id === "B_08");
                        if (inn !== undefined) {
                            inn.CurrentStorage -= 1;
                        }
                    }
                }
                this.broadcastResourcesToAll();
            }
        }
    }

    addGoldToPlayers(quantity) {
        let iter = this.players.entries();
        for (let i = 0; i < this.players.size; i++) {
            let current = iter.next().value;
            let playerData = current[1].Player;
            if (playerData !== undefined) {
                playerData.addResource("GOLD", quantity);
                current[0].emit("update resources", {
                    action: "resources",
                    resources_village: this.getVillageResourcesInfo(),
                    resources_player: playerData.Inventory
                });
            }
        }
    }

    healAI(socketId, AIId) {
        let keys = Array.from(this.players.keys());
        let currentPlayerSocket = keys.find(p => p.id === socketId);
        if (currentPlayerSocket === undefined)
            return null;
        let playerData = this.players.get(currentPlayerSocket).Player;
        if (playerData === undefined)
            return null;
        let selectedAllyAI = this.allyAi.get(AIId)
        if (selectedAllyAI === undefined)
            return null;

        let goldCost = selectedAllyAI.MaxHp - selectedAllyAI.Hp;
        if (goldCost > playerData.countResource("GOLD"))
            return false;

        playerData.removeResource("GOLD", goldCost);
        selectedAllyAI.heal(selectedAllyAI.MaxHp);
        this.broadcastMessageToOthers(currentPlayerSocket, 'AI', { action: "hp", id: AIId, hp: selectedAllyAI.MaxHp });

        return true;
    }

    getPlayerByUsername(username) {
        let iter = this.players.entries();
        for (let i = 0; i < this.players.size; i++) {
            let current = iter.next().value;
            if (current[1].Username === username) {
                return current[1].Player;
            }
        }
        return null;
    }

    loopSpawnAllyAI() {
        // let self = this;
        // this.loops.push(setInterval(function() {
        //     let inn = self.village.Buildings.find(b=>b.Id === "B_08");
        //     if(inn !== undefined){
        //         if(!inn.isFull()){
        //             self.askSpawnAllies(1);
        //         }
        //     }
        // }, 20000));
    }

    loopSpawnEnemyAI() {
        let self = this;
        this.loops.push(setInterval(function () {
            self.askSpawnEnemies(1);
        }, 20000));
    }

    loopSaveGameInstance() {
        let self = this;
        this.loops.push(setInterval(function () {
            self.saveGameInstance().then();
        }, 120000));
        // }, 5000));
    }

    loopVillageTimer() {
        let self = this;
        this.loops.push(setInterval(function () {
            self.village.addTimeToPlayingTime(1);
        }, 1000));
    }

    async saveGameInstance() {
        VillageService.updateVillage(this.village).then(response => {
            for (let p of this.players.values()) {
                PlayerService.updatePlayer(p.Player).then().catch(error => {
                    console.log("error save player");
                });
            }
        }).catch(err => {
            console.log("error save village");
        });
    }

    manageGameEvents() {
        let self = this;
        for (let e of GameEventsList.eventsList) {
            let toExecute = this.manageEvent(e);
            if (toExecute !== undefined) {
                let nextEventTimer;
                if (this.village.PlayingTime < e.Frequency * 1000) {
                    nextEventTimer = e.Frequency * 1000 - this.village.PlayingTime;
                } else {
                    nextEventTimer = this.village.PlayingTime % (e.Frequency * 1000);
                }
                // on se synchro sur base du temps déjà écoulé de la partie
                setTimeout(function () {
                    toExecute();
                    // Maintenant qu'on est synchro, on peut boucler
                    self.loops.push(setInterval(function () {
                        toExecute();
                    }, e.Frequency * 1000));
                }, nextEventTimer);
            }
        }
    }

    // ----------- BUILDINGS -----------
    loopBuildingsProduction() {
        let self = this;
        this.loops.push(setInterval(function () {
            for (let building of self.village.Buildings) {
                if (building.ProductionRate > 0 && !building.isFull()) {
                    let oldStorage = building.CurrentStorage;
                    building.addResources(Utils.roundNumber(building.ProductionRate / 60, 4));
                    let mod = 100;
                    if (building.Id === "B_01") {
                        mod = 1;
                    }
                    if (oldStorage % mod > building.CurrentStorage % mod) {
                        self.updateBoxBuilding(building.Id, building.ProductionType, building.CurrentStorage);
                    } else {
                        if (oldStorage % mod === building.CurrentStorage % mod && oldStorage < building.CurrentStorage) {
                            self.updateBoxBuilding(building.Id, building.ProductionType, building.CurrentStorage);
                        }
                    }
                }
            }
        }, 5000));
    }

    updateBoxBuilding(id, prodType, storage) {
        this.broadcastMessageToAll("update box", { base_id: id, production_type: prodType, storage: storage });
    }

    upgradeBuilding(socketId, buildingId, buildingStats) {
        let keys = Array.from(this.players.keys());
        let currentPlayerSocket = keys.find(p => p.id === socketId);
        if (currentPlayerSocket === undefined)
            return null;

        let selectedBuilding = this.village.Buildings.find(b => b.Id === buildingId);
        if (selectedBuilding !== undefined) {
            let upgraded = selectedBuilding.upgrade(buildingStats);
            if (upgraded)
                this.village.upgrade();
            this.broadcastMessageToOthers(currentPlayerSocket, "building", {
                action: "upgraded",
                building_id: selectedBuilding.Id,
                level: selectedBuilding.Level
            });
            return selectedBuilding;
        }
        return null;
    }

    getBuildingInfo(buildingId) {
        let selectedBuilding = this.village.Buildings.find(b => b.Id === buildingId);
        if (selectedBuilding !== undefined) {
            return selectedBuilding;
        }
        return null;
    }

    buildingTakeDmg(socketPlayer, message) {
        let buildingId = message.building_id;
        let damage = message.damage;
        if (buildingId !== undefined && damage !== undefined) {
            let selectedBuilding = this.village.Buildings.find(b => b.Id === buildingId);
            if (selectedBuilding !== undefined) {
                selectedBuilding.takeDmg(damage);
                this.broadcastMessageToOthers(socketPlayer, "building", {
                    action: "damage",
                    building_id: selectedBuilding.Id,
                    damage: damage
                });
                if (selectedBuilding.isDestroyed())
                    this.broadcastMessageToOthers(socketPlayer, "building", {
                        action: "destroyed",
                        building_id: selectedBuilding.Id
                    });
            }
        }
    }

    repairBuilding(socketId, buildingId) {
        let keys = Array.from(this.players.keys());
        let currentPlayerSocket = keys.find(p => p.id === socketId);
        if (currentPlayerSocket === undefined)
            return null;
        let playerData = this.players.get(currentPlayerSocket).Player;
        if (playerData === undefined)
            return null;
        let selectedBuilding = this.village.Buildings.find(b => b.Id === buildingId);
        let warehouse = this.village.Buildings.find(b => b.Id === "B_06");
        if (selectedBuilding !== undefined && warehouse !== undefined) {
            if (!selectedBuilding.canBeRepaired()) {
                return false;
            }

            for (let r of selectedBuilding.RepairCost) {
                if (r.Label.toUpperCase() === "GOLD") {
                    if (r.Quantity > playerData.countResource("GOLD")) {
                        return false;
                    }
                } else {
                    if (!warehouse.resourceCanBeRemovedFromStorage(r.Label, r.Quantity)) {
                        return false;
                    }
                }
            }
            for (let r of selectedBuilding.RepairCost) {
                if (r.Label.toUpperCase() === "GOLD") {
                    playerData.removeResource("GOLD", r.Quantity);
                } else {
                    warehouse.removeResourceFromStorage(r.Label, r.Quantity);
                }
            }
            selectedBuilding.repair();
            this.broadcastMessageToOthers(currentPlayerSocket, "building", {
                action: "repaired",
                building_id: selectedBuilding.Id
            });
            this.broadcastResourcesToAll();
            return true;
        }
        return null;
    }

    depositResourceForUpgrade(socketId, buildingId, resourceLabel, resourceQuantity) {
        let keys = Array.from(this.players.keys());
        let currentPlayerSocket = keys.find(p => p.id === socketId);
        if (currentPlayerSocket === undefined)
            return null;
        let playerData = this.players.get(currentPlayerSocket).Player;
        if (playerData === undefined)
            return null;
        let selectedBuilding = this.village.Buildings.find(b => b.Id === buildingId.toUpperCase());
        if (selectedBuilding !== undefined) {
            if (selectedBuilding.resourceCanBeAddedForUpgrade(resourceLabel, resourceQuantity)) {
                let resourceInInventory = playerData.Inventory.find(i => i.label.toUpperCase() === resourceLabel.toUpperCase());
                if (resourceInInventory === undefined)
                    return false;
                if (resourceQuantity > resourceInInventory.Quantity)
                    return false;
                resourceInInventory.removeQuantity(resourceQuantity);
                if (selectedBuilding.addResourceForUpgrade(resourceLabel, resourceQuantity)) {
                    return true;
                } else {
                    resourceInInventory.addQuantity(resourceQuantity);
                    return false;
                }
            }
        }
        return null;
    }

    addOrRemoveResourceFromBuilding(socketId, buildingId, resourceLabel, resourceQuantity) {
        let keys = Array.from(this.players.keys());
        let currentPlayerSocket = keys.find(p => p.id === socketId);
        if (currentPlayerSocket === undefined)
            return null;
        let playerData = this.players.get(currentPlayerSocket).Player;
        if (playerData === undefined)
            return null;
        let selectedBuilding = this.village.Buildings.find(b => b.Id === buildingId.toUpperCase());
        if (selectedBuilding !== undefined) {

            if (resourceQuantity > 0) {
                if (!selectedBuilding.resourceCanBeAddedForStorage(resourceQuantity))
                    return false;

                let resourceInInventory = playerData.Inventory.find(i => i.label.toUpperCase() === resourceLabel.toUpperCase());
                if (resourceInInventory === undefined)
                    return false;
                if (resourceQuantity > resourceInInventory.Quantity)
                    return false;

                resourceInInventory.removeQuantity(resourceQuantity);
                selectedBuilding.addResourceForStorage(resourceLabel, resourceQuantity);
                return true;

            } else {
                if (!selectedBuilding.resourceCanBeRemovedFromStorage(resourceLabel, resourceQuantity))
                    return false;
                if (playerData.isInventoryFull())
                    return false;
                playerData.addResource(resourceLabel, resourceQuantity);
                selectedBuilding.removeResourceFromStorage(resourceLabel, resourceQuantity);
                return true;
            }
        }
        return null;
    }

    pickBox(socketId, buildingId) {
        let keys = Array.from(this.players.keys());
        let currentPlayerSocket = keys.find(p => p.id === socketId);
        if (currentPlayerSocket === undefined)
            return null;
        let playerData = this.players.get(currentPlayerSocket).Player;
        if (playerData === undefined)
            return null;

        let selectedBuilding = this.village.Buildings.find(b => b.Id === buildingId);
        if (selectedBuilding === undefined)
            return null;

        if (playerData.isInventoryFull() || selectedBuilding.CurrentStorage < 100) {
            return false;
        }

        selectedBuilding.removeResources(100);
        playerData.addResource(selectedBuilding.ProductionType, 100);
        this.broadcastMessageToOthers(currentPlayerSocket, "update box", {
            base_id: selectedBuilding.Id,
            production_type: selectedBuilding.ProductionType,
            storage: selectedBuilding.CurrentStorage
        });
        return true;
    }

    addVillagerToBuilding(buildingId) {
        if (this._countVillagersAvailable() <= 0) {
            return false;
        }
        let selectedBuilding = this.village.Buildings.find(b => b.Id === buildingId);
        if (selectedBuilding !== undefined) {
            let resp = selectedBuilding.addVillager(Utils.getRandomUUID());
            this.broadcastResourcesToAll();
            return resp;
        }
        return null;
    }

    removeVillagerFromBuilding(buildingId) {
        let selectedBuilding = this.village.Buildings.find(b => b.Id === buildingId);
        if (selectedBuilding !== undefined) {
            return selectedBuilding.removeVillager(null);
        }
        return null;
    }

    _countVillagersAvailable() {
        let totalVillagers = this.village.Buildings.find(b => b.Id === "B_01").storage;
        let villagersInUse = 0;
        for (let building of this.village.Buildings) {
            villagersInUse += building.Villagers.length;
        }
        return totalVillagers - villagersInUse;
    }

    buyItem(socketId, itemData, fromVeggie) {
        let keys = Array.from(this.players.keys());
        let currentPlayerSocket = keys.find(p => p.id === socketId);
        if (currentPlayerSocket === undefined)
            return null;
        let playerData = this.players.get(currentPlayerSocket).Player;
        if (playerData === undefined)
            return null;

        if (!fromVeggie) {
            if (playerData.countResource("GOLD") < itemData.Price)
                return false;
            playerData.removeResource("GOLD", itemData.Price);
        }

        switch (itemData.Target) {
            case "health": {
                let hp = Math.floor(playerData.MaxHp * (itemData.Ratio / 100));
                playerData.heal(hp);
                this.broadcastMessageToAll("player update", { action: "hp", hp: playerData.Hp, username: this.players.get(currentPlayerSocket).Username});
                return { label: itemData.Label, target: itemData.Target, ratio: itemData.Ratio };
            }
            default: {
                setTimeout(this.stopEffect, itemData.Duration * 1000, currentPlayerSocket, itemData.Target);
                return { label: itemData.Label, target: itemData.Target, ratio: itemData.Ratio, type: itemData.Type };
            }
        }
    }

    buyItemFromBank(socketId, itemData) {
        let keys = Array.from(this.players.keys());
        let currentPlayerSocket = keys.find(p => p.id === socketId);
        if (currentPlayerSocket === undefined)
            return null;
        let playerData = this.players.get(currentPlayerSocket).Player;
        if (playerData === undefined)
            return null;
        switch (itemData.Type) {
            case "ally": {
                this.askSpawnAllies(1);
                break;
            }
            default: {
                break;
            }
        }
        return true;
    }

    buyVillager(socketId) {
        let keys = Array.from(this.players.keys());
        let currentPlayerSocket = keys.find(p => p.id === socketId);
        if (currentPlayerSocket === undefined)
            return null;
        let playerData = this.players.get(currentPlayerSocket).Player;
        if (playerData === undefined)
            return null;

        if (playerData.countResource("FOOD") < 200)
            return false;
        let hq = this.village.Buildings.find(b => b.Id === "B_01");

        if (hq === undefined)
            return null;
        if (hq.isFull())
            return false;

        playerData.removeResource("FOOD", 200);
        hq.CurrentStorage += 1;
        this.broadcastResourcesToAll();

        return true;

    }

    buyAlly(socketId) {
        let keys = Array.from(this.players.keys());
        let currentPlayerSocket = keys.find(p => p.id === socketId);
        if (currentPlayerSocket === undefined)
            return null;
        let playerData = this.players.get(currentPlayerSocket).Player;
        if (playerData === undefined)
            return null;
        if (playerData.countResource("GOLD") < 100)
            return false;
        let inn = this.village.Buildings.find(b => b.Id === "B_08");

        if (inn === undefined)
            return null;
        if (inn.isFull())
            return false;

        playerData.removeResource("GOLD", 100);
        this.askSpawnAllies(1);
        this.broadcastResourcesToAll();
        return true;

    }

    getVillageResourcesInfo() {

        let hq = this.village.Buildings.find(b => b.Id === "B_01");
        let warehouse = this.village.Buildings.find(b => b.Id === "B_06");
        let food = 0, stone = 0, wood = 0, villager = 0, iron = 0;
        if (hq !== undefined)
            villager = hq.CurrentStorage;
        if (warehouse !== undefined) {
            let rStone = warehouse.StorageResources.find(r => r.Label === "STONE");
            let rWood = warehouse.StorageResources.find(r => r.Label === "WOOD");
            let rFood = warehouse.StorageResources.find(r => r.Label === "FOOD");
            let rIron = warehouse.StorageResources.find(r => r.Label === "IRON");
            if (rStone !== undefined)
                stone = rStone.Quantity;
            if (rWood !== undefined)
                wood = rWood.Quantity;
            if (rFood !== undefined)
                food = rFood.Quantity;
            if (rIron !== undefined)
                iron = rIron.Quantity;
        }
        //this.broadcastMessageToOthers(currentPlayerSocket,"village",{action:"resource"});

        let resources = [];
        resources.push(new Resource("villager", this._countVillagersAvailable(), villager));
        resources.push(new Resource("food", food));
        resources.push(new Resource("stone", stone));
        resources.push(new Resource("wood", wood));
        resources.push(new Resource("iron", iron));
        resources.push(new Resource("enemy", this.enemyAi.size));

        let inn = this.village.Buildings.find(b => b.Id === "B_08");
        if (inn !== undefined) {
            resources.push(new Resource("ally", inn.CurrentStorage, inn.MaxStorage));
        } else {
            resources.push(new Resource("ally", 0));
        }
        return resources;
    }

    stopEffect(playerSocket, label) {
        playerSocket.emit("effect", { action: "stop", target: label });
    }

    async addResourcesToBoomcraft(socketId, label, quantity) {
        let keys = Array.from(this.players.keys());
        let currentPlayerSocket = keys.find(p => p.id === socketId);
        if (currentPlayerSocket === undefined)
            return null;
        let boomcraftLink = this.players.get(currentPlayerSocket).checkIfLinkExists(ApiConfig.BOOMCRAFT);
        if (boomcraftLink === undefined) {
            return false;
        }
        let playerData = this.players.get(currentPlayerSocket).Player;
        if (playerData === undefined)
            return null;

        let warehouse = this.village.Buildings.find(b => b.Id === "B_06");
        if (warehouse !== undefined) {
            if (!warehouse.resourceCanBeRemovedFromStorage(label, quantity)) {
                return false;
            } else {
                let resp = await BoomcraftService.getResources(boomcraftLink.id).catch(err => {
                });
                if (resp !== undefined) {
                    let inventoryBoomcraft = JSON.parse(JSON.stringify(resp.data));
                    if (inventoryBoomcraft.resource !== undefined) {
                        let selected = inventoryBoomcraft.resource.find(r => r.resource === label.toLowerCase());
                        if (selected !== undefined) {
                            let newQuantity = selected.quantity + quantity;
                            let reqPut = await BoomcraftService.putResources(selected.id_res, newQuantity).catch((err) => {
                                console.log("err");
                                console.log(err);
                            });
                            if (reqPut !== undefined) {
                                warehouse.removeResourceFromStorage(label, quantity);
                                this.broadcastResourcesToAll();
                                return true;
                            }
                        }
                    }
                }
            }
        } 
        return null;
    }

    // ------------------------------------- FROM API HTTP -----------------------------------------
    externalAddAlly(quantity) {
        let inn = this.village.Buildings.find(b => b.Id === "B_08");
        if (inn !== undefined) {
            let max = inn.MaxStorage - inn.CurrentStorage;
            if (quantity > max)
                quantity = max;
            this.askSpawnAllies(quantity);
        }
    }

    externalAddEvent(extEvent) {
        let toExecute = this.manageEvent(extEvent);
        if (toExecute !== undefined) {
            toExecute();
        }
    }

    manageEvent(extEvent) {
        let self = this;
        let toExecute;
        let countdown = 60000;
        let ev = this.findEventInVillage(extEvent.Label);
        if (ev !== undefined) {
            // copie manuelle sinon la ref sera supprimée
            extEvent.label = ev.Label;
            extEvent.level = ev.Level;
            extEvent.quantity = ev.Quantity;
            this.village.removeEvent(ev);
        }
        switch (extEvent.Label.toLowerCase()) {
            case "invasion": {
                if (extEvent.Level !== undefined) {
                    let size = extEvent.Level * 5;
                    if (size > 0) {
                        toExecute = function () {
                            self.broadcastMessageToAll("event", {
                                action: "notification",
                                type: "invasion",
                                level: extEvent.Level,
                                countdown: countdown
                            });
                            setTimeout(function () {
                                try {
                                    self.broadcastMessageToAll("event", {
                                        action: "start",
                                        type: "invasion",
                                        level: extEvent.Level
                                    });
                                    self.askSpawnEnemies(size);
                                } catch (e) {
                                    console.log(e);
                                }
                            }, countdown);
                        }
                    }
                } else {
                    if (extEvent.Quantity !== undefined) {
                        let lvl = Math.floor(extEvent.Quantity / 5);
                        toExecute = function () {
                            self.broadcastMessageToAll("event", {
                                action: "notification",
                                type: "invasion",
                                level: lvl,
                                countdown: countdown
                            });
                            setTimeout(function () {
                                try {
                                    self.broadcastMessageToAll("event", {
                                        action: "start",
                                        type: "invasion",
                                        level: lvl
                                    });
                                    self.askSpawnEnemies(extEvent.Quantity);
                                } catch (e) {
                                    console.log(e);
                                }
                            }, countdown);
                        }
                    }
                }
                break;
            }
            case "calamity": {
                let hpLost = 0;
                switch (extEvent.Level) {
                    case 1: {
                        hpLost = 0.05;
                        break;
                    }
                    case 2: {
                        hpLost = 0.10;
                        break;
                    }
                    case 3: {
                        hpLost = 0.15;
                        break;
                    }
                    default: {
                        break;
                    }
                }
                if (hpLost > 0) {
                    toExecute = function () {
                        self.broadcastMessageToAll("event", {
                            action: "notification",
                            type: "calamity",
                            level: extEvent.Level,
                            countdown: countdown
                        });
                        setTimeout(function () {
                            try {
                                self.broadcastMessageToAll("event", {
                                    action: "start",
                                    type: "calamity",
                                    level: extEvent.Level
                                });
                                for (let b of self.village.Buildings) {
                                    b.takeDmg(b.MaxHp * hpLost);
                                    self.broadcastMessageToAll("building", {
                                        action: "damage",
                                        building_id: b.Id,
                                        damage: b.MaxHp * hpLost
                                    });
                                }
                            } catch (e) {
                                console.log(e);
                            }
                        }, countdown);
                    }
                }
                break;
            }
            case "heal": {
                self.externalAddHeal(extEvent.Level);
                break;
            }
            default: {
                break;
            }
        }
        return toExecute;
    }

    applyHealEventsFromDb() {
        let healEvents = this.village.Events.filter(e => e.Label === "heal");
        for (let healEv of healEvents) {
            this.externalAddEvent(healEv);
            this.village.removeEvent(healEv);
        }
    }
    applyAddResourcesEventsFromDb() {
        this.externalAddResources(this.village.Resources);
        this.village.removeAddResourcesEvent();
    }

    findEventInVillage(label) {
        return this.village.Events.find(e => e.Label === label.toLowerCase());
    }

    externalAddResources(resources) {
        let warehouse = this.village.Buildings.find(b => b.Id === "B_06");
        let update = false;
        if (warehouse !== undefined) {
            for (let r of resources) {
                if (!warehouse.isFull() && this.isValidResourceForStorage(r.Label)) {
                    warehouse.addResourceForStorage(r.Label, r.Quantity);
                    update = true;
                } else {
                    if (update)
                        this.broadcastResourcesToAll();
                    return;
                }
            }
            if (update)
                this.broadcastResourcesToAll();
        }
    }

    isValidResourceForStorage(label) {
        let lUp = label.toUpperCase();
        return lUp === "WOOD" || lUp === "IRON" || lUp === "STONE" || lUp === "FOOD";
    }

    externalAddHeal(level) {
        let healValuePercent;
        switch (level) {
            case 1: {
                healValuePercent = 0.25;
                break;
            }
            case 2: {
                healValuePercent = 0.5;
                break;
            }
            case 3: {
                healValuePercent = 0.75;
                break;
            }
            case 4: {
                healValuePercent = 1;
                break;
            }
            default: {
                return;
            }
        }
        this.broadcastMessageToAll("event", { action: "notification ", type: "heal", level: level });
        for (let p of this.players.values()) {
            let playerData = p.Player;
            playerData.heal(Math.floor(playerData.MaxHp * healValuePercent));
            this.broadcastMessageToAll("player update", { action: "hp", hp: playerData.Hp, username: p.username });
        }
        let iter = this.allyAi.entries();
        for (let i = 0; i < this.allyAi.size; i++) {
            let current = iter.next().value;
            current[1].heal(Math.floor(current[1].MaxHp * healValuePercent));
            this.broadcastMessageToAll('AI', { action: "hp", id: current[0], hp: current[1].Hp });
        }
    }

    broadcastResourcesToAll() {
        let villageResources = this.getVillageResourcesInfo();

        for (let socketClient of this.players.keys()) {
            let playerData = this.players.get(socketClient).Player;
            if (playerData !== undefined) {
                socketClient.emit("update resources", {
                    action: "resources",
                    resources_village: villageResources,
                    resources_player: playerData.Inventory
                });
            }
        }
    }

    /**
     * Ask host to create ennemies
     * @param number number of ennemies
     */
    askSpawnEnemies(number) {
        let hostSocket = this.getHostSocket();
        if (hostSocket !== null) {
            hostSocket.emit("AI", { action: "create", type: "enemy", number: number })
        }
    }

    /**
     * Ask host to create allies
     * @param number number of allies
     */
    askSpawnAllies(number) {
        let hostSocket = this.getHostSocket();
        if (hostSocket !== null) {
            hostSocket.emit("AI", { action: "create", type: "ally", number: number });
        }
    }

    getHostSocket() {
        let iter = this.players.entries();
        for (let i = 0; i < this.players.size; i++) {
            let current = iter.next().value;
            if (current[0].id === this.hostId) {
                return current[0];
            }
        }
        return null;
    }
    getPlayerList(currentUsername){
        let data = [];
        let iter = this.players.entries();
        for (let i = 0; i < this.players.size; i++) {
            let current = iter.next().value;
            let username = current[1].Username;
            let playerData = current[1].Player;
            if(username !== currentUsername){
                data.push({username:username,hp:playerData.Hp});
            }
        }
        return data;
    }
}
