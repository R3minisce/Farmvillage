from pydantic import BaseModel, Field
from typing import List

from schemas.player import PResource

class PVillagers(BaseModel):
    id: str

class PBuilding(BaseModel):
    base_id: str
    label: str
    level: int
    storage: int
    max_storage: int
    production: int
    production_type: str
    villagers: List[PVillagers]
    max_villager: int
    upgrade_resources: List[PResource]
    storage_resources: List[PResource]
    hp: int
    max_hp: int


class PBuildingExternal(BaseModel):
    label: str
    level: int
    storage: int
    max_storage: int
    production: int
    production_type: str
    max_villager: int
    hp: int
    max_hp: int