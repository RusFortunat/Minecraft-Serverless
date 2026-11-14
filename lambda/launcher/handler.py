"""Launcher Lambda.

Triggered by a CloudWatch Logs subscription on the Route 53 query log.
When someone resolves the server hostname, scale the ECS service to 1.
"""
import os

import boto3

CLUSTER = os.environ["CLUSTER"]
SERVICE = os.environ["SERVICE"]
REGION = os.environ["SERVER_REGION"]

ecs = boto3.client("ecs", region_name=REGION)


def handler(event, context):
    svc = ecs.describe_services(cluster=CLUSTER, services=[SERVICE])["services"][0]
    if svc["desiredCount"] == 0:
        ecs.update_service(cluster=CLUSTER, service=SERVICE, desiredCount=1)
        return {"status": "starting"}
    return {"status": "already running"}
