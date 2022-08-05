import {Village} from "../data/village.js";
import {Player} from "../data/player.js";
import crypto from "crypto";
export class Utils {


    static getVillageSample(){
        let village = new Village();
        village.name = "village";
        village.level = 0;
        village.maxLevel = 5;
        village.status = "peace";
        village.principal = true;
        village.lastConnection = Date.now();
        return village;
    }

    static getPlayerSample(){
        let player = new Player();
        player.id = this.getRandomUUID();
        player.nickname = "player";
        player.position = {x:200,y:200};
        player.hp = 100;
        player.maxHp = 100;
        return player;
    }


    static getRandomUUID(){
        return  crypto.randomBytes(16).toString("hex");
    }

    static roundNumber(value, nbDecimal){
        let i = Math.pow(10,nbDecimal);
        return Math.round(value* i)/i;
    }

    static getRandomInt(min, max) {
        min = Math.ceil(min);
        max = Math.floor(max);
        return Math.floor(Math.random() * (max - min +1)) + min;
    }
    // LONGITUDE -180 to + 180
    static getRandomLong() {
        let num = (Math.random()*180).toFixed(5);
        let pos = Math.floor(Math.random());
        if (pos == 0) {
            num = num * -1;
        }
        return num;
    }
    // LATITUDE -90 to +90
    static getRandomLat() {
        let num = (Math.random()*90).toFixed(5);
        let pos = Math.floor(Math.random());
        if (pos == 0) {
            num = num * -1;
        }
        return num;
    }
    static checkHasValue(v){
        return v !== undefined  && v !== null;
    }
}
