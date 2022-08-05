from fastapi import HTTPException, status
from database.models.resource import Resource

from services.dependencies import setattrs
from database.models.user import Player

from schemas.player import PPlayer, PPlayerStats

def get_player(id: str):
    try:
        player = Player.objects(id=id).first().to_mongo().to_dict()
        return player
    except:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="Invalid id")



def get_player_by_user(id: str):
    try:
        player = Player.objects(user_account=id).first().to_mongo().to_dict()
        return player
    except:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="Invalid user id")



def get_players(page: int):
    try: 
        return [player.to_mongo().to_dict() for player in Player.objects.skip((page)*50).limit(50)] # Pagination
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")


def create_player(player: PPlayer):
    try: 
        obj = Player(**player.dict()).save()
        return obj.to_mongo().to_dict()
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")


def update_player(player: PPlayerStats, id: str):
    try: 
        obj = Player.objects(id=id).get()
        obj.hp = player.hp
        obj.max_hp = player.max_hp
        obj.inventory = [Resource(**r.dict()) for r in player.inventory]
        obj.save()
        return obj.to_mongo().to_dict()
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")

def delete_player(id: str) -> dict[str, str]:
    try:
        Player.objects(id=id).delete()
        return {"INFO": "Player deleted"}
    except:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="Invalid id")

