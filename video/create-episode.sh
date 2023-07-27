#!/usr/bin/bash

# Example for running for every subdirectory:
# for dir in */; do cd $dir; ../../create-episode.sh; cd ..; done

# for f in *.mkv
# do
#   FILE_DATE_NAME=$(mediainfo --Output="General;%DATE_RECORDED%" $f | sed 's/-//g;s/://g;s/ //g')
#   mv "$f" "$FILE_DATE_NAME".mkv
# done

function readEpisodeTitle() {
    TITLE_FILE="Episode-Title.txt"
    if [ -e "$TITLE_FILE" ]
    then
        EPISODE_TITLE=$(cat "$TITLE_FILE")
    else
        EPISODE_TITLE=""
    fi
    echo "$EPISODE_TITLE"
}

function getReelFromPWD() {
    PARENT=$(dirname "$PWD")
    REEL_NUMBER=$(basename "$PARENT")
    echo $REEL_NUMBER
}

function getFileExtension () {
case $1 in
  (.*.*) extension=${1##*.};;
  (.*)   extension="";;
  (*.*)  extension=${1##*.};;
  (*)    extension="";;
esac
  echo $extension
}

function getFileBasename () {
  echo "${1%.*}"
}

function zipDV() {
# This function is meant to be run in a folder of native dv streams.
# It will sort them by name and concatenate them together using the 
# name of the first file as the base.
    first_file=$(ls -1 *.dv | sort | head -1)
    input_files=""
    for f in $(ls -1 *.dv | sort)
    do
        input_files="${input_files} $f"
    done
    base=`getFileBasename $first_file`
    ext=`getFileExtension $first_file`
    output_file="${base}-episode.${ext}"
    cat $input_files > $output_file
    echo $output_file
}

function createHashFile() 
{
    outfile=${PWD##*/}
    for f in $(ls -1 *.dv | sort)
    do
        sha512sum -b "$f" >> "${outfile}"-SHA512-Hashes.txt
    done
}

function validateHashesFromFile() 
{
    outfile=${PWD##*/}
    sha512sum -c "${outfile}"-SHA512-Hashes.txt
}

EPISODE_TITLE=$(readEpisodeTitle)

if [ -z "$EPISODE_TITLE" ]
then
    read -p 'Enter the title for this episode:' EPISODE_TITLE
    echo "You entered this for the Episode Title: $EPISODE_TITLE"

    while true; do
        read -p "Proceed?" yesno
        case $yesno in
            [Yy]* ) 
                echo "Proceeding .."
                break
                ;;
            [Nn]* ) 
                echo "Exiting .."
                exit
                ;;
            * ) echo "Answer either yes or no!";;
        esac
    done
fi

REEL_NUMBER=$(getReelFromPWD)

#createHashFile

f=`zipDV`

#f="20041217205109-episode.dv"

FILE_BASENAME="${f%.*}"

MD_DATE=$(mediainfo --Output="General;%Recorded_Date%" $f)
# Date Format: 2009-02-16 10:47:28.000
#PLEX_YEAR=${MD_DATE:0:10}
FRIENDLY_DATE=`date -d "${MD_DATE}" '+%A %B %e, %Y at %-I:%M%P'`
DESCRIPTION="This video was originally captured on ${FRIENDLY_DATE}. Archive: $REEL_NUMBER"

ffmpeg -i "$f" \
-c:a aac -b:a 192k -ac 2 \
-c:v libx264 -x264-params ref=4 \
-pix_fmt yuv420p \
-vf bwdif=1:1:0 \
-preset medium \
-crf 18 \
-movflags +faststart \
-write_tmcd 0 \
-metadata CREATION_TIME="${MD_DATE}" \
-metadata DESCRIPTION="${DESCRIPTION}" \
-metadata TITLE="${EPISODE_TITLE}" \
-metadata GENRE="Home Video Archive" \
-metadata DATE="${MD_DATE}" \
"../${FILE_BASENAME}".mp4

#dvpackager -e mkv $f
#20041218081724-episode_part1.mkv
#mv "$FILE_BASENAME"_part1.mkv "../$FILE_BASENAME".mkv
