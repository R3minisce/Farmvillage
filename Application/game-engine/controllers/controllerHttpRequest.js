import express from "express";
import bodyParser from "body-parser";
import braintree from "braintree";
import { UserService } from "../services/user.service.js";
import { User } from "../models/data/user.js";
import { VillageService } from "../services/village.service.js";
import { PlayerService } from "../services/player.service.js";
import { Player } from "../models/data/player.js";
import { Village } from "../models/data/village.js";
import axios from "axios";
import { ExternalEvent } from "../models/data/externalEvent.js";
import { Resource } from "../models/data/resource.js";
import { Utils } from "../models/utils/utils.js";
import { ApiConfig } from "../services/apiConfig.js";
import { VeggiecrushService } from "../services/veggiecrush.service.js";


export class ControllerHttpRequest {

    constructor(gameDataService, socketController) {
        this.gameData = gameDataService;
        this.socketController = socketController;
    }

    /**
     * Server initialization
     * @param hostname server hostname
     * @param port server port
     */
    startServer(hostname, port) {
        const server = express();
        server.use(bodyParser.json());
        this.defineCors(server);
        this.defineEndPoints(server);
        server.listen(port, hostname, () => {
            console.log(`Http server running at http://${hostname}:${port}/`);
        });
    }

    /**
     * Defines Cors
     * @param server instance of server
     */
    defineCors(server) {
        // https://stackoverflow.com/questions/10695629/what-is-the-parameter-next-used-for-in-express
        server.use((req, res, next) => {
            res.setHeader('Access-Control-Allow-Origin', '*');
            res.setHeader('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content, Accept, Content-Type, Authorization');
            res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
            next();
        });
    }

    /**
     * Define end points
     * @param server instance of server
     */
    defineEndPoints(server) {
        this.defineUserEndPoints(server);
        this.defineBuildingsEndPoints(server);
        this.definePlayerEndpoints(server);
        this.defineAIEndpoints(server);
        this.defineItemsEndpoints(server);
        this.defineExternalEndpoints(server);
        this.defineFromApiEndpoints(server);

    }

