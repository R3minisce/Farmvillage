import axios from "axios";
import {ApiConfig} from "./apiConfig.js";

export class PlayerService {

    static getPlayer(userData){
        return axios.get(ApiConfig.USERURL+userData.id+'/player', ApiConfig.getHeader(userData.access_token, userData.token_type));
    }


    static updatePlayer(player){
        /*
        let data = {
            "hp": player.Hp,
            "max_hp": player.MaxHp,
            "inventory": [{
                    "label": "lol",
                    "quantity": 50,
                    "max_quantity": 1000
            }]
        }
        console.log(data);
        */
        return axios.put(ApiConfig.PLAYERURL+player.Id, player);
    }

}
