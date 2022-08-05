from pydantic import BaseModel
from pydantic.fields import Field

class PIA(BaseModel):
    id: str
    type: str
    hp: int
    max_hp: int
    pos_x: int
    pos_y: int

class PIAExternal(BaseModel):
    id: str
    hp: int
    max_hp: int