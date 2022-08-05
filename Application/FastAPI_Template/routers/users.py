from typing import List

from fastapi import APIRouter, HTTPException, status, Security
from routers.perms import get_current_active_user
from database.controllers import users, players, villages

from database.models.user import User
from schemas.player import PPlayerStats
from schemas.token import RefreshToken
from schemas.user import PUserDB, PUserPass, PUserCurrency, PUserChangePass, PUserPut, PUserPutIn
from schemas.village import PVillageAll

router = APIRouter(prefix="/users", tags=["users"])


def verify_user(id: str):
    obj =  users.get_user(id)
    if obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    return obj


@router.get("/{id}", response_model=PUserDB)
def get_user(id: str) :
    return verify_user(id)


@router.get("/page/{page}", response_model=List[PUserDB])
def get_users(page: int):
    return users.get_users(page)


@router.get("/username/{username}", response_model=PUserDB)
def get_user_by_username(username: str):
    obj =  users.get_user_by_username(username)
    if obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    return obj


@router.get("/{id}/villages", response_model=List[PVillageAll])
def get_villages_by_user_id(id: str):
    return villages.get_villages_by_user_id(id)


@router.get("/{id}/player", response_model=PPlayerStats)
def get_player_by_user_id(id: str):
    obj =  players.get_player_by_user(id)
    if obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    return obj


@router.post("/", status_code=status.HTTP_201_CREATED, response_model=PUserDB)
def create_user(user: PUserPass):
    try: 
        return users.create_user(user)
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                            detail="Invalid username or email")
        
@router.put("/{id}/external_login", response_model=PUserPut)
def update_user(user: PUserPutIn, id: str,
                      #current_user: User = Security(get_current_active_user, scopes=["admin"])
                      ):
    if not verify_user(id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Could not validate credentials")
    user = users.add_user_logins(user, id)
    if user is not None:
        return user 
    raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Account already linked to another account.")


@router.put("/{id}/update_external_login", response_model=PUserPut)
def update_user(token: RefreshToken, id: str,
                      #current_user: User = Security(get_current_active_user, scopes=["admin"])
                      ):
    if not verify_user(id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Could not validate credentials")
    user = users.update_user_logins(token.refresh_token, id)
    if user is not None:
        return user 
    raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Account already linked to another account.")

@router.put("/{id}/currencies", response_model=PUserDB)
def update_user_currency(user: PUserCurrency, id: str,
                      #current_user: User = Security(get_current_active_user, scopes=["admin"])
                      ):
    if not verify_user(id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Could not validate credentials")
    return users.update_user(user, id)      

@router.delete("/{id}", status_code=status.HTTP_200_OK)
def delete_user(id: str,
                      current_user: User = Security(get_current_active_user, scopes=["admin"])
                      ) -> dict[str, str]:
    if  verify_user(id):
        return users.delete_user(id)


@router.put("/pass")
def change_user_password(passwords: PUserChangePass,
                               current_user: User = Security(get_current_active_user, scopes=["me"])):
    if verify_user(current_user["_id"]):
        return users.update_user_password(passwords, current_user["_id"])