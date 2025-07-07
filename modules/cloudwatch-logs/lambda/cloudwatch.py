# Posts events from EventBridge to a CloudWatch log group.

import time
import boto3
import os
import logging
import json
import re

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()
default_log_stream = "default"
logs = boto3.client("logs")


def ensure_log_stream_exists(log_group, log_stream):
    """
    Ensures that the specified log stream exists in the log group.
    Creates it if it does not exist.
    """
    try:
        logs.create_log_stream(logGroupName=log_group, logStreamName=log_stream)
    except logs.exceptions.ResourceAlreadyExistsException:
        pass


def extract_host_from_url(url):
    """
    Extracts the host from a URL string.
    """
    regex = r"^https?://([^/,^\:]+)"
    match = re.search(regex, url)
    if match:
        return match.group(1)
    return None


def main(event, context):
    logger.info("Received event!")

    check_run_event = event.get("detail")
    logger.info("Check run event: %s", json.dumps(check_run_event, indent=2))

    if not check_run_event:
        logger.error("No detail found in the event.")
        return

    log_group_name = os.environ.get("LOG_GROUP_NAME")
    if not log_group_name:
        logger.error("LOG_GROUP_NAME environment variable is not set.")
        return

    logger.info("Processing event for log group: %s", log_group_name)

    try:
        check_run_url = check_run_event.get("check_run_url", "")
        anomalo_instance = extract_host_from_url(check_run_url)

        if not anomalo_instance:
            log_stream = default_log_stream
            logger.warning("Could not extract Anomalo instance from event, using default log stream.")
        else:
            log_stream = anomalo_instance

        logger.info("Using log stream: %s", log_stream)

        ensure_log_stream_exists(log_group_name, log_stream)

        response = logs.put_log_events(
            logGroupName=log_group_name,
            logStreamName=log_stream,
            logEvents=[
                {
                    "timestamp": int(time.time() * 1000),
                    "message": json.dumps(check_run_event)
                }
            ]
        )
        logger.info("Successfully posted event to CloudWatch Logs: %s", response)

    except Exception as e:
        logger.error("Error posting event to CloudWatch Logs: %s", e, exc_info=True)
