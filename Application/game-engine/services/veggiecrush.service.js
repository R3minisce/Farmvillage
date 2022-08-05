import axios from "axios";
import {ApiConfig} from "./apiConfig.js";

export class VeggiecrushService{

    static addPotion(idPotion, quantity, refreshToken){
        return axios.put(ApiConfig.VEGGIECRUSHURL + "/users/add_potion/" + idPotion + "/" + quantity, null, ApiConfig.getHeader(refreshToken, "Bearer"));
    }
    static removePotion(idPotion, quantity, refreshToken){
        return axios.put(ApiConfig.VEGGIECRUSHURL + "/users/use_potion/" + idPotion + "/" + quantity, null, ApiConfig.getHeader(refreshToken, "Bearer"));
    }
    static getInventory(refreshToken){
        return axios.get(ApiConfig.VEGGIECRUSHURL + "/users/inventory/", ApiConfig.getHeader(refreshToken, "Bearer"));
    }
    static refreshToken(refreshToken){
        let headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer' + " " + refreshToken
        }
        return axios.post(ApiConfig.VEGGIECRUSHURL + "/refresh", null, {headers: headers});
    }
}
