from pydantic import BaseModel, Field
from typing import List
from bson import ObjectId

from schemas.object_id import PyObjectId


class PResource(BaseModel):
    label: str
    quantity: int
    max_quantity: int

class PResourceExternalPost(BaseModel):
    label: str
    quantity: int

class PResourceExternal(BaseModel):
    label: str
    quantity: int

class PPlayer(BaseModel):
    user_account: PyObjectId
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    
    class Config:
        json_encoders = {ObjectId: str}

class PPlayerStats(PPlayer):
    hp: int
    max_hp: int
    inventory: List[PResource]

class PPlayerPut(BaseModel):
    hp: int
    max_hp: int
    inventory: List[PResource]
