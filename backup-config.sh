#!/bin/bash

DATE=$(date +%Y-%m-%d)
TIME=$(date +%s)

BACKUP_DIR="configs-backup"
TODAYS_BACKUP_DIR=$HOME/$BACKUP_DIR/$DATE

BACKUPS=( plex media-center )

echo "Saving Archive To: " $TODAYS_BACKUP_DIR

mkdir -p $TODAYS_BACKUP_DIR

#To backup user's home directory
for dir in "${BACKUPS[@]}"
do
  cd $HOME/$dir
  for sdir in `ls -d */`
  do
    FRIENDLY_NAME=${sdir:0:${#sdir}-1}
    echo "Archiving: " $dir/$sdir
    tar -zcvpf $TODAYS_BACKUP_DIR/$FRIENDLY_NAME-$TIME.tar.gz --exclude='plex/Library/Application Support/Plex Media Server/Cache' --exclude='transmission/downloads' $sdir 
  done
done
