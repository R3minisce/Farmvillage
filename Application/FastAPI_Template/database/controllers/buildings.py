from fastapi import HTTPException, status
from database.models.user import Building


def get_building(id: str):
    try:
        building = Building.objects(id=id).first().to_mongo().to_dict()
        return building
    except:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="Invalid id")



def get_buildings_by_village_id(id: str):
    try:
        return [building.to_mongo().to_dict() for building in Building.objects(village_id=id)]
    except:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="Invalid village id")
