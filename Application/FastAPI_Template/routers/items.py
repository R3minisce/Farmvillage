from fastapi import APIRouter, HTTPException, status, Security
from typing import List

from routers.perms import get_current_active_user

from database.controllers import items

from database.models.user import User
from schemas.items import PItem, PItemOut
router = APIRouter(prefix="/items", tags=["items"])


def verify_item(id: str):
    obj =  items.get_item(id)
    if obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    return obj

@router.get("/", response_model=List[PItemOut])
def get_items():
    return items.get_items()


@router.get("/type/{type}", response_model=List[PItemOut])
def get_items_by_type(type: str):
    return items.get_items_by_type(type)


@router.post("/", status_code=status.HTTP_201_CREATED, response_model=PItemOut)
def create_item(item: PItem):
    try: 
        return items.create_item(item)
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                            detail="Invalid item")


@router.put("/{id}", response_model=PItem)
def update_item(item: PItem, id: str,
                      #current_player: User = Security(get_current_active_player, scopes=["admin"])
                      ):
    if not verify_item(id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Could not validate credentials")
    return items.update_item(item, id)


@router.delete("/{id}", status_code=status.HTTP_200_OK)
def delete_item(id: str,
                      current_player: User = Security(get_current_active_user, scopes=["admin"])
                      ) -> dict[str, str]:
    if  verify_item(id):
        return items.delete_item(id)