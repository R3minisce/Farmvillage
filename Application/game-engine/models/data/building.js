import {Villager} from "./villager.js";
import {Utils as Utils} from "../utils/utils.js";
import {Resource} from "./resource.js";

export class Building{


    /**
     * Init building from object
     * @param o
     */
    initFromObj(o){
        this.base_id = o.base_id;
        this.label = o.label;
        this.level = o.level;
        this.max_villager = o.max_villager;
        this.max_storage = o.max_storage;
        this.storage = o.storage;
        this.production = o.production;
        this.production_type = o.production_type;
        this.hp = o.hp;
        this.max_hp = o.max_hp;
        this.upgrade_resources = [];
        this.storage_resources = [];
        if(o.upgrade_resources !== undefined){
            for(let data of o.upgrade_resources){
                let r = new Resource();
                r.initFromObj(data);
                this.upgrade_resources.push(r);
            }
        }
        if(o.storage_resources !== undefined){
            for(let data of o.storage_resources){
                let re = new Resource();
                re.initFromObj(data);
                this.storage_resources.push(re);
            }
        }
        this.villagers = [];
        if(o.villagers!== undefined){
            for(let data of o.villagers){
                let v = new Villager();
                v.initFromObj(data);
                this.villagers.push(v);
            }
        }
        this.is_upgradable = this.canBeUpgraded();
        this.is_repairable = this.canBeRepaired();
        this.updateRepairCost();
        this.updateProduction();
    }
    /**
     * Create building from datasheet
     * @param o
     */

    initFromBaseObj(o, level){
        if(level === 0){
            this.base_id = o.INFO.ID;
            this.label = o.INFO.NAME;
            this.production_type = o.INFO.PROD_TYPE;
            this.level = 0;
            this.max_villager = 0;
            this.max_storage = 0;
            this.production = 0;
            this.storage = 0;
            this.hp = 0;
            this.max_hp = 0;
            this.villagers = [];
            this.upgrade_resources = this.getNextUpgradeResources(o.STATS.find(b=>b.LEVEL === level+1));
            this.storage_resources = [];
            this.is_upgradable = this.canBeUpgraded();
            this.is_repairable = this.canBeRepaired();
            this.updateProduction();
            this.updateRepairCost();
        }else{
            let baseStats = o.STATS.find(b=>b.LEVEL === level);
            this.base_id = o.INFO.ID;
            this.label = o.INFO.NAME;
            this.production_type = o.INFO.PROD_TYPE;
            this.level = baseStats.LEVEL;
            this.max_villager = baseStats.MAX_VILLAGER;
            this.max_storage = baseStats.MAX_STORAGE;
            this.production = baseStats.PROD;
            this.storage = 0;
            this.hp = baseStats.HP;
            this.max_hp = baseStats.HP;
            this.villagers = [];
            this.upgrade_resources = this.getNextUpgradeResources(o.STATS.find(b=>b.LEVEL === level+1));
            this.storage_resources = [];
            this.is_upgradable = this.canBeUpgraded();
            this.is_repairable = this.canBeRepaired();
            this.updateProduction();
            this.updateRepairCost();
        }
    }

    upgrade(buildingStatsArray){
        if(this.canBeUpgraded()){
            let nextLevel = this.level + 1;
            let nextStats = buildingStatsArray.find(s=>s.LEVEL === nextLevel);
            if(nextStats!== undefined){
                this.level = nextLevel;
                this.max_villager = nextStats.MAX_VILLAGER;
                this.max_storage = nextStats.MAX_STORAGE;
                this.production = nextStats.PROD;
                this.hp = nextStats.HP;
                this.max_hp = nextStats.HP;

                let nextLevelAfterUpgrade = this.level+1;
                let nextStatsAfterUpgrade = buildingStatsArray.find(s=>s.LEVEL === nextLevelAfterUpgrade);
                if(nextStatsAfterUpgrade!== undefined){
                    this.upgrade_resources = this.getNextUpgradeResources(nextStatsAfterUpgrade);
                }else{
                    this.upgrade_resources = [];
                }
                this.is_upgradable = this.canBeUpgraded();
                this.is_repairable = this.canBeRepaired();
                this.updateRepairCost();
                return true;
            }
        }
        return false;
    }
    canBeUpgraded(){
        if(this.upgrade_resources.length === 0){
            return false;
        }
        for(let resource of this.upgrade_resources){
            if(!resource.isFull()){
                return false;
            }
        }
        return true;
    }
    isFull(){
        return this.max_storage<= this.storage;
    }

