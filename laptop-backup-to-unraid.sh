#!/usr/bin/bash

# This will back up XPS-13 laptop files to Unraid

# Make sure the mount point exists (using /tmp)

mountpoint -q /home/josh/mounted/Dell-XPS13 || sudo mount -t nfs 192.168.1.239:/mnt/user/synology-nas/Computer-Backups/Dell-XPS13/ /home/josh/mounted/Dell-XPS13

rsync -rav --no-perms --no-group --no-owner \
    --include {'.ssh/, .aws/'} \
    --exclude '.*/' \
    --exclude ffmpeg_build \
    --exclude ffmpeg_sources \
    --exclude AppImages \
    --exclude snap \
    --exclude "Soulseek Chat Logs" \
    --exclude Templates \
    --exclude mounted \
    /home/josh/ /home/josh/mounted/Dell-XPS13/

# rsync -rav --no-perms --no-group --no-owner \
#  --exclude .cache \
#  --exclude .config \
#  --exclude .cups \
#  --exclude .dvdcss \
#  --exclude .SoulseekQt \
#  --exclude .MakeMKV \
#  --exclude .restic \
#  --exclude .thunderbird \
#  --exclude .vscode \
#  --exclude .pyicloud \
#  --exclude .putty \
#  --exclude .platformio \
#  --exclude .gnupg \
#  --exclude .gphoto \
#  --exclude .mozilla \
#  --exclude .pki \
#  --exclude ffmpeg_build \
#  --exclude ffmpeg_sources \
#  --exclude Resilio \
#  --exclude "Soulseek Chat Logs" \
#  --exclude .local \
#  /home/josh/ /home/josh/mounted/Dell-XPS13/
