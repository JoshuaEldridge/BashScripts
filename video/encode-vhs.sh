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
    # For VHS captured at 720x486 (Intensity Pro): removes overscan lines for a cleaner digital file and scales
    # to 640x480 for proper 4:3 aspect ratio. Adds slight increase in Gamma/Saturation for richer color.
    CRF_QUALITY=18
    FF_PRESET="medium"
    AUDIO_BITRATE="192k"
    VIDEO_FILTERS="bwdif=1:1:0,crop=704:470:8:8,scale=640:480:interl=1,eq=gamma=1.1:saturation=1.5"

    ;;
  DV)
    CRF_QUALITY=18
    FF_PRESET="medium"
    AUDIO_BITRATE="256k"
    VIDEO_FILTERS="bwdif=1:1:0,eq=gamma=1.1:saturation=1.5"

    ;;
  *)
    CRF_QUALITY=20
    FF_PRESET="fast"
    AUDIO_BITRATE="192k"
    VIDEO_FILTERS="bwdif=1:-1:0"
	;;
esac

function createFriendlyFileName () {
# Description: This function takes the friendly title and converts it into a file name that's consistenly formatted to remove spaces and special characters.
# Usage: createFriendlyFileName "$TEST_STRING" "$TEST_DATE"
# Input: this function expects TITLE and DATE variables to passed into the first and second positions. 
# Output: a single string that can be used as a file name where spaces are converted to periods (.) and special characters are removed and a timestamp is converted to a simple date. Example output: 2009-06-13.Beatrice.Rides.the.Scrambler.mp4
	if [ $# -eq 0 ]; then
		echo "createFriendlyFileName requires at least one argument (file name)"
		exit
	fi

	TITLE_PART="$1"
	# Handle multiple spaces, tabs, etc
	TITLE_PART=${TITLE_PART//+([[:space:]])/ }
	# Remove commas, single and double quotes (can add others)
	TITLE_PART=${TITLE_PART//[\'\",)(!]/}
	# Replace special characters with a space (can add others)
	TITLE_PART=${TITLE_PART//[-&+]/ }
	# Replace remaining spaces with periods
	TITLE_PART=${TITLE_PART//[^[:alnum:]]/\.}
	if [ -z "$2" ]; then
		echo $TITLE_PART
	else
		# Remove dashes and colons
		#DATE_PART=${2//[-: ]/}
		DATE_PART=${2:0:10}
		echo $DATE_PART.$TITLE_PART
	fi
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
	-aspect 4:3 \
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
	  -ss ${START_TIME} \
		-to ${END_TIME} \
		-c:v libx264 -x264-params ref=4 \
		-c:a aac -b:a $AUDIO_BITRATE -ac 2 \
		-pix_fmt yuv420p \
		-aspect 4:3 \
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
	-aspect 4:3 \
	-vf "$VIDEO_FILTERS" \
	-preset "$FF_PRESET" \
	-crf $CRF_QUALITY \
	-movflags +faststart \
	-write_tmcd 0 \
	"$FILE_BASENAME".mp4
fi

