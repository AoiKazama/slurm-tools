#!/bin/bash

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

#SBATCH --job-name=hf-sync
#SBATCH --partition=x0
#SBATCH --nodelist=your-node
#SBATCH --gpus-per-node=0
#SBATCH --time=20-00:00:00
#SBATCH --output=hf-sync-%j.out
#SBATCH --error=hf-sync-%j.err
#SBATCH --requeue

json_data="{
    \"hf_token\": \"$HF_TOKEN\",
    \"hf_user\": \"HF-Organization\",
    \"repo_name\": \"your-model\",
    \"repo_type\": \"model\",
    \"checkpoint_path\": \"/storageX/path/to/training-model\",
    \"slack_notification\": false,
    \"slack_webhook_url\": \"https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX\",
    \"slack_channel\": \"#your-channel\",
    \"slack_botname\": \"HF Sync\",
    \"slack_icon\": \":hugging_face:\"
}"

# Terminate the process after 10 days
end_time=$((SECONDS + 10 * 24 * 3600))

# Check for a new checkpoint every 10 minutes
while [ $SECONDS -lt $end_time ]
do
    python /path/to/upload_latest_checkpoint.py "$json_data"
    sleep 600
done
