from mongoengine import connect
# from mongoengine.document import Document, DynamicDocument
# from mongoengine.fields import DateTimeField, ReferenceField, StringField, EmailField, BinaryField, ListField, IntField, BooleanField
# from datetime import datetime
import os
from datetime import date, datetime



IP = "192.168.0.15"
PORT = 27017
COLLECTION = "test"

db = connect(host=f"mongodb://{IP}:{PORT}/{COLLECTION}")

### ----------------------- TESTS -----------------------


## ---- USER CREATION ----

from database.models.user import User

user = User(
    username = "azeazeae",
    email = "azeaze@email.com",
    password = str(os.urandom(16)),
    premium_currency = 450,
    scopes = ["admin"]
).save()

print(user.to_json())

## ------- PLAYER CREATION ------

from database.models.player import Player
from database.models.resource import Resource

res_01 = Resource(label = "wood", quantity = 200, max_quantity = 400)

player = Player(
    pseudo = "azeazeaze",
    user_account = user,
    hp = 20,
    max_hp = 50,
    inventory = [res_01]
).save()

print(player.to_json())

## ------- EVENT CREATION ------

from database.models.event import Effect, Event

effect_01 = Effect(label="wood", ratio=200)

temp = 4
event_01 = Event(
    label = "event_01",
    type = "buff",
    effects = [effect_01],
    duration = temp,
    starting_time = datetime.utcnow,
)

print(effect_01.to_json())
print(event_01.to_json())

## ------- RESOURCES CREATION -------

from database.models.resource import Resource

res_02 = Resource(label = "stone", quantity = 200, max_quantity = 400)
res_03 = Resource(label = "iron", quantity = 200, max_quantity = 400)

print(res_02.to_json())

## ----- VILLAGER CREATION ------

from database.models.villager import Villager

vil_01 = Villager(
    name = "Thiery",
    hp = 20,
    max_hp = 20
)

print(vil_01.to_json())

## -------- BUILDINGS CREATION ------

from database.models.building import Building

build_01 =  Building(
    label = "HQ",
    # base = LA REFERENCE,
    level = 1,
    production_ratio = 0,
    villagers = [vil_01],
    storage = 200
)

print(build_01.to_json())

## -------- VILLAGE CREATION ----------

from database.models.village import Village

village = Village(
    name = "village_01",
    level = 1,
    principal = True,
    status = "jusqu_ici_tout_va_bien",

    events = [event_01],
    resources = [res_01, res_02, res_03],
    buildings = [build_01]
).save()

### ----------------------- EXAMPLE -----------------------

# # Defining documents
# class User(Document):
#     # username = StringField(unique=True, required=True)
#     username = StringField(required=True)
#     # email = EmailField(unique=True)
#     email = EmailField()
#     password = BinaryField(required=True)
#     categories = ListField()
#     admin = BooleanField(default=False)
#     creation_time = DateTimeField(default=datetime.utcnow)

#     def json(self):
#         user_dict = {
#             "username": self.username,
#             "email": self.email,
#             "password": self.password,
#             "categories": self.categories,
#             "admin": self.admin,
#             "creation_time": self.creation_time,
#         }
#         return json.dumps(user_dict)

#     meta = {
#         "indexes": ["username", "email"],
#         "ordering": ["-creation_time"]
#     }

# # Dynamic documents
# class Player(DynamicDocument):
#     # pseudo = StringField(unique=True)
#     pseudo = StringField()
#     user_account = ReferenceField(User)
#     creation_time = DateTimeField(default=datetime.utcnow)

#     meta = {
#         "indexes": ["pseudo"],
#         "ordering": ["-creation_time"]
#     }

# # Save Documents
# user = User(
#     username = "Romouleazezer",
#     email = "testaze@email.com",
#     password = os.urandom(16),
#     admin = True
# ).save()

# Player(
#     pseudo = "Romoulatorazezer",
#     user_account = user,
#     resources = ["wood 100", "iron 100", "stone 100"]
# ).save()

# for user in User.objects(username="aze"):
#     print(user.username)

# # User.objects(username="Romoule").delete()

# # Full CRUD

# # Change fields of an object
# user.username = "AzhorrLeBest"
# user.save()

# # Querying the database

# # Get All
# users = User.objects()
# print(users)

# # Get One
# test = User.objects(username="Romoule").first()
# print(test)

# # Filtering 
# test = User.objects(admin=True).first()
# print(test)

# # bing packing
# # mitrezal

