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
from huggingface_hub import HfApi

def upload_checkpoint(step):
    # set in .bashrc -- export HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxxxx
    hf_token = os.environ['HF_TOKEN']
    # or set "hf write token"
    # こちらを使う場合はこのスクリプトを共有フォルダではなく自分のhome(~/)内の適当な場所にコピーして実行してください
    #hf_token = "hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    api = HfApi()
    
    folder_path = f"/storageX/path/to/checkpoint/model/global_step{step}"
    repo_id = "your-huggingface-organization/model_repo"
    commit_message = f"Upload global_step{step}"
    
    if not os.path.exists(folder_path):
        print(f"Error: The folder {folder_path} does not exist.")
        return
    
    api.upload_folder(
        folder_path=folder_path,
        repo_id=repo_id,
        repo_type="model",
        token=hf_token,
        commit_message=commit_message
    )
    print(f"Successfully uploaded global_step{step}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python /path/to/upload_checkpoint_manual.py <step>")
        sys.exit(1)

    step = sys.argv[1]
    upload_checkpoint(step)
