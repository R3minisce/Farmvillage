export class ApiConfig{
    static SERVERURL = "http://prod_API_1:8000";
    //static SERVERURL = "http://prod_API_1:8000";
    //static SERVERURL = "http://127.0.0.1:8000";
    //static SERVERURL = "http://192.113.50.2:21000";
    //static SERVERURL = "http://192.168.1.60:8000";

    static PLAYERURL = ApiConfig.SERVERURL+"/players/";
    static USERURL =  ApiConfig.SERVERURL+"/users/"
    static VILLAGEURL= ApiConfig.SERVERURL+"/villages/";
    static BUILDINGURL = ApiConfig.SERVERURL+"/public/bases/";
    static LOGINURL = ApiConfig.SERVERURL+"/login/";
    static ITEMURL = ApiConfig.SERVERURL+"/items/";

    static GAMEENGINETOKEN = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2MTkzZDA5NGFmMzBmOGZiZDg0YmZhNTciLCJzY29wZXMiOlsidXNlciIsImFkbWluIl0sImV4cCI6MTY2ODYzNDkyNX0.0XqJ9tKyRru1-zlz40vaOFRQV-0WtospQezKvNEkJ_MnKjN3PREbRX2M_JLiaODGRVZEAt5CcUQ-O2voM5RjcpMRVjcW-wPBbMvGCPdVBhnm86B5CDki_ZXutjy1go8tdbd1v1-Hs7LbkpTUshUPM4SPk9AMezXcdzYHV9QjZ5Iz4-LhEEzi7TQ13i6wolwIYerInnQcRtJY_Lv8aw22S0KgwIBCrnKXZO12WN7SbzCsD6JNNwdq-5SA48ln65RbmmHzq7uoqKgCpyCBzhI8BBKAZIv1JaMA_wRCVL5ht3aNSWrTpeBkxV7iGqfU-EFuqOtERT5V-AUNFnhNuBJOkg";
    static GAMEENGINETOKENTYPE = "Bearer";
    static OPENWEATHERAPIKEY = "5c71eb73d77099081e4458d477ac2ba6";

    static PAYPALMERCHANTID = "s4t9nyhp2nnw8y9t";
    static PAYPALPUBLICKEY = "gcg94vswkwm934kp";
    static PAYPALPRIVATEKEY = "af1644c34844f3c6e0b9a8d6481a0cc3";

    static VEGGIECRUSHURL = "http://192.113.50.2:8505";
    static BOOMCRAFTURL = "http://192.113.50.7:8000";


    static getHeader(token, token_type){
        return {
            headers:{
                Authorization: token_type + " " + token
            }
        };
    }

    static BOOMCRAFT = "BOOMCRAFT";
    static VEGGIECRUSH = "VEGGIECRUSH";
    static FACEBOOK = "FACEBOOK";
    static POTIONDROP = 0.5;
}
