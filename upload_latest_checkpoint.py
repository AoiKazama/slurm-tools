#!/usr/bin/env python

# Copyright 2024 AoiKazama
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


import os
import sys
import json
import requests
import hashlib
from huggingface_hub import HfApi

def send_message(slack_webhook_url, log_message, config):
    payload = {
        "channel": config["slack_channel"],
        "username": config["slack_botname"],
        "text": log_message,
        "icon_emoji": config["slack_icon"]
    }
    response = requests.post(slack_webhook_url, json=payload)
    print(f"Slack response: {response.text}")

def file_md5(filename, slack_webhook_url, config):
    hash_md5 = hashlib.md5()
    try:
        with open(filename, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
    except FileNotFoundError:
        error_message = f"Failed to open the file: {filename} - File not found."
        send_message(slack_webhook_url, error_message, config)
        raise
    return hash_md5.hexdigest()

def upload_latest_checkpoint(config):
    hf_token = config["hf_token"]
    user = config["hf_user"]
    repo_name = config["repo_name"]
    repo_type = config["repo_type"]
    checkpoint_dir = config["checkpoint_path"]
    slack_notification = config["slack_notification"]
    slack_webhook_url = config["slack_webhook_url"]
    
    if not hf_token:
        if slack_notification:
            messege = f"Hugging Face API token is not set in HF_TOKEN environment variable."
            send_message(slack_webhook_url, message, config)
        raise ValueError("Hugging Face API token is not set in HF_TOKEN environment variable.")

    api = HfApi()
    repo_url = f"{user}/{repo_name}"

    try:
        api.repo_info(repo_url)
    except Exception as e:
        api.create_repo(repo_name, token=hf_token, private=True)
        print(f"Creating a new repository: {repo_name}")

    latest_file_path = os.path.join(checkpoint_dir, "latest")
    current_md5 = file_md5(latest_file_path, slack_webhook_url, config)
    md5_file_path = os.path.join(os.path.expanduser("~"), "latest.md5")

    print("current_md5: " + current_md5)
    if os.path.exists(md5_file_path):
        with open(md5_file_path, 'r') as f:
            previous_md5 = f.read().strip()
    else:
        previous_md5 = ""
        print("MD5 file not found. A new file will be created.")

    if previous_md5 == current_md5:
        print("No changes in 'latest' file. Skipping upload.")
        with open(md5_file_path, 'w') as f:
            f.write(current_md5)
            print("No new checkpoint found. Skipping upload.")
        return
    else:
        print("Changes detected. Proceeding with upload.")
        with open(md5_file_path, 'w') as f:
            f.write(current_md5)

    with open(latest_file_path, 'r') as file:
        latest_checkpoint = file.read().strip()

    if not os.path.exists(latest_file_path):
        message = f"{latest_file_path} does not exist."
        if slack_notification:
            send_message(slack_webhook_url, message, config)
        raise FileNotFoundError(message)

    checkpoint_path = os.path.join(checkpoint_dir, latest_checkpoint)
    if not os.path.exists(checkpoint_path) and os.path.exists(md5_file_path):
        message = f"{checkpoint_path} does not exist."
        if slack_notification:
            send_message(slack_webhook_url, message, config)
        raise FileNotFoundError(message)

    try:
        print(f"Uploading {latest_checkpoint} to {repo_name}")
        api.upload_folder(
            folder_path=checkpoint_path,
            repo_id=repo_url,
            repo_type=repo_type,
            token=hf_token,
            commit_message=f"Upload {latest_checkpoint}"
        )
    except Exception as e:
        message = f"Failed to upload {latest_checkpoint} to {repo_name}: {str(e)}"
        if slack_notification:
            send_message(slack_webhook_url, message, config)
        raise e

    log_message = f"Successfully uploaded {latest_checkpoint} to {repo_name}."
    print(log_message)
    if slack_notification:
        send_message(slack_webhook_url, log_message, config)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python /path/to/upload_latest_checkpoint.py '<json_data>'")
        sys.exit(1)

    json_str = sys.argv[1]
    config = json.loads(json_str)
    
    upload_latest_checkpoint(config)
