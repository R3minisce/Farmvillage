import {BuildingService} from "./building.service.js";
import {Resource} from "../models/data/resource.js";
import {ItemService} from "./item.service.js";
import {Item} from "../models/data/item.js";
import {GameEvent} from "../models/data/gameEvent.js";

export class GameDataService{

    constructor() {
        this.buildings =[];
        this.items = [];
    }


    async loadBuildings(){
        return BuildingService.getBuildings().then(resp=>{
            this.buildings = JSON.parse(JSON.stringify(resp.data));
            console.log("Load buildings ok");
        }).catch(error=>{
            console.log("Error loading buildings");
        });
    }

    async loadItems(){
        return ItemService.getItems().then(resp=>{
            for(let data of JSON.parse(JSON.stringify(resp.data))){
                let i = new Item();
                i.initFromObj(data);
                this.items.push(i);
            }
            console.log("Load items ok");
        }).catch(error=>{
            console.log("Error loading items");
        });
    }
    get Buildings(){
        return this.buildings;
    }
    set Buildings(buildings){
        this.buildings = buildings;
    }


    getAllBuidings(){
        return this.buildings;
    }

    getBuildingById(baseId){
        return this.buildings.find(b=>b.INFO.ID === baseId);
    }
    getNextUpgradeResources(baseId, currentLevel){
        let selected = this.buildings.find(b=>b.INFO.ID === baseId);
        if(selected!== undefined){
            let next =  selected.find(s=>s.LEVEL === currentLevel+1);
            if(next!== undefined){
                let nextUpgrade = [];
                let r1 = new Resource();
                r1.initFromObj({label:"WOOD_COST", quantity:0, max_quantity:next.WOOD_COST});
                let r2 = new Resource();
                r2.initFromObj({label:"STONE_COST", quantity:0, max_quantity:next.STONE_COST});
                let r3 = new Resource();
                r3.initFromObj({label:"IRON_COST", quantity:0, max_quantity:next.IRON_COST});
                nextUpgrade.push(r1,r2,r3);
                return nextUpgrade;
            }
        }
        return null;
    }
    getBuildingStatsById(baseId){
        let selected = this.buildings.find(b=>b.INFO.ID === baseId);
        return selected === undefined ? undefined : selected.STATS;
    }
}