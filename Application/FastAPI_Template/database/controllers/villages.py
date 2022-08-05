from typing import List
from fastapi import HTTPException, status
from config.parameters import GAME_ENGINE_IP
from database.controllers.users import get_user_by_username
from database.models.event import Event
from database.models.ia import IA
from database.models.resource import Resource
from database.models.user import Building, User, Village
from database.models.villager import Villager
from schemas.building import PBuilding
from schemas.event import PEvent
from schemas.player import PResourceExternalPost

from services.dependencies import setattrs
from schemas.village import PVillage, PVillageExternal, PVillageUpdate

import uuid
import requests

def get_village(id: str):
    try:
        village = Village.objects(id=id).first().to_mongo().to_dict()
        village["nb_allies"] = len(village["allies"])
    except:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="Invalid id")
    return village


def get_villages_by_user_id(id: str):
    try:
        villages = [village.to_mongo().to_dict() for village in Village.objects(user_account=id)]
        for v in villages: v["nb_allies"] = len(v["allies"])
    except:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="Invalid user id")
    return villages


def get_villages_by_username(username: str):
    try:
        user = User.objects(username=username).first().to_mongo().to_dict()
        villages = [village.to_mongo().to_dict() for village in Village.objects(user_account=user["_id"])]
        for v in villages: v["nb_allies"] = len(v["allies"])
    except:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="Invalid username")
    return villages


def create_village(village: PVillage):
    try: 
        obj = Village(user_account=village.user_account, name=village.name, level=village.level, principal=village.principal, playing_time=village.playing_time).save()
        buildings_list = []
        for b in village.buildings:
            building_obj =  Building(hp=b.hp, max_hp=b.max_hp, base_id=b.base_id, label=b.label, level=b.level, storage=b.storage, max_storage=b.max_storage, production=b.production, max_villager=b.max_villager, production_type=b.production_type)
            building_obj.villagers = [Villager(id=villager.id) for villager in b.villagers]
            building_obj.upgrade_resources = [Resource(label=resource.label, quantity=resource.quantity, max_quantity=resource.max_quantity) for resource in b.upgrade_resources]
            building_obj.storage_resources = [Resource(label=sr.label, quantity=sr.quantity, max_quantity=sr.max_quantity) for sr in b.storage_resources]
            buildings_list.append(building_obj)
        obj.buildings = buildings_list
        obj.save()
        return obj.to_mongo().to_dict()
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")


def create_village_external(village: PVillageExternal):
    try:
        
        user = get_user_by_username(village.owner_username)
        obj = Village(user_account=user["_id"], name=village.name, level=village.level*9, principal=False, status="external", playing_time=0).save()
        obj.resources = [Resource(label=r.label, quantity=r.quantity, max_quantity=-1) for r in village.resources]
        obj.allies = [IA(id=str(uuid.uuid4()), type="ally", hp=160, max_hp=160, pos_x=0, pos_y=0) for i in range (village.nb_allies)]
        obj.save()
        obj_dict = obj.to_mongo().to_dict()
        obj_dict["nb_allies"] = len(obj.allies)
        return obj_dict
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")


def update_village(village: PVillageUpdate, id: str):
    try: 
        obj = Village.objects(id=id).get()

        # Désolé mais .. flemme

        obj.level = village.level
        obj.status = village.status
        obj.principal = village.principal
        obj.playing_time = village.playing_time

        ## Resources
        obj.resources = [Resource(**r.dict()) for r in village.resources]

        ## IAs
        obj.allies = [IA(**ia.dict()) for ia in village.allies]
        
        ## Events
        events_list = [Event(label=e.label, level=e.level) for e in village.events]
        obj.events = events_list

        ## Buildings
        buildings_list = []
        for b in village.buildings:
            building_obj =  Building(hp=b.hp, max_hp=b.max_hp, base_id=b.base_id, label=b.label, level=b.level, storage=b.storage, max_storage=b.max_storage, production=b.production, max_villager=b.max_villager, production_type=b.production_type)
            building_obj.upgrade_resources = [Resource(label=resource.label, quantity=resource.quantity, max_quantity=resource.max_quantity) for resource in b.upgrade_resources]
            building_obj.storage_resources = [Resource(label=sr.label, quantity=sr.quantity, max_quantity=sr.max_quantity) for sr in b.storage_resources]
            building_obj.villagers = [Villager(id=v.id) for v in b.villagers]
            buildings_list.append(building_obj)
        obj.buildings = buildings_list

        obj.save()
        return obj.to_mongo().to_dict()

    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")


