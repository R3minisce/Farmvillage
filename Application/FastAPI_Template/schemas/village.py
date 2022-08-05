from datetime import datetime
from pydantic import BaseModel, Field
from typing import List
from bson import ObjectId
from schemas.building import PBuilding, PBuildingExternal
from schemas.event import PEvent
from schemas.ia import PIA, PIAExternal

from schemas.object_id import PyObjectId
from schemas.player import PResource, PResourceExternal, PResourceExternalPost

# ----- BASE ------

class PVillage(BaseModel):
    user_account: PyObjectId
    name: str
    level: int
    principal: bool
    playing_time: int
    buildings: List[PBuilding]

    class Config:
        json_encoders = {ObjectId: str}

class PVillageUpdate(BaseModel):
    status: str
    user_account: PyObjectId
    name: str
    level: int
    principal: bool
    playing_time: int
    buildings: List[PBuilding]

    class Config:
        json_encoders = {ObjectId: str}

# ------ EXTERNAL -----

class PVillageExternal(BaseModel):
    owner_username: str
    level: int = Field(1, min_value=1, max_value=9)
    name: str
    nb_allies: int
    resources: List[PResourceExternalPost]

    class Config:
        json_encoders = {ObjectId: str}

class PVillageExternalOut(BaseModel):

    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    status: str
    name: str
    level: int
    creation_time: datetime
    nb_allies: int
    resources: List[PResourceExternal]
    events: List[PEvent]
    buildings: List[PBuildingExternal]

    class Config:
        json_encoders = {ObjectId: str}


# ------ LOCAL -----

class PVillageAll(PVillage):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    status: str
    creation_time: datetime
    last_connection: datetime
    resources: List[PResource]
    events: List[PEvent]
    allies: List[PIA]

class PVillagePut(BaseModel):
    level: int
    principal: bool
    status: str
    playing_time: int
    resources: List[PResource]
    events: List[PEvent]
    buildings: List[PBuilding]
    allies: List[PIA]