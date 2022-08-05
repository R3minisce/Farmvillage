from mongoengine.document import Document, EmbeddedDocument
from mongoengine.fields import DateTimeField, EmbeddedDocumentListField, IntField, ReferenceField, StringField, EmailField, ListField, BooleanField
from datetime import datetime

from database.models.ia import IA

from .resource import Resource
from .event import Event
from .villager import Villager


class Building(EmbeddedDocument):
    base_id = StringField()
    label = StringField()
    level = IntField()
    production = IntField()
    villagers = EmbeddedDocumentListField(Villager)
    max_villager = IntField()
    upgrade_resources = EmbeddedDocumentListField(Resource)
    storage_resources = EmbeddedDocumentListField(Resource)
    storage = IntField()
    max_storage = IntField()
    production_type = StringField()
    hp = IntField()
    max_hp = IntField()

    meta = {
        "indexes": ["label"],
        "ordering": ["+level"]
    }


class Village(Document):
    user_account = ReferenceField("User", required=True)
    name = StringField(required=True)
    level = IntField()
    principal = BooleanField(default=False)
    status = StringField(default="common")
    creation_time = DateTimeField(default=datetime.utcnow)
    last_connection = DateTimeField(default=datetime.utcnow)
    playing_time = IntField()

    allies = EmbeddedDocumentListField(IA)
    resources = EmbeddedDocumentListField(Resource)
    events = EmbeddedDocumentListField(Event)
    buildings = EmbeddedDocumentListField(Building)


    meta = {
        "indexes": ["name"],
        "ordering": ["+level"]
    }

class Player(Document):
    user_account = ReferenceField("User", required=True)
    hp = IntField(default=1000)
    max_hp = IntField(default=1000)
    inventory = EmbeddedDocumentListField(Resource)

    meta = {
        "indexes": ["user_account"],
        "ordering": ["-creation_time"]
    }
    
class ExtLogin(EmbeddedDocument):
    username = StringField(required=True)
    email = EmailField(required=False)
    id = StringField(required=True)
    type = StringField(required=True)
    refresh_token = StringField(required=False)
    access_token = StringField(required=False)
    access_token_secret = StringField(required=False)
    
    def json(self):
        return self.to_json()

    meta = {
        "indexes": ["username", "email"],
        "ordering": ["-type"]
    }

class User(Document):
    username = StringField(unique=True, required=True)
    email = EmailField(unique=True, required=True)
    password = StringField(required=True)
    currency = IntField(default=0)
    disabled = BooleanField(default=False)
    scopes = ListField(StringField())
    creation_time = DateTimeField(default=datetime.utcnow)
    external_logins = EmbeddedDocumentListField(ExtLogin)

    def json(self):
        return self.to_json()

    meta = {
        "indexes": ["username", "email"],
        "ordering": ["-creation_time"]
    }

