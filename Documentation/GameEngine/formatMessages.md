
# Envoi
### Session
| Description | Event | Data |
| --- |--- | --- |  
|Inscription| register| {username:"", email:"", password:""} |
| Connexion | connection |{username:"", password:""} |
| Connexion (avec les données récupérées sur /login) | connection2 | data:{}, selected_village:{} |
| Rejoindre partie| join game |{username:""}|
### Players Actions
| Description | Event | Data |
| --- |--- | --- |  
| Maj pos| action| {action:"move", direction:"", position:{"x":0,"y":0}}|
| Attaquer| action|{action:"attack"}|
|Joueur subit dégats(envoyé par l'hôte, vu que c'est lui qui gère les ennemis)| action|{action:"damage", damage:0, username: ""}| 

### Modification village
| Description | Event | Data |
| --- |--- | --- |  
| Créer village| village| {action:"create", name:""}
| Demande maj ressource village| village| {action:"get resources"}




### Ennemis IA
| Description | Event | Data |
| --- |--- | --- |  
| Créer IA (envoyé par l'hôte)| AI| {action:"spawn", type:"ally/enemy" direction:"", position:{"x":0,"y":0}}, id:"", max_hp:0, hp:0}|
| Maj pos| AI| {action:"move", direction:"", position:{"x":0,"y":0}}, id:""}|
| Attaquer| AI| {action:"attack", id:"", direction: 0}|
| IA subit dégats (envoyé par celui qui a touché l'IA)| AI| {action:"damage", damage:0, id:""}|


### Data
| Description | Event | Data |
| --- |--- | --- |  
| Obtenir liste joueurs| data| {request:"players"}|

### Building
| Description | Event | Data |
| --- |--- | --- |  
| Dégats bâtiment| building| {action:"damage", building_id:"", damage:0}|

# Réception

### Session
| Description | Event | Data |
| --- |--- | --- | 
|Réponse connexion|first loading|{username: "",email: "", premium_currency: "",villages: [ ], creation_time: "", player:{hp,...}}| 
|Réponse connexion (version http)|game started| - |

### Players actions

| Description | Event | Data |
| --- |--- | --- | 
|Player joined game|player update|{action:"connection", username: ""}| 
|Update player mouvement|player update|{action:"move",username: "", direction: "", position:{"x":0,"y":0}}| 
|Player attack animation|player update|{action:"attack",username: ""}| 
|Joueur subit des dégats (reçu par tous les joueurs sauf hôte vu que c'est lui qui produit les dmg, pour par exemple metre à jour la barre de vie des alliés)| player update|{action:"damage", damage:0, username: ""}| 
|Update inventaire (max_quantity = -1 si pas de max)|player update|{action:"inventory",inventory: [{label:"", quantity:0, max_quantity:0}]| 
|Joueur ramasse boite|remove box|{box_id: ""}| 
|Nouvelle valeur hp d'un joueur (heal) |player update|{action:"hp", hp:0, username:""}| 

### IA
 C'est l'hôte qui génère les actions de l'IA et elles sont propagées aux autres joueurs.
| Description | Event | Data |
| --- |--- | --- |  
| Demande création ennemi/allié (envoyé par le serveur à l'hôte)| AI | {action:"create", type:"enemy/ally", number:0}|
| Nouvelle IA vient de spawn| AI | {action:"spawn", type:"ally/enemy" direction:"", position:{"x":0,"y":0}}, id:"", max_hp:0, hp:0}|
| Maj pos| AI| {action:"move", direction:"", position:{"x":0,"y":0}}, id:""|
| Attaquer| AI| {action:"attack", id:"", direction: 0}|
| IA subit des dégats | AI| {action:"damage", damage:0, id:"" }|
| Maj HP IA (heal event) | AI | {action:"hp", id:"", hp:0 }|

### Bâtiments
| Description | Event | Data |
| --- |--- | --- |
| Afficher nouvelle ressource | update box | {base_id = "", production_type = "", box_id =""} |
| Update lvl bâtiment | building| {action:"upgraded",building_id = "", level:0} |
| Bâtiment détruit| building | {action:"destroyed", building_id = ""} |
| Bâtiment réparé| building | {action:"repaired", building_id = ""} |
| Bâtiment prend dégats| building | {action:"damage", building_id = "", damage:0} |

### Modification village
| Description | Event | Data |
| --- |--- | --- |  
| Maj affichage ressources| update resources| {action:"resources", resources_village:{}, resources_player:{}}

### Effects
| Description | Event | Data |
| --- |--- | --- |
| Fin d'un buff | effect | {action : "stop", target:""} |

### Events
| Description | Event | Data |
| --- |--- | --- |
| Notification calamité | event | {action:"notification", type:"calamity", level:0, countdown:0} |
| Notification invasion | event | {action:"notification", type:"invasion", level:0, countdown:0} |
| Début invasion | event | {action:"start", type:"invasion", level:0} |
| Début calamité | event | {action:"start", type:"calamity", level:0} |

### Data
| Description | Event | Data |
| --- |--- | --- |  
| Réponse liste joueurs| players list| [ [ socketId, username ], [ 'ee', 'bouboule' ] ] |
| update weather| weather update| Snow / Rain / Clear / ... https://openweathermap.org/weather-conditions |
| update day| day update|  Day / Night |

### Erreur
| Description | Event | Data |
| --- |--- | --- |  
| Info erreur| error| {message:""} |


# NOUVEAU SYSTEME CONNEXION
## Envoi
| Description | Event | Data |
| --- |--- | --- |  
| enregistrer token| register token| {token:""} |

# Mort joueur
## Réception
| Description | Event | Data |
| --- |--- | --- |  
| Joueur mort et kick de la game (reçu par tous les joueurs)| player left| {username:"", type:"disconnection/death"} |
| Fin de la partie (mort de l'hôte ou déconnexion de l'hôte)| game ended| {type:"disconnection/death"}|