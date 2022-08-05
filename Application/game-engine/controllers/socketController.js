import { createServer } from "http";
import { Server } from "socket.io";
import {GameInstanceManager} from "../models/gameManagement/gameInstanceManager.js";
import {Village} from "../models/data/village.js";
import {GameEngineConfig} from "../services/gameEngineConfig.js";
import {Resource} from "../models/data/resource.js";
import {CycleManager} from "../models/gameManagement/cycleManager.js";
import {VillageService} from "../services/village.service.js";
import {UserService} from "../services/user.service.js";
import {ApiConfig} from "../services/apiConfig.js";
import {VeggiecrushService} from "../services/veggiecrush.service.js";
import {Item} from "../models/data/item.js";


//https://socket.io/docs/v3/server-initialization/


/*
client.emit will send back message to sender only,
io.emit will send message to all the client including sender
if you want to send message to all but not back to sender then client.broadcast.emit
 */

export class SocketController {


    constructor(gameDataService) {
        this.gameData = gameDataService;
        this.cycleManager = new CycleManager();
    }

    async loadData(){
        await this.gameData.loadBuildings();
        await this.gameData.loadItems();
        this.gameInstanceManager = new GameInstanceManager(this.gameData);
        this.loggedPlayers = new Map(); // token -> client socket
        this.tokenUserdataMap = new Map(); // token -> user data
    }

    start(){
        const httpServer = createServer();
        const io = new Server(httpServer);
        this.defineSocket(io);
        this.startListening(httpServer);
        this.cycleManager.startCycles(io);
    }

    /**
     * Define event listeners for the socket
     * @param io the server that has been created
     */
    defineSocket(io){
        let self = this;

        io.on('connection', function(client) {
            self.defineClientSession(client,self);
            self.definePlayerActions(client, self);
            self.defineAIActions(client,self);
            self.defineGlobalActions(client,self);
            self.defineBuildingActions(client,self);
        });
    }

    /**
     * Behaviour for player actions
     * @param client socket client
     * @param self socketController
     */
    definePlayerActions(client, self){
        client.on('action', function(message) {
            switch (message.action) {
                case "move": {
                    self.gameInstanceManager.movementEvent(client,message);
                    break;
                }
                case "attack":{
                    self.gameInstanceManager.attackEvent(client,message);
                    break;
                }
                case "damage":{
                    self.gameInstanceManager.playerTakeDmgEvent(client,message);
                    break;
                }
            }
        });
    }

    defineGlobalActions(client, self){

        client.on('village', function(message){
            switch(message.action){
                case "get resources":{
                    self.gameInstanceManager.getResourcesRequest(client.id);
                }
            }
        });
        client.on('register token', function(message){
            self.loggedPlayers.set(message.token, client);
        });
    }

    /**
     * Behaviour for ennemies actions
     * @param client socket client
     * @param self socketController
     */
    defineAIActions(client, self){
        client.on('AI', function(message) {
            switch (message.action) {
                case "spawn": {
                    self.gameInstanceManager.AISpawnEvent(client,message);
                    break;
                }
                case "move": {
                    self.gameInstanceManager.AIMovementEvent(client,message);
                    break;
                }
                case "attack":{
                    self.gameInstanceManager.AIAttackEvent(client,message);
                    break;
                }
                case "damage":{
                    self.gameInstanceManager.AITakeDmgEvent(client,message);
                    break;
                }
            }
        });
    }
    defineBuildingActions(client, self){
        client.on('building', function(message) {
            switch (message.action) {
                case "damage":{
                    self.gameInstanceManager.buildingTakeDmg(client,message);
                    break;
                }
            }
        });
    }


    /**
     * Behaviour for register, connection and disconnection
     * @param client socket client
     * @param self socketController
     */
    defineClientSession(client, self){

        // user disconnected
        client.on('disconnect',  () => {
            let token = this.findTokenBySocket(client);
            if(token !== null){
                this.disconnectPlayer(token);
            }
        });
    }

