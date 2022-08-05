from pydantic import BaseModel

class PEvent(BaseModel):
    label: str
    level: int
    quantity: int