#!/usr/bin/bash

# This file will take a raw/lossless file captured from VHS and produce
# an optimized MP4 file for Plex and other players.
# It will look for a local metadata file with the same name as the input
# file base name, but with a .metadata extension
# Example: if the source file is named Lossless-VHS-Capture-03.FFV1.mkv
# the script will look for a metadata file named Lossless-VHS-Capture-03.FFV1.metadata

# Example Usage: encode-vhs.sh Lossless-VHS-Capture-03.FFV1.mkv
# Additional Options/Presets for Encoding: encode-vhs.sh Lossless-VHS-Capture-03.FFV1.mkv VHS


shopt -s extglob
TEST_STRING="Beatrice-Ride's the+Scrambler,     at the Parish&Picnic"
TEST_DATE="2009-06-13 10:18:52"

case $2 in
  HH)
    CRF_QUALITY=20
    FF_PRESET="medium"
    AUDIO_BITRATE="192k"
    VIDEO_FILTERS="bwdif=0:-1:1"

    ;;
  VHS)
    CRF_QUALITY=18
    FF_PRESET="medium"
    AUDIO_BITRATE="192k"
    VIDEO_FILTERS="bwdif=1:1:0,eq=gamma=1.1:saturation=1.5"

    ;;
  DV)
    CRF_QUALITY=18
    FF_PRESET="medium"
    AUDIO_BITRATE="256k"
    VIDEO_FILTERS="bwdif=1:1:0,eq=gamma=1.1:saturation=1.5"

    ;;
  *)
    CRF_QUALITY=18
    FF_PRESET="medium"
    AUDIO_BITRATE="256k"
    
  ;;
esac

#Top Field First
#VHS_VIDEO_FILTERS="bwdif=1:0:0,crop=720:480-10:0:5"
#Bottom Field First
#VIDEO_FILTERS="bwdif=1:1:0,eq=gamma=1.1:saturation=1.5"
#VHS_VIDEO_FILTERS="bwdif=1:1:0,crop=720-10:480-16:5:8,fps=29.97"
#VHS_VIDEO_FILTERS="bwdif=1:1:0,hqdn3d=10,pp=al,crop=720-10:480-16:5:8,fps=29.97"
#VHS_VIDEO_FILTERS="bwdif=1:1:0,hqdn3d=5,pp=al,fillborders=left=10:right=10:top=10:bottom=10:mode=fixed"
#VHS_VIDEO_FILTERS="bwdif=1:1:0,eq=gamma=1:saturation=1,hqdn3d=2,fillborders=left=20:right=5:top=5:bottom=15:mode=fixed"
#VHS_VIDEO_FILTERS="bwdif=1:1:0,eq=gamma=1.1:saturation=1.2,hqdn3d=2.5,crop=690:460:20:5"
#VHS_VIDEO_FILTERS="bwdif=1:1:0,pp=al,hqdn3d=2,fillborders=left=20:right=5:top=5:bottom=15:mode=fixed"

# Stub: Function that will take the friendly title and conver it into a file name that's consistenly formatted to the following: Beatrice.Rides.the.Scrambler.2009-06-13.mp4
# Media files will be stored in folders by year, so leading with the Title (rather than the date) should help with finding and sorting videos more quickly.

function createFriendlyFileName () {
# Input: this function expects TITLE and DATE variables to passed into the first and second positions
# Output: a single string that can be used as a file name where spaces are converted to periods (.) and special characters are removed and a timestamp is converted to a simple date.

	TITLE_PART="$1"
	# Handle multiple spaces, tabs, etc
	TITLE_PART=${TITLE_PART//+([[:space:]])/ }
	# Remove commas, single and double quotes (can add others)
	TITLE_PART=${TITLE_PART//[\'\",]/}
	# Replace special characters with a space (can add others)
	TITLE_PART=${TITLE_PART//[-&+]/ }
	# Replace remaining spaces with periods
	TITLE_PART=${TITLE_PART//[^[:alnum:]]/\.}
	DATE_PART=${2:0:10}
	echo $TITLE_PART.$DATE_PART
}


METADATA="False"

FILE_BASENAME="${1%.*}"

if [ -f "$FILE_BASENAME.metadata" ]; then
  source "$FILE_BASENAME.metadata"
  METADATA="True"
fi

if [ $METADATA == "True" ]; then
  FRIENDLY_FILE_NAME=$(createFriendlyFileName "$EPISODE_TITLE" "$MD_DATE")
  echo "Encoding file with name: " $FRIENDLY_FILE_NAME.mp4
  if [ -z ${END_TIME} ]; then
	ffmpeg -i "$1" \
	-c:v libx264 -x264-params ref=4 \
	-c:a aac -b:a $AUDIO_BITRATE -ac 2 \
	-pix_fmt yuv420p \
	-vf "$VIDEO_FILTERS" \
	-preset "$FF_PRESET" \
	-crf $CRF_QUALITY \
	-movflags +faststart \
	-write_tmcd 0 \
	-metadata CREATION_TIME="$MD_DATE" \
	-metadata DESCRIPTION="$DESCRIPTION" \
	-metadata TITLE="$EPISODE_TITLE" \
	-metadata GENRE="$GENRE" \
	-metadata DATE="$MD_DATE" \
	"$FRIENDLY_FILE_NAME".mp4
  else
  	ffmpeg -i "$1" \
  	-ss "$START_TIME" \
	-to "$END_TIME" \
	-c:v libx264 -x264-params ref=4 \  		
	-c:a aac -b:a $AUDIO_BITRATE -ac 2 \
	-pix_fmt yuv420p \
	-vf "$VIDEO_FILTERS" \
	-preset "$FF_PRESET" \
	-crf $CRF_QUALITY \
	-movflags +faststart \
	-write_tmcd 0 \
	-metadata CREATION_TIME="$MD_DATE" \
	-metadata DESCRIPTION="$DESCRIPTION" \
	-metadata TITLE="$EPISODE_TITLE" \
	-metadata GENRE="$GENRE" \
	-metadata DATE="$MD_DATE" \
	"$FRIENDLY_FILE_NAME".mp4
  fi
else
	ffmpeg -i "$1" \
	-c:v libx264 -x264-params ref=4 \
	-c:a aac -b:a $AUDIO_BITRATE -ac 2 \
	-pix_fmt yuv420p \
	-vf "$VIDEO_FILTERS" \
	-preset "$FF_PRESET" \
	-crf $CRF_QUALITY \
	-movflags +faststart \
	-write_tmcd 0 \
	"$FILE_BASENAME".mp4
fi

