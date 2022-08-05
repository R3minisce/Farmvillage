from fastapi.exceptions import HTTPException
from starlette import status
from database.db_init import db
from json import loads
from database.utils.json_encoder import JSONEncoder


def get_bases():
    try: 
        objs = db.get_database("test").base.find({})
        return [loads(JSONEncoder().encode(base)) for base in objs]
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")