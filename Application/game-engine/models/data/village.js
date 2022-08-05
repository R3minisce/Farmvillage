import {Building} from "./building.js";
import {AI} from "./AI.js";
import {Resource} from "./resource.js";
import {ExternalEvent} from "./externalEvent.js";

export class Village{

    upgrade(){
        this.Level+=1;
    }

    initFromObj(o){
        this.user_account = o.user_account;
        this._id = o._id;
        this.name = o.name;
        this.level = o.level;
        this.status = o.status;
        this.principal = o.principal;
        this.creation_time = o.creation_time;
        this.playing_time = o.playing_time;
        if(this.playing_time === undefined)
            this.playing_time = 0;
        this.resources = [];
        if(o.resources !== undefined){
            for(let data of o.resources){
                let r = new Resource();
                r.initFromObj(data);
                this.resources.push(r);
            }
        }
        this.events = [];
        if(o.events !== undefined){
            for(let data of o.events){
                let e = new ExternalEvent();
                e.initEvent(data.label, data.level, data.quantity);
                this.events.push(e);
            }
        }
        this.allies = [];
        if(o.allies !== undefined){
            for(let data of o.allies){
                let a = new AI();
                a.initFromObj(data);
                this.allies.push(a);
            }
        }
        this.buildings = [];
        if(o.buildings !== undefined){
            for(let data of o.buildings){
                let b = new Building();
                b.initFromObj(data);
                this.buildings.push(b);
            }
        }
    }

    initBaseVillage(userAccountId, villageName, baseBuildingsObjects, principal){
        this.user_account = userAccountId;
        this.name = villageName;
        this.buildings = [];
        this.allies = [];
        this.level = 3;
        this.playing_time = 0;
        this.resources = [];
        this.events = [];
        this.status = "";
        this.playing_time = 0;
        this.principal = principal;
        for(let b of baseBuildingsObjects){
            let buildingModel  = new Building();
            switch(b.INFO.ID){
                case "B_01":{
                    buildingModel.initFromBaseObj(b,1);
                    buildingModel.CurrentStorage = 2;
                    break;
                }
                case "B_02":{
                    buildingModel.initFromBaseObj(b,1);
                    break;
                }
                case "B_03":{
                    buildingModel.initFromBaseObj(b,1);
                    break;
                }
                default :{
                    buildingModel.initFromBaseObj(b,0);
                    break;
                }
            }
            this.buildings.push(buildingModel);
        }
    }

    get Id(){
        return this._id;
    }
    set Id(id){
        this._id = id;
    }
    get UserAccount(){
        return this.user_account;
    }

    get Name(){
        return this.name;
    }

    set Name(name){
        this.name = name;
    }

    get Level(){
        return this.level;
    }

    set Level(level){
        this.level = level;
    }

    get Status(){
        return this.status;
    }

    set Status(status){
        this.status = status;
    }

    get Principal(){
        return this.principal;
    }

    set Principal(principal){
        this.principal = principal;
    }

    get Buildings(){
        return this.buildings;
    }
    get Allies(){
        return this.allies;
    }
    addAlly(ally){
        let index = this.allies.findIndex(a=>a.Id === ally.Id) ;
        if(index === -1){
            this.allies.push(ally);
        }else{
            this.allies[index] = ally;
        }
    }
    removeAlly(ally){
        let index = this.allies.findIndex(a=>a.Id === ally.Id) ;
        if(index!== -1){
            this.allies.splice(index, 1);
        }
    }
    get PlayingTime(){
        return this.playing_time;
    }
    addTimeToPlayingTime(sec){
        this.playing_time += sec;
    }
    get Events(){
        return this.events;
    }
    removeEvent(ev){
        let index = this.events.findIndex(e=> e === ev) ;
        if(index!== -1){
            this.events.splice(index, 1);
        }
    }
    get Resources(){
        return this.resources;
    }
    removeAddResourcesEvent(){
        this.resources = [];
    }
}
 