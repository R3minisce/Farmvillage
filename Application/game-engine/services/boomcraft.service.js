import axios from "axios";
import {ApiConfig} from "./apiConfig.js";

export class BoomcraftService{

    static getResources(idUserBoomcraft){
        return axios.get(ApiConfig.BOOMCRAFTURL +"/resource/get_resources_by_user?id_user="+idUserBoomcraft);
    }

    static putResources(idResource, quantity){
        return axios.put(ApiConfig.BOOMCRAFTURL +"/resource/update_resource_by_id?id_res="+idResource+"&new_quantity="+quantity);
    }
    static getCodeResource(){
        return axios.get(ApiConfig.BOOMCRAFTURL +"/resource/get_code_resource");
    }
}
