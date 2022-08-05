import uvicorn
import os

from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, Request

abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)

from routers import users, perms, players, bases, villages, items
from config.parameters import (
    # ALLOWED_HOSTS, 
    ORIGINS, 
    KEY_FILE, 
    CERT_FILE, 
    PORT, 
    HOST_IP, 
    ALLOWED_METHODS, 
    # DB_URL
)


app = FastAPI()

"""
# Database Initialisation
"""
import database.db_init


"""
# API & Routers Initialisation
"""

app.include_router(perms.router)
app.include_router(bases.router)
app.include_router(items.router)
app.include_router(users.router)
app.include_router(players.router)
app.include_router(villages.router)


@app.get("/")
def root():
    return {"Welcome": 
            "You can access API documentation through /docs"}


"""
# Middleware Initialisation
"""
# app.add_middleware(HTTPSRedirectMiddleware)
app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts="*",
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=ORIGINS,
    allow_credentials=True,
    allow_methods=ALLOWED_METHODS,
    allow_headers=["*"],
)


@app.middleware("http")
async def request_validator(request: Request, call_next):
    # We can filter either request or response 
    # before there are processed by the routers
    response = await call_next(request)
    return response


"""
# Main
"""
if __name__ == "__main__":
    uvicorn.run("main:app", host=HOST_IP, 
                            port=PORT, 
                            reload=True,
                            # ssl_keyfile= KEY_FILE,
                            # ssl_certfile= CERT_FILE
                            )
