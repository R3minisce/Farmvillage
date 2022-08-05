from fastapi import APIRouter, HTTPException, status, Security
from typing import List

from routers.perms import get_current_active_user

from database.controllers import players

from database.models.user import User
from schemas.player import PPlayer, PPlayerStats, PPlayerPut
router = APIRouter(prefix="/players", tags=["players"])


def verify_player(id: str):
    obj =  players.get_player(id)
    if obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    return obj


@router.get("/page/{page}", response_model=List[PPlayerStats])
def get_players(page: int):
    return players.get_players(page)


@router.get("/{id}", response_model=PPlayerStats)
def get_player_by_player_id(id: str) :
    return verify_player(id)



# @router.get("/user/{id}", response_model=PPlayerStats)
# def get_player_by_user_id(id: str):
#     obj =  players.get_player_by_user(id)
#     if obj is None:
#         raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
#     return obj


# @router.post("/", status_code=status.HTTP_201_CREATED, response_model=PPlayerDB)
# def create_player(player: PPlayer):
#     try: 
#         return players.create_player(player)
#     except:
#         raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
#                             detail="Invalid playername or email")


@router.put("/{id}", response_model=PPlayerStats)
def update_player(player: PPlayerPut, id: str,
                      #current_player: User = Security(get_current_active_player, scopes=["admin"])
                      ):
    if not verify_player(id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Could not validate credentials")
    return players.update_player(player, id)


@router.delete("/{id}", status_code=status.HTTP_200_OK)
def delete_player(id: str,
                      current_player: User = Security(get_current_active_user, scopes=["admin"])
                      ) -> dict[str, str]:
    if  verify_player(id):
        return players.delete_player(id)