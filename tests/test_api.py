import os
import sys

import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "app"))
from main import MemoryStore, create_app  # noqa: E402


class BrokenStore(MemoryStore):
    def ping(self):
        return False


@pytest.fixture
def client():
    return create_app(MemoryStore()).test_client()


def test_healthz(client):
    assert client.get("/healthz").json == {"status": "ok"}


def test_readyz_ok(client):
    assert client.get("/readyz").status_code == 200


def test_readyz_fails_when_db_down():
    assert create_app(BrokenStore()).test_client().get("/readyz").status_code == 503


def test_create_and_list(client):
    r = client.post("/operations", json={"title": "restart cache", "owner": "ali"})
    assert r.status_code == 201
    assert client.get("/operations").json[0]["title"] == "restart cache"


def test_rejects_missing_fields(client):
    assert client.post("/operations", json={"title": "x"}).status_code == 400


def test_metrics_exposed(client):
    client.get("/healthz")
    assert b"http_requests_total" in client.get("/metrics").data


def test_version_endpoint(client):
    assert "version" in client.get("/version").json


@pytest.mark.skipif(os.getenv("INTENTIONAL_FAILURE") != "1", reason="only used to prove the CI gate")
def test_intentional_failure():
    assert False, "intentional failure: CI must block deployment"
