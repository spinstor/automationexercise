"""Robot Framework variablefile that sources login credentials from MongoDB.

Load this with Robot Framework by passing:

    robot --variablefile config/mongo_login.py tests  ...

It connects to ONE MongoDB server and reads the first ENABLED document from
the "users" collection. The document is expected to look like:

    {
        "email":    "sofia@example.com",     # required  -> ${LOGIN_EMAIL}
        "password": "Passw0rd!123",          # required  -> ${LOGIN_PASSWORD}
        "name":     "Sofia",                 # optional  -> ${LOGIN_NAME}
        "enabled":  true                     # optional, must be truthy
    }

The variables injected into Robot are:
    ${LOGIN_EMAIL}     the stored email
    ${LOGIN_PASSWORD}  the stored password
    ${LOGIN_NAME}      the stored display name (falls back to email prefix)

When MongoDB is unreachable or has no enabled user, NO variables are injected
and a warning is printed: suites that need Mongo can then fail fast with a
clear message, while suites with a non-Mongo fallback keep working.

Connection settings come from environment variables (defaults shown):

    MONGO_URI         mongodb://localhost:27017/
    MONGO_DB          robot_auth
    MONGO_COLLECTION  users
"""

import os
import sys

try:
    import pymongo
except ImportError as exc:  # pragma: no cover - clear failure for humans
    raise SystemExit(
        "PyMongo is not installed. Run: python -m pip install pymongo"
    ) from exc

MONGO_URI = os.environ.get("MONGO_URI", "mongodb://localhost:27017/")
MONGO_DB = os.environ.get("MONGO_DB", "robot_auth")
MONGO_COLLECTION = os.environ.get("MONGO_COLLECTION", "users")


def _fetch_active_credentials():
    """Returns the first enabled user document from MongoDB, or None."""
    client = pymongo.MongoClient(MONGO_URI, serverSelectionTimeoutMS=5000)
    try:
        collection = client[MONGO_DB][MONGO_COLLECTION]
        document = collection.find_one({"enabled": True})
        if document is None:
            print(
                "No enabled user found in {0}.{1}. Seed one with: "
                "python scripts/seed_mongo.py --email you@example.com "
                "--password 'Passw0rd!123' --name 'Sofia'".format(
                    MONGO_DB, MONGO_COLLECTION
                )
            )
        return document
    except pymongo.errors.PyMongoError as exc:
        print(
            "WARNING: MongoDB unreachable ({0}) - suites using ${{LOGIN_*}} "
            "will fall back to generated credentials.".format(exc)
        )
        return None
    finally:
        client.close()


def get_variables(*args, **kwargs):
    """Robot Framework entry point: returns a dict of scalar variables."""
    document = _fetch_active_credentials()
    if not document:
        return {}
    email = document["email"]
    name = document.get("name") or email.split("@", 1)[0]
    print("MongoDB credentials loaded from {0}.{1}: {2} <{3}>".format(
        MONGO_DB, MONGO_COLLECTION, name, email
    ))
    return {
        "LOGIN_EMAIL": email,
        "LOGIN_PASSWORD": document["password"],
        "LOGIN_NAME": name,
    }