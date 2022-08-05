import axios from "axios";
import {ApiConfig} from "./apiConfig.js";

export class ItemService{
    static getItems(){
        return axios.get(ApiConfig.ITEMURL);
    }

}