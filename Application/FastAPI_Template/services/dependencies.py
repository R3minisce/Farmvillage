import bcrypt

"""
# Class Dependencies
"""
def setattrs(_self, **kwargs):
    for k, v in kwargs.items():
        setattr(_self, k, v)


"""
# Methods Dependencies
"""
def hash_password(password: str):
    return bcrypt.hashpw(password, bcrypt.gensalt())


def check_password(plain_text_password, hashed_password):
    return bcrypt.checkpw(plain_text_password, hashed_password)