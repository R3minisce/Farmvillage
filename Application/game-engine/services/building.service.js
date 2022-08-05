import {ApiConfig} from "./apiConfig.js";
import axios from "axios";

export class BuildingService{

    static getBuildings(){
        return axios.get(ApiConfig.BUILDINGURL);
    }
}