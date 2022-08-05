from fastapi import HTTPException, status
from bcrypt import checkpw

from services.dependencies import hash_password, setattrs
from database.models.user import ExtLogin, User, Player

from schemas.user import *


def get_user(id: str):
    try:
        user = User.objects(id=id).first().to_mongo().to_dict()
    except:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="Invalid id")
    return user


def get_user_by_username(username: str):
    try:
        user = User.objects(username=username).first().to_mongo().to_dict()
    except:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="Invalid username")
    return user

def get_user_external(type: str, id: str):
    try:
        user = User.objects().filter(external_logins__match={"type": type, "id": id}).first().to_mongo().to_dict()
    except:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="User not found")
    return user


def get_users(page: int):
    try: 
        return [x.to_mongo().to_dict() for x in User.objects.skip((page)*50).limit(50)] # Pagination
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")


def create_user(user: PUserPass):
    try: 
        password = hash_password(user.password.encode())
        obj = User(username=user.username, email=user.email, password=password, scopes=["user"]).save()
        Player(user_account=obj.id).save()
        return obj.to_mongo().to_dict()
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")


def update_user(user: PUserStatus, id: str):
    try: 
        user_out = User.objects(id=id).get()
        setattrs(user_out, **user.dict())
        user_out.save()
        return user_out.to_mongo().to_dict()
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")
        
def add_user_logins(user: PUserPutIn, id: str):
    try: 
        user_out = User.objects(id=id).get()
        users = User.objects().filter(external_logins__match={"type": user.external_login.type, "id": user.external_login.id})
        if not users: 
            new_logins = ExtLogin(id=user.external_login.id, refresh_token=user.external_login.refresh_token, 
                                    username=user.external_login.username, email=user.external_login.email, 
                                    type=user.external_login.type, access_token=user.external_login.access_token,
                                    access_token_secret=user.external_login.access_token_secret)
            user_out.external_logins.append(new_logins)
            user_out.save()
            return user_out.to_mongo().to_dict()
        return None
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")


def update_user_logins(newToken: str, id: str):
    try: 
        user = User.objects(id=id).get()
        veggie = [x for x in user.external_logins if x.type == "VeggieCrush"][0]
        veggie.refresh_token = newToken
        user.save()
        return user.to_mongo().to_dict()
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")

def update_user_password(passwords: PUserChangePass, id: str):
    try: 
        user_obj = User.objects(id=id).first()
        if not checkpw(passwords.old_password.encode(), user_obj.password.encode()):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                                detail="Could not validate credentials")
        new_password = hash_password(passwords.new_password.encode())
        user_obj.password = new_password.decode()
        user_obj.save()
        return {"INFO": "Password modified"}
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Error during processing. Refer to a developer.")


def delete_user(id: str) -> dict[str, str]:
    try:
        User.objects(id=id).delete()
        return {"INFO": "User deleted"}
    except:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="Invalid id")

