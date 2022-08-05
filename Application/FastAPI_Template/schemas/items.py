from pydantic import BaseModel, Field
from bson import ObjectId
from schemas.object_id import PyObjectId

class PItem(BaseModel):
    label: str
    type: str
    desc: str
    target: str
    ratio: int
    price: int
    duration: int

class PItemOut(PItem):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")

    class Config:
        json_encoders = {ObjectId: str}