    getNextUpgradeResources(nextStats){
        let nextUpgrade = [];
        let r1 = new Resource();
        r1.initFromObj({label:"WOOD", quantity:0, max_quantity:nextStats.WOOD_COST});
        let r2 = new Resource();
        r2.initFromObj({label:"STONE", quantity:0, max_quantity:nextStats.STONE_COST});
        let r3 = new Resource();
        r3.initFromObj({label:"IRON", quantity:0, max_quantity:nextStats.IRON_COST});
        nextUpgrade.push(r1,r2,r3);
        return nextUpgrade;
    }

    resourceCanBeAddedForUpgrade(label, quantity){
        let currentResource = this.upgrade_resources.find(r=>r.Label === label.toUpperCase());
        if(currentResource!== undefined){
            if(currentResource.isFull()){
                return false;
            }
            if(currentResource.quantity + quantity <= currentResource.max_quantity){
                return true;
            }
        }
        return false;
    }

    resourceCanBeAddedForStorage(quantity){
        let currentWeight = 0;
        for(let r of this.storage_resources){
            currentWeight += r.Quantity;
        }
        return (currentWeight + quantity <= this.MaxStorage);
    }
    resourceCanBeRemovedFromStorage(label, quantity){
        let currentResource = this.storage_resources.find(r=>r.Label === label.toUpperCase());
        if(currentResource === undefined)
            return false;

        if(currentResource.quantity < quantity)
            return false;

        return true;

    }

    addResourceForStorage(label, quantity){
        let currentResource = this.storage_resources.find(r=>r.Label === label.toUpperCase());
        let storageAvailable = this.MaxStorage - this.CurrentStorage;
        quantity = quantity - (quantity%100);
        if(quantity > storageAvailable)
            quantity = storageAvailable;

        if(currentResource !== undefined){
            currentResource.addQuantity(quantity);
            this.CurrentStorage += Math.abs(quantity);
        }else{
            currentResource = new Resource();
            currentResource.initFromObj({label:label.toUpperCase(), quantity:0, max_quantity:-1});
            currentResource.addQuantity(quantity);
            this.CurrentStorage += Math.abs(quantity);
            this.storage_resources.push(currentResource);
        }
    }
    removeResourceFromStorage(label,quantity){
        let currentResource = this.storage_resources.find(r=>r.Label === label.toUpperCase());
        if(currentResource !== undefined){
            this.CurrentStorage -= Math.abs(quantity);
            currentResource.removeQuantity(quantity);
        }
    }

    addResourceForUpgrade(label, quantity){
        let currentResource = this.upgrade_resources.find(r=>r.Label.toUpperCase() === label.toUpperCase());
        if(currentResource!== undefined){
            if(currentResource.isFull()){
                return false;
            }else{
                currentResource.addQuantity(quantity);
                this.is_upgradable = this.canBeUpgraded();
                return true;
            }
        }
    }

    get MaxVillager(){
        return this.max_villager;
    }
    get MaxStorage(){
        return this.max_storage;
    }
    get BaseProduction(){
        return this.production;
    }


    /**
     * Decrease Hp
     * @param dmg value to remove from Hp
     */
    takeDmg(dmg){
        this.Hp -= dmg;
        this.updateRepairCost();
        this.is_repairable = this.canBeRepaired();
    }

    /**
     * Return true if the building is destroyed
     * @returns {boolean}
     */
    isDestroyed(){
        return this.Hp <= 0;
    }

    /**
     * Put the building at max health
     */
    repair(){
        this.Hp = this.MaxHp;
        this.updateRepairCost();
        this.is_repairable = this.canBeRepaired();
    }

