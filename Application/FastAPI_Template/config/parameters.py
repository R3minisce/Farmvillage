from fastapi.security import OAuth2PasswordBearer


"""
# API & HTTPS Parameters
"""
HOST_IP = "0.0.0.0"
# HOST_IP ="192.168.1.60"
PORT = 8000
KEY_FILE = "config/key.pem"
CERT_FILE = "config/cert.pem"
#GAME_ENGINE_IP ="http://127.0.0.1:3001"
GAME_ENGINE_IP ="http://prod_game_engine_1:3001"

"""
# Database Parameters
"""
#DB_IP = "192.113.50.2"
DB_IP = "mongodb_FarmVillage_prod"
#DB_PORT = "21002"
DB_PORT ="27017"
DB_COLLECTION = "test"
DB_URL = f"mongodb://{DB_IP}:{DB_PORT}/{DB_COLLECTION}"


"""
# Regex Policies
"""
PASSWORD_POLICY = r'^.*$'
# PASSWORD_POLICY = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{12,}$'
EMAIL_POLICY = r'^.+\@.+\..+$'


"""
# JWT Parameters
"""
ALGORITHM = "RS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 365.25
PRIV_KEY = open('config/priv_key.pem', 'r').read()
PUB_KEY = open('config/pub_key.pub', 'r').read()


"""
# OAuth2 Initialisation, Permissions
"""
OAUTH2_SCHEME = OAuth2PasswordBearer(
    tokenUrl="login",
    scopes={"user": "Token for personnal access",
            "admin": "Token for admin access"
            }
)


"""
# CORS & Middleware Parameters
"""
ALLOWED_HOSTS = ["127.0.0.1", "localhost","*"]
ALLOWED_METHODS = ["GET", "PUT", "POST", "DELETE"]
ORIGINS = [
    # "http://127.0.0.1:8000",
    # "http://localhost:8000",
    "*"
]
