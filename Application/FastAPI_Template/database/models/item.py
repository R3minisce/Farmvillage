from mongoengine.fields import IntField, StringField
from mongoengine.document import Document

class Item(Document):
    label = StringField(required=True)
    type = StringField(required=True)
    desc = StringField()
    target = StringField(required=True)
    ratio = IntField(required=True)
    price = IntField(required=True)
    duration = IntField(required=True)

    meta = {
        "indexes": ["type"],
        "ordering": ["-price"]
    }