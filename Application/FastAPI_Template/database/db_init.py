from mongoengine import connect

from config.parameters import DB_URL
from mongoengine import connect

db = connect(host=DB_URL)