    /**
     * Add a villager to the building
     * @param villagerId
     */
    addVillager(villagerId){
        if(this.villagers.length < this.MaxVillager){
            let v  = new Villager();
            v.Id = villagerId;
            this.villagers.push(v);
            this.updateProduction();
            return true;
        }
        return false;
        /*
        if(this.villagers.length < this.MaxVillager){
            if(this.villagers.find(v=>v === villagerId) === undefined){
                this.villagers.push(villagerId);
                this.updateProduction();
            }
        }*/
    }

    /**
     * Remove a villager from the building
     * @param villagerId
     */
    removeVillager(villagerId){
        if(villagerId!== null){
            let index = this.villagers.findIndex(v=>v === villagerId);
            if(index !== -1){
                this.villagers.splice(index,1);
                this.updateProduction();
                return true;
            };
            return false;
        }else{
            if(this.villagers.length === 0 ){
                return false;
            }else{
                this.villagers.splice(0,1);
                this.updateProduction();
                return true;
            }
        }
    }

    /**
     * Increase the current storage
     * @param quantity value to add to current storage
     */
    addResources(quantity){
       this.CurrentStorage = Utils.roundNumber(this.storage+quantity,4);
    }

    /**
     * Decrease the current storage
     * @param quantity value to remove from the current storage
     */
    removeResources(quantity){
        this.CurrentStorage -= quantity;
    }

    /**
     * Update the production value based on villagers of the building
     */
    updateProduction(){
        if(this.max_hp === 0){
            this.production_rate = 0;
        }else{
            this.production_rate = this.villagers.length * this.production * (this.hp / this.max_hp) * 1000;
        }
    }

    get Id(){
        return this.base_id;
    }

    get Level(){
        return this.level;
    }

    get Hp(){
        return this.hp;
    }

    set Hp(hp){
        if(hp < 0)
            hp = 0;
        if(hp > this.max_hp)
            hp = this.max_hp;
        this.hp = hp;
        this.updateProduction();
    }

    get MaxHp(){
        return this.max_hp;
    }
    set MaxHp(maxHp){
        this.max_hp = maxHp;
    }

    get Villagers(){
        return this.villagers;
    }

    get CurrentStorage(){
        return Utils.roundNumber(this.storage,2);
    }

    set CurrentStorage(currentStorage){
        if(currentStorage < 0)
            currentStorage = 0;
        if(currentStorage > this.MaxStorage)
            currentStorage = this.MaxStorage;
        this.storage = currentStorage;
    }

    get MaxStorage(){
        return this.max_storage;
    }

    set MaxStorage(maxStorage){
        this.max_storage = maxStorage;
    }

    get ProductionRate(){
        return this.production_rate;
    }
    get ProductionType(){
        return this.production_type;
    }
    get StorageResources(){
        return this.storage_resources;
    }
    updateRepairCost(){
        if(this.MaxHp === 0) {
            this.repair_cost = [];
            return;
        }
        let diff = Math.floor(((this.MaxHp - this.Hp)/ this.MaxHp)*100);
        let resourcesCost = 0;
        switch(true) {
            case (diff <= 25): {
                resourcesCost = 100;
                break;
            }
            case (diff <= 50): {
                resourcesCost = 200;
                break;
            }
            case (diff <= 75): {
                resourcesCost = 300;
                break;
            }
            case (diff <= 100): {
                resourcesCost = 400;
                break;
            }
        }
        if(this.repair_cost === undefined || this.repair_cost === []) {
            this.repair_cost = [];
            this.repair_cost.push(new Resource("STONE", resourcesCost, -1));
            this.repair_cost.push(new Resource("WOOD", resourcesCost, -1));
            this.repair_cost.push(new Resource("IRON", resourcesCost, -1));
            this.repair_cost.push(new Resource("GOLD", resourcesCost, -1));
        }else{
            for(let r of this.repair_cost){
                r.Quantity = resourcesCost;
            }
        }


    }
    get RepairCost(){
        return this.repair_cost;
    }
    canBeRepaired(){
        return this.Hp < this.MaxHp;
    }

}