    getVillageResourcesInfo(village){
        let hq = village.Buildings.find(b=>b.Id === "B_01");
        let warehouse = village.Buildings.find(b=>b.Id === "B_06");
        let food = 0, stone = 0, wood = 0, villager = 0, iron = 0;
        if(hq !== undefined)
            villager = hq.CurrentStorage;
        if(warehouse !== undefined){
            let rStone = warehouse.StorageResources.find(r=>r.Label === "STONE");
            let rWood = warehouse.StorageResources.find(r=>r.Label === "WOOD");
            let rFood = warehouse.StorageResources.find(r=>r.Label === "FOOD");
            let rIron = warehouse.StorageResources.find(r=>r.Label === "IRON");
            if(rStone !== undefined)
                stone = rStone.Quantity;
            if(rWood !== undefined)
                wood = rWood.Quantity;
            if(rFood !== undefined)
                food = rFood.Quantity;
            if(rIron !== undefined)
                iron = rIron.Quantity;
        }

        let resources = [];
        resources.push(new Resource("villager",this._countVillagersAvailable(village), villager));
        resources.push(new Resource("food", food));
        resources.push(new Resource("stone", stone));
        resources.push(new Resource("wood", wood));
        resources.push(new Resource("iron", iron));
        resources.push(new Resource("enemy", 0));

        let inn = village.Buildings.find(b=>b.Id === "B_08");
        if(inn !== undefined){
            resources.push(new Resource("ally", inn.CurrentStorage, inn.MaxStorage));
        }else{
            resources.push(new Resource("ally", 0));
        }
        return resources;
    }
    _countVillagersAvailable(village){
        let totalVillagers = village.Buildings.find(b=>b.Id === "B_01").storage;
        let villagersInUse = 0;
        for(let building of village.Buildings){
            villagersInUse += building.Villagers.length;
        }
        return totalVillagers - villagersInUse;
    }


    /**
     * Send error message to client
     * @param client
     * @param message
     */
    sendErrorMessage(client, message){
        client.emit("error", {'message':message});
    }

    getDayInfo(){
        return this.cycleManager.DayInfo;
    }
    getWeatherInfo(){
        return this.cycleManager.WeatherInfo;
    }

    /**
     * Start the server
     * @param httpServer
     */
    startListening(httpServer){
        httpServer.listen(GameEngineConfig.SOCKETPORT);
        console.log(`Socket server listening on port: ` + GameEngineConfig.SOCKETPORT);
    }

    // ---------------------- FROM HTTP ----------------------------------------------
    upgradeBuilding(token, buildingId){
        let currentSocketId = this.getSocketIdByToken(token);
        if(currentSocketId!== undefined){
            return this.gameInstanceManager.upgradeBuilding(currentSocketId, buildingId);
        }
        return null;
    }
    getBuildingInfo(token, buildingId){
        let currentSocketId = this.getSocketIdByToken(token);
        if(currentSocketId!== undefined){
            return this.gameInstanceManager.getBuildingInfo(currentSocketId, buildingId);
        }
        return null;
    }
    depositResourceForUpgrade(token, buildingId, resourceLabel, resourceQuantity){
        let currentSocketId = this.getSocketIdByToken(token);
        if(currentSocketId!== undefined){
            return this.gameInstanceManager.depositResourceForUpgrade(currentSocketId, buildingId, resourceLabel, resourceQuantity);
        }
        return null;
    }
    addOrRemoveResourceFromBuilding(token, buildingId, resourceLabel, resourceQuantity){
        let currentSocketId = this.getSocketIdByToken(token);
        if(currentSocketId!== undefined){
            return this.gameInstanceManager.addOrRemoveResourceFromBuilding(currentSocketId, buildingId, resourceLabel, resourceQuantity);
        }
        return null;
    }
    pickBox(token,buildingId){
        let currentSocketId = this.getSocketIdByToken(token);
        if(currentSocketId!== undefined){
            return this.gameInstanceManager.pickBox(currentSocketId, buildingId);
        }
        return null;
    }
    getPlayerInventory(token){
        let currentSocketId = this.getSocketIdByToken(token);
        if(currentSocketId!== undefined){
            return this.gameInstanceManager.getPlayerInventory(currentSocketId);
        }
        return null;
    }

