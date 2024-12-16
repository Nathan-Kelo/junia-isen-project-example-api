import os
from unittest.mock import patch

import pytest

@pytest.fixture
def mongo_url():
  with patch.dict(os.environ,{"MONGO_URL":"mongodb://localhost:27017"}) as mock:
    yield mock

@pytest.fixture
def client(mongo_url):
    from api.app import app
    app.testing = True
    with app.test_client() as client:
        yield client

def test_home(client):
    response = client.get("/")
    assert response.status_code == 200
