from typing import List
from fastapi import APIRouter
from starlette import status
from starlette.exceptions import HTTPException
from database.controllers import bases, villages, players
from routers import users
from schemas.event import PEvent
from schemas.player import PResourceExternalPost
from schemas.user import PUserDB, PUserExternal
from schemas.village import PVillageAll, PVillageExternal, PVillageExternalOut

router = APIRouter(prefix="/public", tags=["public"])

@router.get("/bases")
def get_craftable_buildings_stats():
    return bases.get_bases()


@router.get("/users/{username}", response_model=PUserExternal)
def get_user_by_username(username: str):
    obj =  users.get_user_by_username(username)
    obj["player"] = players.get_player_by_user(obj["_id"])
    if obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    return obj


@router.post("/villages", status_code=status.HTTP_201_CREATED, response_model=PVillageExternalOut)
def create_village(village: PVillageExternal):
    try: 
        return villages.create_village_external(village)
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                            detail="Invalid Item")

# @router.get("/users/{id}/villages", response_model=List[PVillageExternalOut])
# def get_villages_by_user_id(id: str):
#     return villages.get_villages_by_user_id(id)


@router.get("/users/{username}/villages", response_model=List[PVillageExternalOut])
def get_villages_by_username(username: str):
    return villages.get_villages_by_username(username)


@router.get("/villages/{id}", response_model=PVillageExternalOut)
def get_village(id: str):
    return villages.get_village(id)


@router.put("/villages/{id}/resources")
def send_resources_to_village_by_village_id(resources: List[PResourceExternalPost], id: str,
                      #current_player: User = Security(get_current_active_player, scopes=["admin"])
                      ):
    if not verify_village(id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Could not validate credentials")
    return villages.update_village_resources(resources, id)


@router.put("/villages/{id}/events")
def send_events_to_village_by_village_id(event: PEvent, id: str,
                      #current_player: User = Security(get_current_active_player, scopes=["admin"])
                      ):
    if not verify_village(id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Could not validate credentials")
    return villages.update_village_event(event, id)


@router.put("/villages/{id}/IAs")
def send_allies_to_village_by_village_id(IAs: int, id: str,
                      #current_player: User = Security(get_current_active_player, scopes=["admin"])
                      ):
    if not verify_village(id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Could not validate credentials")
    return villages.update_village_IAs(IAs, id)


def verify_village(id: str):
    obj =  villages.get_village(id)
    if obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    return obj