    disconnectPlayer(token){
        this.disconnectPlayerFromVillage(token);
        this.loggedPlayers.delete(token);
        this.tokenUserdataMap.delete(token);
        return true;
    }
    disconnectPlayerFromVillage(token){
        let socket = this.loggedPlayers.get(token);
        if(socket !== undefined){
            this.gameInstanceManager.disconnectPlayer(socket.id);
            return this.tokenUserdataMap.get(token).Villages;
        }
        return null;
    }
    addVillagerToBuilding(token, buildingId){
        let currentSocketId = this.getSocketIdByToken(token);
        if(currentSocketId!== undefined){
            return this.gameInstanceManager.addVillagerToBuilding(currentSocketId, buildingId);
        }
        return null;
    }
    removeVillagerFromBuilding(token,buildingId){
        let currentSocketId = this.getSocketIdByToken(token);
        if(currentSocketId!== undefined){
            return this.gameInstanceManager.removeVillagerFromBuilding(currentSocketId, buildingId);
        }
        return null;
    }
    repairBuilding(token,buildingId){
        let currentSocketId = this.getSocketIdByToken(token);
        if(currentSocketId!== undefined){
            return this.gameInstanceManager.repairBuilding(currentSocketId, buildingId);
        }
        return null;
    }
    healAI(token, aiId){
        let currentSocketId = this.getSocketIdByToken(token);
        if(currentSocketId!== undefined){
            return this.gameInstanceManager.healAI(currentSocketId, aiId);
        }
        return null;
    }
    getItemList(type){
        return this.gameData.items.filter(i=>i.type.toUpperCase() === type.toUpperCase());
    }
    getBankItemList(){
        return this.gameData.items.filter(i=>i.type.toUpperCase() !== "POTION");
    }
    getPriceEurForItem(itemId){
        let selectedItem = this.gameData.items.find(i=>i.Id === itemId);
        if(selectedItem !== undefined){
            return selectedItem.Price/100;
        }
        return null;
    }
    buyItem(token, itemId, fromVeggie){
        let currentSocketId = this.getSocketIdByToken(token);
        if(currentSocketId!== undefined){
            let selectedItem = this.gameData.items.find(i=>i.Id === itemId);
            if(selectedItem !== undefined){
                return this.gameInstanceManager.buyItem(currentSocketId, selectedItem, fromVeggie);
            }
        }
        return null;
    }
    buyItemFromBank(token, itemId){
        let currentSocketId = this.getSocketIdByToken(token);
        if(currentSocketId!== undefined){
            let selectedItem = this.gameData.items.find(i=>i.Id === itemId);
            if(selectedItem !== undefined){
                return this.gameInstanceManager.buyItemFromBank(currentSocketId, selectedItem);
            }
        }
        return null;
    }
    buyVillager(token){
        let currentSocketId = this.getSocketIdByToken(token);
        if(currentSocketId!== undefined){
            return this.gameInstanceManager.buyVillager(currentSocketId);
        }
        return null;
    }
    buyAlly(token){
        let currentSocketId = this.getSocketIdByToken(token);
        if(currentSocketId!== undefined){
            return this.gameInstanceManager.buyAlly(currentSocketId);
        }
        return null;
    }

    getSocketIdByToken(token){
        let socket = this.loggedPlayers.get(token);
        if(socket !== undefined){
            return socket.id;
        }
        return undefined;
    }
    // ------------------------------------- FROM API HTTP -----------------------------------------
    externalAddAlly(villageId, quantity){
        return this.gameInstanceManager.externalAddAlly(villageId,quantity);
    }
    externalAddEvent(villageId, extEvent){
        return this.gameInstanceManager.externalAddEvent(villageId,extEvent);
    }
    externalAddResources(villageId, resources){
        return this.gameInstanceManager.externalAddResources(villageId,resources);
    }
    //------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------
    async connectToVillage(token, villageId) {
        let currentUser = this.tokenUserdataMap.get(token);
        if (currentUser !== undefined) {
            if(currentUser.Player.isDead()){
                currentUser.Player.Hp = currentUser.Player.MaxHp;
            }
            let selectedVillage = currentUser.Villages.find(v => v.Id === villageId);
            if (selectedVillage !== undefined) {
                if (selectedVillage.Buildings.length === 0 || selectedVillage.Status === "destroyed") {
                    selectedVillage = await this.resetVillage(token, villageId);
                }
                this.gameInstanceManager.newGameInstance(this.loggedPlayers.get(token), currentUser, selectedVillage);
                return {
                    village: selectedVillage,
                    resources: this.getVillageResourcesInfo(selectedVillage),
                    weather: this.getWeatherInfo(),
                    day: this.getDayInfo()
                }
            }
        }
        return null;
    }
    joinGame(token, username){

        let hostId = this.findSocketIdByUsername(username);
        if(hostId !== null && hostId !== undefined){
            let currentUser = this.tokenUserdataMap.get(token);
            let currentSocketClient = this.loggedPlayers.get(token);
            if(currentUser !== undefined && currentSocketClient !== undefined){
                if(currentUser.Player.isDead()){
                    currentUser.Player.Hp = currentUser.Player.MaxHp;
                }
                let info = this.gameInstanceManager.connectToGame(hostId,currentSocketClient,currentUser);
                let village = info.village;
                if(village !== null){
                   return {
                        village: village,
                        players : info.players,
                        resources: this.getVillageResourcesInfo(village),
                        weather : this.getWeatherInfo(),
                        day: this.getDayInfo()
                    }
                }
            }
        }
        return null;
    }

    async userCreateNewVillage(token, name){
        let currentUser = this.tokenUserdataMap.get(token);
        if(currentUser!== undefined){
            let newVillage = new Village();
            newVillage.initBaseVillage(currentUser.Id, name, this.gameData.Buildings, false);

            let req = await VillageService.createVillage(currentUser.Id, newVillage).catch(()=>{});
            if(req !== undefined){
                newVillage.initFromObj(JSON.parse(JSON.stringify(req.data)));
                currentUser.addVillage(newVillage);
                return newVillage;
            }
        }
        return null;
    }

