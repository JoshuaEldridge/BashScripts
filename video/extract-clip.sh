#!/usr/bin/bash

if ! command -v ffmpeg &>/dev/null ; then
  echo "This script requires mp4tag to run! Please install and try again."
  exit
fi

FILE_BASENAME="${1%.*}"
CHAPTER="${2}"

if [ -z "$1" ]
  then 
    echo "Nothing to do! This script expects a source file to be passed in."
    exit 1
fi

if [ -z "$2" ]
  then 
    CHAPTER="00"
fi


ffmpeg \
-ss 00:12:50 \
-to 00:13:05 \
-i "$1" \
-c:a copy \
-c:v copy \
"$FILE_BASENAME-$CHAPTER".mkv 

#-ss 00:15:07 \
#-to 00:45:35 \