    defineUserEndPoints(server) {
        server.post('/register', (req, res) => {
            UserService.registerUser(req.body.username, req.body.email, req.body.password).then(async () => {
                let token = await this.loadToken(req.body.username, req.body.password).catch(()=>{});
                if (token !== undefined) {
                    this.loadProfile(token, res);
                } else {
                    res.sendStatus(404);
                }
            }).catch((error) => {
                res.sendStatus(404);
            });
        });
        server.post('/login', async (req, res) => {
            let token = await this.loadToken(req.body.username, req.body.password).catch(()=>{});
            if (token !== undefined) {
                this.loadProfile(token, res);
            } else {
                res.sendStatus(404);
            }
        });
        server.post('/login/external', async (req, res) => {
            let type = req.body.type;
            let id = req.body.id;
            let token = await this.loadTokenFromExternalLogin(id, type).catch(()=>{});
            if (token !== undefined) {
                this.loadProfile(token, res);
            } else {
                res.sendStatus(404);
            }


            /* if(Utils.checkHasValue(type)){
                 switch (type.toUpperCase()){
                     case Utils.BOOMCRAFT:{
                         break;
                     }
                     case Utils.VEGGIECRUSH:{
                         break;
                     }
                     case Utils.FACEBOOK:{
                         break;
                     }
                     default:{
                         break;
                     }
                 }
             }*/
        });

        server.post('/logout', (req, res) => {
            let result = this.socketController.disconnectPlayer(req.body.token);
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.post('/logout/village', (req, res) => {
            let result = this.socketController.disconnectPlayerFromVillage(req.body.token);
            if (result !== null) {
                result = this.formatVillagesList(result);
            }
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.post('/join/village', async (req, res) => {
            let result = await this.socketController.connectToVillage(req.body.token, req.body.village_id).catch(()=>{});
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.post('/join/friend', (req, res) => {
            let result = this.socketController.joinGame(req.body.token, req.body.username);
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.post('/create/village', async (req, res) => {
            let result = await this.socketController.userCreateNewVillage(req.body.token, req.body.village_name).catch(()=>{});
            if (result !== null) {
                result = this.formatVillage(result);
            }
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.post('/reset/village', async (req, res) => {
            let result = await this.socketController.resetVillage(req.body.token, req.body.village_id).catch(()=>{});
            if (result !== null) {
                result = this.formatVillage(result);
            }
            this.sendNotFoundOrOkWithResult(res, result);
        });
    }


    defineBuildingsEndPoints(server) {
        server.post('/building', (req, res) => {
            let result = this.socketController.getBuildingInfo(req.body.token, req.body.building_id);
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.put('/building/upgrade', (req, res) => {
            let result = this.socketController.upgradeBuilding(req.body.token, req.body.building_id);
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.put('/building/upgrade/resource', (req, res) => {
            let result = this.socketController.depositResourceForUpgrade(req.body.token, req.body.building_id, req.body.label, req.body.quantity);
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.put('/building/resource', (req, res) => {
            let result = this.socketController.addOrRemoveResourceFromBuilding(req.body.token, req.body.building_id, req.body.label, req.body.quantity);
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.post('/building/villager', (req, res) => {
            let result = this.socketController.addVillagerToBuilding(req.body.token, req.body.building_id);
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.delete('/building/villager', (req, res) => {
            let result = this.socketController.removeVillagerFromBuilding(req.body.token, req.body.building_id);
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.post('/building/repair', (req, res) => {
            let result = this.socketController.repairBuilding(req.body.token, req.body.building_id);
            this.sendNotFoundOrOkWithResult(res, result);
        });
    }

    defineItemsEndpoints(server) {
        server.get('/item/:type', (req, res) => {
            let result = this.socketController.getItemList(req.params.type);
            res.status(200).send(result);
        });
        server.post('/buy/item', (req, res) => {
            let result = this.socketController.buyItem(req.body.token, req.body.item_id, false);
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.post('/buy/villager', (req, res) => {
            let result = this.socketController.buyVillager(req.body.token);
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.get('/bank/item', (req, res) => {
            let result = this.socketController.getBankItemList();
            res.status(200).send(result);
        });
        
        server.post('/buy/ally', (req, res) => {
            let result = this.socketController.buyAlly(req.body.token);
            this.sendNotFoundOrOkWithResult(res, result);
        });
    }
    definePlayerEndpoints(server) {
        server.post('/pickbox', (req, res) => {
            let result = this.socketController.pickBox(req.body.token, req.body.building_id);
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.get('/player/:token/inventory', (req, res) => {
            let result = this.socketController.getPlayerInventory(req.params.token);
            this.sendNotFoundOrOkWithResult(res, result);
        });
    }
    defineAIEndpoints(server) {
        server.post('/healally', (req, res) => {
            let result = this.socketController.healAI(req.body.token, req.body.ai_id);
            this.sendNotFoundOrOkWithResult(res, result);
        });
    }
    defineExternalEndpoints(server) {
        const gateway = new braintree.BraintreeGateway({
            environment: braintree.Environment.Sandbox,
            merchantId: ApiConfig.PAYPALMERCHANTID,
            publicKey: ApiConfig.PAYPALPUBLICKEY,
            privateKey: ApiConfig.PAYPALPRIVATEKEY
        });

        server.post("/paypal/buy/item/:id", (req, res) => {
            let token = req.body.token;
            const nonceFromTheClient = req.body.nonce;
            const deviceData = req.body.device_data;
            let itemId = req.params.id;
            let price = this.socketController.getPriceEurForItem(itemId);
            if (price !== null) {
                gateway.transaction.sale({
                    amount: price.toString(),
                    paymentMethodNonce: nonceFromTheClient,
                    deviceData: deviceData,
                    options: {
                        submitForSettlement: true
                    }
                }).then(result => {
                    let buyItemResult = this.socketController.buyItemFromBank(token, itemId);
                    if (buyItemResult !== null) {
                        res.sendStatus(200);
                    } else {
                        res.sendStatus(404);
                    }
                }).catch((err) => {
                    res.sendStatus(404);
                });
            } else {
                res.sendStatus(404);
            }
        });

        server.get('/dadjoke', async (req, res) => {
            let header = {
                Accept: "application/json",
                "User-Agent": "axios 0.24.0"
            }
            let result = await axios.get("https://icanhazdadjoke.com/", { headers: header }).catch(e => {
                res.sendStatus(404);
            });
            if (result !== undefined) {
                res.status(200).send(result.data.joke);
            }
        });

        server.post("/link/external", async (req, res) => {
            let token = req.body.token;

            let data = {
                id: req.body.id,
                username: req.body.username,
                email: req.body.email,
                type: req.body.type,
                refresh_token: req.body.refresh_token,
                access_token: req.body.access_token,
                access_token_secret: req.body.access_token_secret,

            }
            let result = await this.socketController.linkUserToExternal(token, data).catch((err)=>{});
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.post("/veggiecrush/inventory", async (req, res) => {
            let token = req.body.token;
            let result = await this.socketController.getVeggiecrushInventory(token).catch((err)=>{});
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.post("/veggiecrush/use/potion", async (req, res) => {
            let token = req.body.token;
            let potionId = req.body.potion_id;
            let result = await this.socketController.useVeggiePotion(token, potionId).catch((err)=>{});
            this.sendNotFoundOrOkWithResult(res, result);
        });
        server.post("/boomcraft/add/resource", async (req, res) => {
            let token = req.body.token;
            let resourceLabel = req.body.label;
            let quantity = req.body.quantity;
            let result = await this.socketController.addResourcesToBoomcraft(token, resourceLabel, quantity).catch((err)=>{});
            this.sendNotFoundOrOkWithResult(res, result);
        });
    }

    defineFromApiEndpoints(server) {
        server.post('/external/add/ally', (req, res) => {
            let id = req.body.village_id;
            let quantity = req.body.quantity;
            if (id === undefined || quantity === undefined) {
                res.sendStatus(422);
            } else {
                let result = this.socketController.externalAddAlly(id, quantity);
                if (result === null) {
                    res.sendStatus(404);
                } else {
                    res.sendStatus(200);
                }
            }
        });
        server.post('/external/add/event', (req, res) => {
            let ev = new ExternalEvent();
            if (ev.initEvent(req.body.label, req.body.level, req.body.quantity)) {
                let result = this.socketController.externalAddEvent(req.body.village_id, ev);
                if (result === null) {
                    res.sendStatus(404);
                } else {
                    res.sendStatus(200);
                }
            } else {
                res.sendStatus(422);
            }
        });
        server.post('/external/add/resources', (req, res) => {
            let resources = [];
            for (let r of req.body.resources) {
                resources.push(new Resource(r.label, r.quantity, r.max_quantity));
            }
            let result = this.socketController.externalAddResources(req.body.village_id, resources);
            if (result === null) {
                res.sendStatus(404);
            } else {
                res.sendStatus(200);
            }
        });
    }
    /**
     * Load data from server and create game instance
     * @param client
     * @param self
     * @param message
     */
    loadProfile(dataToken, res) {
        let self = this;

        UserService.getDataAccount(dataToken.access_token, dataToken.token_type).then(async (resp) => {
            let dataAccount = JSON.parse(JSON.stringify(resp.data));
            let userDataAccount = {
                id: dataAccount._id,
                username: dataAccount.username,
                access_token: dataToken.access_token,
                token_type: dataToken.token_type,
            }
            let currentUser = new User();
            currentUser.initFromObjDb(dataAccount);
            currentUser.TokenType = dataToken.token_type;
            currentUser.AccessToken = dataToken.access_token;

            await this.refreshVeggieCrushToken(currentUser).catch((err)=>{});

            VillageService.getVillagesByUserId(currentUser.Id).then(async (respGetVillages) => {
                currentUser.initVillagesFromObj(JSON.parse(JSON.stringify(respGetVillages.data)));
                if (currentUser.Villages.length === 0 || currentUser.Villages.find(v=> v.Principal === true) === undefined) {
                    let newVillage = new Village();
                    newVillage.initBaseVillage(currentUser.Id, "Principal", self.gameData.Buildings, true);
                    VillageService.createVillage(currentUser.Id, newVillage).then(respCreate => {
                        newVillage.initFromObj(JSON.parse(JSON.stringify(respCreate.data)));
                        currentUser.addVillage(newVillage);
                        self.loadPlayer(self, userDataAccount, currentUser, res);
                    }).catch((error) => {
                        self.sendErrorResponse(error, res);
                    });
                } else {
                    self.loadPlayer(self, userDataAccount, currentUser, res);
                }
            }).catch((error) => {
                self.sendErrorResponse(error, res);
            });
        }).catch(error => {
            self.sendErrorResponse(error, res);
        });

    }
    async loadToken(username, password) {
        let dataToken = await UserService.getToken(username, password).catch(() => { });
        if (dataToken !== undefined) {
            return JSON.parse(JSON.stringify(dataToken.data));
        } else {
            return undefined;
        }
    }
    async loadTokenFromExternalLogin(id, type) {
        let dataToken = await UserService.loginUserWithExternal(id, type).catch(() => { });
        if (dataToken !== undefined) {
            return JSON.parse(JSON.stringify(dataToken.data));
        } else {
            return undefined;
        }
    }

    async refreshVeggieCrushToken(user) {

        let link = user.checkIfLinkExists(ApiConfig.VEGGIECRUSH);
        if (link !== undefined) {
            let req = await VeggiecrushService.refreshToken(link.refresh_token).catch((err) => {
            });
            if (req !== undefined) {
                let data = JSON.parse(JSON.stringify(req.data));
                let newToken = data.refresh_token;
                let update = await UserService.updateRefreshToken(user.Id, newToken).catch((err) => {
                });
                if (update !== undefined) {
                    let newExternalLogins = JSON.parse(JSON.stringify(update.data)).external_logins;
                    user.ExternalLinks = newExternalLogins;
                }
            }
        }
    }
    loadPlayer(self, userDataAccount, currentUser, res) {
        PlayerService.getPlayer(userDataAccount).then((playerDataResp) => {
            let playerFromDb = JSON.parse(JSON.stringify(playerDataResp.data));
            let playerModel = new Player();
            playerModel.initFromObj(playerFromDb);
            currentUser.Player = playerModel;
            if (currentUser.Player.Hp <= 0)
                currentUser.Player.Hp = currentUser.Player.MaxHp;
            let token = Utils.getRandomUUID();
            let clientResponse = {
                username: currentUser.username,
                email: currentUser.email,
                currency: currentUser.currency,
                villages: this.formatVillagesList(currentUser.villages),
                creation_time: currentUser.creation_time,
                external_logins: currentUser.external_logins,
                player: playerModel,
                token: token
            }
            self.socketController.tokenUserdataMap.set(token, currentUser);
            res.status(200).send(clientResponse);
        }).catch((error) => {
            self.sendErrorResponse(error, res);
        });
    }
    formatVillagesList(villages) {
        let result = [];
        for (let v of villages) {
            result.push(this.formatVillage(v));
        }
        return result;
    }
    formatVillage(village) {
        return {
            id: village._id,
            name: village.name,
            level: village.level,
            status: village.status,
            principal: village.principal,
            creation_time: village.creation_time,
            playing_time: village.playing_time,
        }
    }

    sendErrorResponse(error, res) {
        console.log(error);
        res.status(error.response.status).send(error.response.data);
    }
    sendNotFoundOrOkWithResult(res, result) {
        if (result === null) {
            res.sendStatus(404);
        } else {
            res.status(200).send(result);
        }
    }
}