def update_village_resources(resources: List[PResourceExternalPost], id: str):
    detail = "Error during processing. Refer to a developer."
    try:
        if (len(resources) > 4):
            detail = "you can only add a maximum of 4 different resources."
            raise HTTPException()

        authorised_resources = ["WOOD", "IRON", "STONE", "FOOD"]
        for test_r in resources:
            if (test_r.label.upper() not in authorised_resources or test_r.quantity < 100 or test_r.quantity > 5000):
                detail = "you can only add resources with the following labels [ WOOD IRON FOOD STONE ] and between 100 & 5000."
                raise HTTPException()
        try:
            data = {"village_id": id, "resources": [Resource(label=r.label, quantity=r.quantity, max_quantity=-1).to_mongo().to_dict() for r in resources]}
            result = requests.post(url = f"{GAME_ENGINE_IP}/external/add/resources", json = data)
            if result.status_code == 200 :
                return {"msg":"Updated live"}
            else:
                raise Exception()

        except:
            obj = Village.objects(id=id).get()
            new_resources = [Resource(label=r.label, quantity=r.quantity, max_quantity=-1) for r in resources]
            obj.resources = new_resources + obj.resources
            obj.save()
            return {"msg":"Updated in DB"}
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail=detail)


def update_village_IAs(IAs: int, id: str):
    detail = "Error during processing. Refer to a developer.";
    try:
        # Vérification de l'input pour l'ajout d'alliés
        if (IAs > 20 or IAs < 1):
            detail="you can only add a maximum of 20 allies."
            raise HTTPException()

        try:
            data = {"village_id": id, "quantity": IAs}
            result = requests.post(url = f"{GAME_ENGINE_IP}/external/add/ally", json = data)
            if result.status_code == 200 :
                return {"msg":"Updated live"}
            else:
                raise Exception()

        except:
            # Village et vérification de l'INN
            obj = Village.objects(id=id).get()
            try: 
                buildings = obj.to_mongo().to_dict()["buildings"]
                inn = next(x for x in buildings if x["base_id"]=="B_08")
                storage = inn["storage"]
                max_storage = inn["max_storage"]
            except: 
                detail = "There is no inn yet."
                raise HTTPException()

            # Calcul et ajout des alliés
            new_allies = []
            if (storage == max_storage):
                detail="There is no more room for allies."
                raise HTTPException()

            elif (storage + IAs >= max_storage):
                new_allies = [IA(id=str(uuid.uuid4()), type="ally", hp=160, max_hp=160, pos_x=0, pos_y=0) for i in range (max_storage - storage)]
            else:
                new_allies = [IA(id=str(uuid.uuid4()), type="ally", hp=160, max_hp=160, pos_x=0, pos_y=0) for i in range (IAs)]
            obj.allies = new_allies + obj.allies
            obj.save()
            return {"msg":"Updated in DB"}

    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail=detail)


def update_village_event(event: PEvent, id: str):
    detail = "Error during processing. Refer to a developer."
    try:
        authorised_event = ["INVASION", "CALAMITY", "HEAL"]
        if (event.label.upper()  not in  authorised_event):
            detail="you can only add events with the following labels [ INVASION CALAMITY HEAL ]."
            raise HTTPException()

        try:
            data = {"village_id": id, "label": event.label, "level":event.level, "quantity": event.quantity}
            result = requests.post(url = f"{GAME_ENGINE_IP}/external/add/event", json = data)
            if result.status_code == 200 :
                return {"msg":"Updated live"}
            else:
                raise Exception()
        except:
            obj = Village.objects(id=id).get()
            events_list = [Event(label=event.label, level=event.level, quantity=event.quantity)]
            obj.events = events_list + obj.events 
            obj.save()
            return {"msg":"Updated in DB"}
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail=detail)


def update_village_buildings(buildings: List[PBuilding], id: str):
    try: 
        obj = Village.objects(id=id).get()
        buildings_list = []
        for b in buildings:
            building_obj =  Building(hp=b.hp, max_hp=b.max_hp, base_id=b.base_id, label=b.label, level=b.level, storage=b.storage, max_storage=b.max_storage, production=b.production, max_villager=b.max_villager, production_type=b.production_type)
            building_obj.villagers = [Villager(id=villager.id) for villager in b.villagers]
            building_obj.upgrade_resources = [Resource(label=resource.label, quantity=resource.quantity, max_quantity=resource.max_quantity) for resource in b.upgrade_resources]            
            building_obj.storage_resources = [Resource(label=sr.label, quantity=sr.quantity, max_quantity=sr.max_quantity) for sr in b.storage_resources]
            buildings_list.append(building_obj)
        obj.buildings = buildings_list
        obj.save()
        return obj.to_mongo().to_dict()
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")


def delete_village(id: str) -> dict[str, str]:
    try:
        Village.objects(id=id).delete()
    except:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="Invalid id")
    return {"INFO": "Village deleted"}
