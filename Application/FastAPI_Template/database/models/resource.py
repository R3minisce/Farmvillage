from mongoengine.fields import IntField, StringField
from mongoengine.document import EmbeddedDocument


class Resource(EmbeddedDocument):
    label = StringField(required=True, max_length=20)
    quantity = IntField()
    max_quantity = IntField()

    meta = {
        "indexes": ["label"],
        "ordering": ["+quantity"]
    }