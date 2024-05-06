## Readme

### Huggingface auto upload tool
- hf-sync.slurm
- upload_latest_checkpoint.py<br>
.bashrcにexport HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxして使ってください

```
sbatch hf-sync.slurm
```

### Huggingface manual upload tool
- upload_checkpoint_manual.py
```
upload_checkpoint_manual.py 3000
```
- upload_checkpoint_manual.sh<br>
multiple manual upload

### Disk monitoring tool
- fs-watchdog.slurm
- bg_monitor_fs.sh<br>
backgroundでたくさん起動させてしまわないよう注意<br>
topコマンドでkillする

