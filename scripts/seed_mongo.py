#!/usr/bin/env python
"""Seed and inspect the MongoDB users collection used by the Robot tests.

The framework reads the first enabled document of "robot_auth.users" as the
login credentials for the Mongo-driven login suite. This script manages those
documents:

Examples:
    python scripts/seed_mongo.py --email sofia@example.com --password 'Passw0rd!123' --name Sofia
    python scripts/seed_mongo.py --list
    python scripts/seed_mongo.py --disable --email sofia@example.com
    python scripts/seed_mongo.py --delete --email sofia@example.com

Connection settings come from environment variables (defaults shown):

    MONGO_URI         mongodb://localhost:27017/
    MONGO_DB          robot_auth
    MONGO_COLLECTION  users
"""

import argparse
import os
import sys

try:
    import pymongo
except ImportError as exc:
    raise SystemExit("PyMongo is not installed. Run: python -m pip install pymongo") from exc

MONGO_URI = os.environ.get("MONGO_URI", "mongodb://localhost:27017/")
MONGO_DB = os.environ.get("MONGO_DB", "robot_auth")
MONGO_COLLECTION = os.environ.get("MONGO_COLLECTION", "users")


def get_collection():
    client = pymongo.MongoClient(MONGO_URI, serverSelectionTimeoutMS=5000)
    return client[MONGO_DB][MONGO_COLLECTION], client


def cmd_seed(args):
    collection, client = get_collection()
    try:
        document = {
            "email": args.email,
            "password": args.password,
            "name": args.name or args.email.split("@", 1)[0],
            "enabled": True,
        }
        result = collection.update_one(
            {"email": args.email}, {"$set": document}, upsert=True
        )
        message = "updated" if result.upserted_id is None else "inserted"
        print("%s document into %s.%s" % (message, MONGO_DB, MONGO_COLLECTION))
        print("Enabled login credentials: %s / %s" % (document["email"], document["password"]))
    finally:
        client.close()


def cmd_list(args):
    collection, client = get_collection()
    try:
        documents = list(collection.find({}).sort("email", 1))
        if not documents:
            print("Collection %s.%s is empty." % (MONGO_DB, MONGO_COLLECTION))
            return
        for doc in documents:
            print("- {enabled!s:5} {email} / {password}  ({name})".format(
                enabled=doc.get("enabled", True),
                email=doc["email"],
                password=doc["password"],
                name=doc.get("name", ""),
            ))
    finally:
        client.close()


def cmd_change_enabled(args, enabled):
    collection, client = get_collection()
    try:
        result = collection.update_one(
            {"email": args.email}, {"$set": {"enabled": enabled}}
        )
        if result.matched_count == 0:
            print("No document found for email %s" % args.email)
        else:
            print("%s %s (enabled=%s)" % (args.email, "enabled" if enabled else "disabled", enabled))
    finally:
        client.close()


def cmd_delete(args):
    collection, client = get_collection()
    try:
        result = collection.delete_one({"email": args.email})
        print("Deleted %d document(s) for email %s" % (result.deleted_count, args.email))
    finally:
        client.close()


def main():
    parser = argparse.ArgumentParser(description="Manage Robot login credentials in MongoDB")
    sub = parser.add_subparsers(dest="command")

    p_seed = sub.add_parser("seed", help="Insert or update an enabled login account")
    p_seed.add_argument("--email", required=True)
    p_seed.add_argument("--password", required=True)
    p_seed.add_argument("--name", default="")
    p_seed.set_defaults(func=cmd_seed)

    p_list = sub.add_parser("list", help="List all stored accounts")
    p_list.set_defaults(func=cmd_list)

    p_disable = sub.add_parser("disable", help="Disable an account so it is not used")
    p_disable.add_argument("--email", required=True)
    p_disable.set_defaults(func=lambda a: cmd_change_enabled(a, False))

    p_enable = sub.add_parser("enable", help="Re-enable an account")
    p_enable.add_argument("--email", required=True)
    p_enable.set_defaults(func=lambda a: cmd_change_enabled(a, True))

    p_delete = sub.add_parser("delete", help="Delete an account")
    p_delete.add_argument("--email", required=True)
    p_delete.set_defaults(func=cmd_delete)

    args = parser.parse_args()
    if not hasattr(args, "func"):
        parser.print_help()
        sys.exit(1)

    try:
        args.func(args)
    except pymongo.errors.PyMongoError as exc:
        print(
            "MongoDB connection failed: {0}".format(exc),
            file=sys.stderr,
        )
        print(
            "Is a MongoDB server running at {0}? See README (MongoDB connections).".format(MONGO_URI),
            file=sys.stderr,
        )
        sys.exit(2)


if __name__ == "__main__":
    main()