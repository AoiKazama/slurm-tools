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

#SBATCH --job-name=fs-watchdog
#SBATCH --partition=x0
#SBATCH --nodelist=your-node
#SBATCH --gpus-per-node=0
#SBATCH --output=fs-watchdog-%j.out
#SBATCH --error=fs-watchdog-%j.err
#SBATCH --time=20-24:00:00
#SBATCH --requeue

SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
filesystem=/storageX
interval=$((24 * 60 * 60))

# check filesystem exist or not
if [ ! -d "$filesystem" ]; then
  echo "Error: Filesystem '$filesystem' does not exist."
  exit 1
fi

end_time=$(date +%s --date='3 weeks')

while [ $(date +%s) -lt $end_time ]; do
  fs_data=$(df -h | grep "$filesystem")
  if [ -z "$fs_data" ]; then
    echo "Error: Unable to get data for $filesystem."
    exit 1
  fi
  total=$(echo "$fs_data" | awk '{print $2}')
  used=$(echo "$fs_data" | awk '{print $3}')
  available=$(echo "$fs_data" | awk '{print $4}')
  usep=$(echo "$fs_data" | awk '{print $5}')
  jst_time=$(TZ='Asia/Tokyo' date +'%Y-%m-%d %H:%M:%S')
  log_message="Daily Report - $jst_time:\n$filesystem Total: $total, Used: $used, Available: $available, Use%: $usep"
  payload="payload={\"channel\": \"#notification\", \"username\": \"fs watchdog\", \"text\": \"$log_message\", \"icon_emoji\": \":dog:\"}"
  curl -X POST --data-urlencode "$payload" $SLACK_WEBHOOK_URL
  sleep $interval
done
