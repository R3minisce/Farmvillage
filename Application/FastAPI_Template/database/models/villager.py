from mongoengine.fields import BooleanField, IntField, StringField
from mongoengine.document import EmbeddedDocument

class Villager(EmbeddedDocument):
    id = StringField(required=True)

    meta = {
        "indexes": ["id"],
        "ordering": ["+id"]
    }