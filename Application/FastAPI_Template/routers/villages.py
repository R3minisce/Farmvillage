from typing import List
from fastapi import APIRouter, HTTPException, Security
from starlette import status
from database.controllers import villages
from database.models.user import User
from schemas.building import PBuilding
from schemas.event import PEvent
from schemas.ia import PIA
from schemas.village import PVillage, PVillageAll, PVillagePut, PVillageExternal, PVillageExternalOut, PResourceExternalPost

from routers.perms import get_current_active_user

router = APIRouter(prefix="/villages", tags=["villages"])

@router.get("/{id}", response_model=PVillageAll)
def get_village(id: str):
    return villages.get_village(id)

# @router.get("/user/{id}", response_model=List[PVillageAll])
# def get_villages_by_user_id(id: str):
#     return villages.get_villages_by_user_id(id)
    

@router.post("/", status_code=status.HTTP_201_CREATED, response_model=PVillageAll)
def create_village(village: PVillage):
    try: 
        return villages.create_village(village)
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                            detail="Invalid Item")


@router.post("/external", status_code=status.HTTP_201_CREATED, response_model=PVillageExternalOut)
def create_village(village: PVillageExternal):
    try: 
        return villages.create_village_external(village)
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                            detail="Invalid Item")


def verify_village(id: str):
    obj =  villages.get_village(id)
    if obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    return obj

@router.put("/{id}", response_model=PVillageAll)
def update_village(village: PVillagePut, id: str,
                      #current_player: User = Security(get_current_active_player, scopes=["admin"])
                      ):
    if not verify_village(id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Could not validate credentials")
    return villages.update_village(village, id)


@router.put("/{id}/resources")
def add_resources_to_village_by_village_id(resources: List[PResourceExternalPost], id: str,
                      #current_player: User = Security(get_current_active_player, scopes=["admin"])
                      ):
    if not verify_village(id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Could not validate credentials")
    return villages.update_village_resources(resources, id)


@router.put("/{id}/events")
def add_events_to_village_by_village_id(event: PEvent, id: str,
                      #current_player: User = Security(get_current_active_player, scopes=["admin"])
                      ):
    if not verify_village(id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Could not validate credentials")
    return villages.update_village_event(event, id)


@router.put("/{id}/IAs")
def add_IAs_to_village_by_village_id(IAs: int, id: str,
                      #current_player: User = Security(get_current_active_player, scopes=["admin"])
                      ):
    if not verify_village(id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Could not validate credentials")
    return villages.update_village_IAs(IAs, id)


@router.put("/{id}/buildings", response_model=PVillageAll)
def update_village_buildings_by_village_id(buildings: List[PBuilding], id: str,
                      #current_player: User = Security(get_current_active_player, scopes=["admin"])
                      ):
    if not verify_village(id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Could not validate credentials")
    return villages.update_village_buildings(buildings, id)


@router.delete("/{id}", status_code=status.HTTP_200_OK)
def delete_village(id: str,
                      current_player: User = Security(get_current_active_user, scopes=["admin"])
                      ) -> dict[str, str]:
    if  not verify_village(id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Could not validate credentials")
        return villages.delete_village(id)