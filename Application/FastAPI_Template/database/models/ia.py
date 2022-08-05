from mongoengine.fields import IntField, StringField
from mongoengine.document import EmbeddedDocument


class IA(EmbeddedDocument):
    id = StringField()
    type = StringField(required=True)
    hp = IntField()
    max_hp = IntField()
    pos_x = IntField()
    pos_y = IntField()

    meta = {
        "indexes": ["type"],
        "ordering": ["-hp"]
    }