
# Connexion
| Url | Type | Data | Response|
| --- |--- | --- | --- |
|/login| post| {username:"", password:""} |{"username":"","email":"","villages":[{"user_account":"","_id":"","name":"","level":0,"status":"","principal":true,"creation_time":"","last_connection":"","resources":[],"events":[],"buildings":[{"base_id":"","label":"","level":1,"storage":0,"villagers":[]}]}],"creation_time":"","player":{"_id":"","user_account":"","hp":50,"max_hp":50,"inventory":[]}} |
|/logout | post | {username:""} | (200) / (404) |

# Bâtiments
|Description| Url | Type | Data | Response|
| --- | --- | --- | --- | --- |
| Infos building |  /building | post | {username:"", building_id:""} | Objet avec les infos du bâtiments |
| Upgrade building| /building/upgrade | put | {username:"", building_id:""} | Objet avec les nouvelles infos du bâtiments |
|Augmenter quantité ressource stockée pour upgrade| /building/upgrade/resource | put | {username:"", building_id:"", label:"", quantity:0} | (200) true = ok, false = bâtiment full/ inventaire player insuffisant/ la quantité est trop grande par rapport aux ressources requises, / (404) |
| Add villager to building |  /building/villager | post | {username:"", building_id:""} | (200) true= ok, false = déjà full ou pas de villageois dispo, / (404) |
| Remove villager from building |  /building/villager | delete | {username:"", building_id:""} | (200) true= ok, false = déjà vide, / (404) |
| Déposer (quantity >0)/ retirer (quantity <0) ressource |  /building/resource | put | {username:"", building_id:"", label:"", quantity: 0} | (200) true transfert ok, false = bâtiment-  player full ou pas assez de ressources/ (404) |
| Réparer |  /building/repair | post | {username:"", building_id:""} | (200) true ok , false pas assez de gold / (404) |


# Player
|Description| Url | Type | Data | Response|
| --- | --- | --- | --- | --- |
| Ramasser boite |  /pickbox | post | {username:"", building_id:"", box_id=""} | (200) true = ok, false = player full / (404) |

# AI
|Description| Url | Type | Data | Response|
| --- | --- | --- | --- | --- |
| Heal AI |  /healally| post | {username:"", ai_id:""} | (200) true = heal ok et gold retiré,  false = pas assez de gold / (404) |

# Items
|Description| Url | Type | Data | Response|
| --- | --- | --- | --- | --- |
| get items list |  /item/{type}| get | - | liste d'items correspondant au type |
| buy item|  /buy/item| post | {username:"", item_id:""} | (200) {label:"", target: "", ratio: 0, type:""} -- false pas assez de gold / (404) |
| buy villager|  /buy/villager| post | {username:""} | (200) true -- false pas assez de gold ou villager full / (404) |
| buy ally|  /buy/ally| post | {username:""} | (200) true -- false pas assez de gold ou allies full / (404) |

# API externes
|Description| Url | Type | Data | Response|
| --- | --- | --- | --- | --- |
| dadjokes |  /dadjoke| get | - | une bonne blague bien drôle |

# From API
|Description| Url | Type | Data | Response|
| --- | --- | --- | --- | --- |
| Ajout event invasion (level) |  /external/add/event| post | {village_id:"", label:"invasion, level:0} | 200 / 404 / 422 |
| Ajout event invasion (quantité) |  /external/add/event| post | {village_id:"", label:"invasion, quantity:0} | 200 / 404 / 422 |
| Ajout event calamité |  /external/add/event| post | {village_id:"", label:"calamity", level:0} | 200 / 404 / 422 |
| Ajout alliés |  /external/add/ally| post | {village_id:"", quantity:0} | 200 / 404 / 422 |
| Ajout ressources |  /external/add/resources| post | {village_id:"", resources:[{label:"",quantity:0, max_quantity:0}]} | 200 / 404 |
| Ajout Heal |  /external/add/heal| post | {village_id:"", level:0} | 200 / 404 |


# DOC NOUVELLE CONNEXION
|Description| Url | Type | Data | Response|
| --- | --- | --- | --- | --- |
| Register |  /register| post | {username:"", email:"", password:""} | 200 json infos user, liste villages, token / 404 |
| Login |  /login| post | {username:"", password:""} |200 json infos user, liste villages, token / 404 |
| Connexion à un village |  /join/village| post | {token:"", village_id:""} |200 {village, resources, weather, day} / 404 |
| Connexion à un ami |  /join/friend| post | {token:"", username:""} |200 {village, resources, weather, day} / 404 |
| Création village |  /create/village| post | {token:"", village_name:""} |200 infos basiques du village  / 404 |

# Services externe
|Description| Url | Type | Data | Response|
| liaison service | /link/external | post | {token, id, username, email, type} | 200 / 404 |
| inventaire veggie  | /veggiecrush/inventory | post | {token} | 200 tableau potions/ 404 |
| use veggie potion | /veggiecrush/use/potion | post | {token, potion_id} | 200 {label:"", target: "", ratio: 0, type:""}/ 404 |
| envoi ressources boomcraft | /boomcraft/add/resource | post | {token, label, quantity} | 200 true - false/ 404 |