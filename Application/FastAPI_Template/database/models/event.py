from mongoengine.fields import IntField, StringField
from mongoengine.document import EmbeddedDocument

class Event(EmbeddedDocument):
    label = StringField(required=True)
    level = IntField(min_value=0, max_value=10)
    quantity = IntField(min_value=0, max_value=50)


    meta = {
        "indexes": ["label"],
        "ordering": ["-level"]
    }