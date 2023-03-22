from src.secret_manager.delete_entry import delete_entry
from src.secret_manager.list_entries import list_secrets
import boto3
import ast
from moto import mock_secretsmanager
import pytest
import os


@pytest.fixture(scope="function")
def aws_credentials():
    """Mocked AWS Credentials for moto."""
    os.environ["AWS_ACCESS_KEY_ID"] = "testing"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
    os.environ["AWS_SECURITY_TOKEN"] = "testing"
    os.environ["AWS_SESSION_TOKEN"] = "testing"
    os.environ["AWS_DEFAULT_REGION"] = "us-east-1"


@mock_secretsmanager
def test_delete_entry(aws_credentials):
    client = boto3.client('secretsmanager')
    client.create_secret(
        Name="test1",
        SecretString='{"user_id": "user1", "password": "password1"}'
    )
    client.create_secret(
        Name="test2",
        SecretString='{"user_id": "user2", "password": "password2"}'
    )
    client.create_secret(
        Name="test3",
        SecretString='{"user_id": "user3", "password": "password3"}'
    )

    delete_entry("test2")

    expected = list_secrets()
    assert expected == ["test1", "test3"]
