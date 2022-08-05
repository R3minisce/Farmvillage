import axios from "axios";
import {ApiConfig} from "./apiConfig.js";

export class VillageService{


    static getVillagesByUserId(userId){
        return axios.get(ApiConfig.USERURL+userId+'/villages');
    }
    static updateVillage(village){
        return axios.put(ApiConfig.VILLAGEURL+village.Id, JSON.parse(JSON.stringify(village)));
    }
    static createVillage(userId, village){
        return axios.post(ApiConfig.VILLAGEURL, JSON.parse(JSON.stringify(village)));
    }
    static deleteVillage(villageId){
        return axios.delete(ApiConfig.VILLAGEURL+villageId);
    }
}
