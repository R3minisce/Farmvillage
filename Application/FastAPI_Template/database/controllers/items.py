from fastapi import HTTPException, status
from database.models.item import Item

from services.dependencies import setattrs
from schemas.items import PItem

def get_item(id: str):
    try:
        item = Item.objects(id=id).first().to_mongo().to_dict()
        return item
    except:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="Invalid id")


def get_items():
    try: 
        return [item.to_mongo().to_dict() for item in Item.objects.all()] # Pagination
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")


def get_items_by_type(type: str):
    try: 
        return [item.to_mongo().to_dict() for item in Item.objects(type=type)] # Pagination
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")


def create_item(item: PItem):
    try: 
        obj = Item(**item.dict()).save()
        return obj.to_mongo().to_dict()
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")


def update_item(item: PItem, id: str):
    try: 
        obj = Item.objects(id=id).get()
        obj.label = item.label
        obj.type = item.type
        obj.desc = item.desc
        obj.price = item.price
        obj.target = item.target
        obj.ratio = item.ratio
        obj.duration = item.duration
        obj.save()
        return obj.to_mongo().to_dict()
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")

def delete_item(id: str) -> dict[str, str]:
    try:
        Item.objects(id=id).delete()
        return {"INFO": "Item deleted"}
    except:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="Invalid id")

