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

#SBATCH --job-name=hfupload
#SBATCH --partition=x0
#SBATCH --nodelist=your-node
#SBATCH --gpus-per-node=0
#SBATCH --time=06:00:00
#SBATCH --output=upload_checkpoint_manual-%j.out
#SBATCH --error=upload_checkpoint_manual-%j.err


start_step=1200
end_step=3000
save_interval=600

for step in $(seq $start_step $save_interval $end_step)
do
    python /path/to/upload_checkpoint_manual.py $step
done

print("Upload complete!")