    async resetVillage(token, id){
        let currentUser = this.tokenUserdataMap.get(token);
        if(currentUser!== undefined){
           let village = currentUser.Villages.find(v=>v.Id === id);
           if(village!== undefined){
               let newVillage = new Village();
               newVillage.initBaseVillage(currentUser.Id, village.Name, this.gameData.Buildings, village.Principal);
               newVillage.Id = village.Id;
               let req = await VillageService.updateVillage(newVillage).catch(()=>{});
               if(req !== undefined){
                   newVillage.initFromObj(JSON.parse(JSON.stringify(req.data)));
                   village = newVillage;
                   return village;
               }
           }
        }
        return null;
    }
    async linkUserToExternal(token, data){
        let currentUser = this.tokenUserdataMap.get(token);
        if(currentUser!== undefined){
            let userId = currentUser.Id;
            let req = await UserService.linkUserToExternal(userId,data).catch(()=>{});
            if(req !== undefined){
                currentUser.addExternalLink(data);
                return true;
            }
        }
        return null;
    }
    async getVeggiecrushInventory(token){
        let currentUser = this.tokenUserdataMap.get(token);
        if(currentUser!== undefined){
            let veggieLink = currentUser.checkIfLinkExists(ApiConfig.VEGGIECRUSH);
            if(veggieLink !== undefined){
                let req = await VeggiecrushService.getInventory(veggieLink.refresh_token).catch((err)=>{
                });
                if(req !== undefined){
                    let data = JSON.parse(JSON.stringify(req.data));
                    return this.mapVeggiePotionsArrayToFarmVillage(data);
                }
            }
        }
        return null;
    }
    async useVeggiePotion(token, potionId){
        let currentUser = this.tokenUserdataMap.get(token);
        if(currentUser!== undefined){
            let veggieLink = currentUser.checkIfLinkExists(ApiConfig.VEGGIECRUSH);
            if(veggieLink !== undefined){
                let req = await VeggiecrushService.removePotion(potionId, 1, veggieLink.refresh_token).catch((err)=>{
                });
                if(req !== undefined){
                    let format = {
                        id : potionId,
                        count: 1
                    }
                    let itemData = this.mapVeggiePotionToFarmVillage(format);
                    if(itemData !== undefined){

                        let potion = this.gameData.items.find(i=>i.Label === itemData.Label);
                        let currentSocketId = this.getSocketIdByToken(token);
                        if(currentSocketId!== undefined){
                            return this.gameInstanceManager.buyItem(currentSocketId, potion, true);
                        }
                    }
                }
            }
        }
        return null;
    }
    mapVeggiePotionsArrayToFarmVillage(veggiePotions){
        let result = [];
        for(let p of veggiePotions){
            let potion = this.mapVeggiePotionToFarmVillage(p);
            if(potion !== undefined){
                result.push(potion);
            }
        }
        return result;
    }
    mapVeggiePotionToFarmVillage(p){
        switch(parseInt(p.id)) {
            case 1:{
                return this.convertPotionFromVeggie(1,"small_damage_potion",p.count);
            }
            case 2:{
                return this.convertPotionFromVeggie(2,"large_damage_potion",p.count);
            }
            case 3:{
                return this.convertPotionFromVeggie(3,"small_speed_potion",p.count);
            }
            case 4:{
                return this.convertPotionFromVeggie(4,"large_speed_potion",p.count);
            }
            default :{
                return undefined;
            }
        }
    }
    convertPotionFromVeggie(veggieId, name, quantity){
        let potion = this.gameData.items.find(i=>i.Label === name);
        if(potion !== undefined){
            let p = new Item();
            p.initFromObj(potion);
            p.Quantity = quantity;
            p.Price = 0;
            p.Id = veggieId;
            return p;
        }
        return undefined;
    }

    async addResourcesToBoomcraft(token, label, quantity){
        let currentSocketId = this.getSocketIdByToken(token);
        if(currentSocketId!== undefined){
            return await this.gameInstanceManager.addResourcesToBoomcraft(currentSocketId, label, quantity);
        }
        return null;
    }

    findSocketIdByUsername(username){
        let iter = this.tokenUserdataMap.entries();
        for(let i=0; i<this.tokenUserdataMap.size; i++){
            let current = iter.next().value;
            if(current[1].Username === username){
                if(this.loggedPlayers.get(current[0])!== undefined){
                    return this.loggedPlayers.get(current[0]).id;
                }
            }
        }
        return null;
    }
    findTokenBySocket(socket){
        let iter = this.loggedPlayers.entries();
        for(let i=0; i<this.loggedPlayers.size; i++){
            let current = iter.next().value;
            if(current[1] === socket){
                return current[0];
            }
        }
        return null;
    }
}

/*
 1- login http dans controleur http
 2- register token dans socket
 3- connexion village
 */
