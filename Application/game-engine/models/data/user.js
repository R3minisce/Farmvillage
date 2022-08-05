import {Village} from "./village.js";
import {Player} from "./player.js";
import {Utils} from "../utils/utils.js";

export class User{


    initFromObjDb(o){
        this.username = o.username;
        this._id = o._id;
        this.email = o.email;
        this.currency = o.currency;
        this.scopes = o.scopes;
        this.creation_time = o.creation_time;
        this.external_logins = [];
        if(o.external_logins !== undefined && o.external_logins !== null){
            for(let l of o.external_logins){
                this.external_logins.push(l);
            }
        }
    }

    initFromFullObj(o){
        this.initFromObjDb(o);
        this.initVillagesFromObj(o.villages);
        let p = new Player();
        p.initFromObj(o.player);
        this.player = p;
    }
    initVillagesFromObj(o){
        this.villages = [];

        for(let i=0; i< o.length; i++){
            let v = new Village();
            v.initFromObj(o[i]);
            this.villages.push(v);
        }
    }

    get AccessToken(){
        return this.access_token;
    }
    set AccessToken(token){
        this.access_token= token;
    }
    get TokenType(){
        return this.token_type
    }
    set TokenType(tokenType){
        this.token_type = tokenType;
    }

    get Token(){
        return this.TokenType + " " + this.AccessToken;
    }

    get Username(){
        return this.username;
    }

    get Id(){
        return this._id;
    }

    get Email(){
        return this.email;
    }
    get Currency(){
        return this.currency;
    }
    addCurrency(value){
        this.currency += value;
    }
    removeCurrency(value){
        let newVal = this.currency - value;
        if(newVal < 0){
            newVal = 0;
        }
        this.currency = newVal;
    }

    get Villages(){
        return this.villages;
    }
    addVillage(village){
        this.villages.push(village);
    }
    deleteVillage(id){
        let index = this.villages.findIndex(v=>v.Id === id);
        if(index !== -1){
            this.villages.splice(index,1);
        }
    }

    addExternalLink(o){
        this.external_logins.push(o);
    }
    get ExternalLinks(){
        return this.external_logins;
    }
    set ExternalLinks(newArray){
        if(!Utils.checkHasValue(newArray)){
            this.external_logins = []
        }else{
            this.external_logins = newArray;
        }
    }
    get CreationTime(){
        return this.creation_time;
    }

    get Player(){
        return this.player;
    }
    set Player(player){
        this.player = player;
    }
    checkIfLinkExists(type){
        return this.external_logins.find(l=>l.type.toUpperCase() === type.toUpperCase());
    }
}
