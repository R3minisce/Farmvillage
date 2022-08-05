from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from bson import ObjectId

from config.parameters import PASSWORD_POLICY, EMAIL_POLICY
from schemas.object_id import PyObjectId
from schemas.player import PPlayer, PPlayerPut


class PExtLoginDb(BaseModel):
    id: str
    username: str
    email: Optional[str]  = None
    type: str
    refresh_token: Optional[str] = None
    access_token: Optional[str] = None
    access_token_secret: Optional[str] = None

class PExtLogin(BaseModel):
    id: str
    type: str


class PUserBase(BaseModel):
    username: str
    email: str = Field(..., regex=EMAIL_POLICY)


class PUserCurrency(BaseModel):
    currency: int


class PUserDB(PUserBase):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    currency: int
    scopes: List[str]
    creation_time: datetime
    external_logins: List[PExtLoginDb]

    class Config:
        json_encoders = {ObjectId: str}
        

class PUserPut(BaseModel):
    external_logins: List[PExtLoginDb]
    
class PUserPutIn(BaseModel):
    external_login: PExtLoginDb

class PUserStatus(PUserBase):
    disabled: bool


class PUserPass(PUserBase):
    password: str = Field(..., regex=PASSWORD_POLICY)


class PUserChangePass(BaseModel):
    old_password: str = Field(regex=PASSWORD_POLICY)
    new_password: str = Field(regex=PASSWORD_POLICY)


# External 

class PUserExternal(BaseModel):
    username: str
    currency: int   
    scopes: List[str]
    creation_time: datetime
    player : PPlayerPut