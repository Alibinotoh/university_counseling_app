import os
from neo4j import GraphDatabase
from dotenv import load_dotenv

load_dotenv()

URI = os.getenv("NEO4J_URI")
USER = os.getenv("NEO4J_USERNAME")
PWD = os.getenv("NEO4J_PASSWORD")

# Create the driver instance
driver = GraphDatabase.driver(URI, auth=(USER, PWD))

# This helper function is optional but good for testing
def get_db():
    return driver