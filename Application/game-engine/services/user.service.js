import {ApiConfig} from "./apiConfig.js";
import axios from "axios";

export class UserService {

    static getToken(username,password){
        let data = "grant_type=&username="+username+"&password="+password+"&scope=me&client_id=&client_secret=";
        let headers = {
            'Content-Type': 'application/x-www-form-urlencoded'
        }
        return axios.post(ApiConfig.LOGINURL, data, {headers: headers});
    }

    static getDataAccount(access_token, token_type){
        return axios.get(ApiConfig.LOGINURL, ApiConfig.getHeader(access_token, token_type));
    }

    static registerUser(username, email, password){
        let data = {
            username : username,
            email : email,
            password : password
        }
        return axios.post(ApiConfig.USERURL, data);
    }

    static getUsersList(page){
        return axios.get(ApiConfig.USERURL+page);
    }

    static linkUserToExternal(userId, data){
        return axios.put(ApiConfig.USERURL + userId +"/external_login", {external_login: data});
    }
    static loginUserWithExternal(id, type){
        let data = {
            id: id,
            type: type
        }
        return axios.post(ApiConfig.SERVERURL+ "/login_external", data);
    }
    static updateRefreshToken(userId,newToken){
        return axios.put(ApiConfig.USERURL + userId +"/update_external_login", {refresh_token: newToken});
    }

}
