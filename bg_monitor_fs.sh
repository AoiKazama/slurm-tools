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


# SlackのWebhook URL
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"

filesystem=/storageX

interval=21600

end_time=$(( SECONDS + 7 * 24 * 3600 ))

(
while [ $SECONDS -lt $end_time ]; do
  fs_data=$(df -h | grep "$filesystem")
  total=$(echo $fs_data | awk '{print $2}')
  used=$(echo $fs_data | awk '{print $3}')
  available=$(echo $fs_data | awk '{print $4}')
  usep=$(echo $fs_data | awk '{print $5}')

  jst_time=$(date -u --date='9 hours' +'%Y-%m-%d %H:%M:%S')
  
  log_message="Daily Report - $jst_time:\n$filesystem Total: $total, Used: $used, Available: $available, Use%: $usep"

  # Slac notificationk
  payload="payload={\"channel\": \"#your-channel\", \"username\": \"fs watchdog\", \"text\": \"$log_message\", \"icon_emoji\": \":hotdog:\"}"
  curl -X POST --data-urlencode "$payload" $SLACK_WEBHOOK_URL
  
  sleep $interval
done

echo "Monitoring job completed."
) &

echo "Monitoring script is running in the background."

