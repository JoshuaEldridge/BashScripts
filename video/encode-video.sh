#!/usr/bin/bash

# This file will take a raw/lossless file captured from VHS and produce
# an optimized MP4 file for Plex and other players.
# It will look for a local metadata file with the same name as the input
# file base name, but with a .metadata extension
# Example: if the source file is named Lossless-VHS-Capture-03.FFV1.mkv
# the script will look for a metadata file named Lossless-VHS-Capture-03.FFV1.metadata

# Example Usage: encode-vhs.sh Lossless-VHS-Capture-03.FFV1.mkv
# Additional Options/Presets for Encoding: encode-vhs.sh Lossless-VHS-Capture-03.FFV1.mkv VHS

# In order to create a short clip with a different name from a file, a third argument with the
# name of the .metadata file can be passed.
# Example encode-vhs.sh Lossless-VHS-Capture-03.FFV1.mkv VHS short_clip.metadata

if ! command -v ffmpeg &>/dev/null ; then
  echo "This script requires ffmpeg to run! Please install and try again."
  exit
fi

shopt -s extglob
TEST_STRING="Beatrice-Ride's the+Scrambler,     (at) the Parish&Picnic!"
TEST_DATE="2009-06-13 10:18:52"

case $2 in
  HH)
    ASPECT_RATIO="16:9"
    CRF_QUALITY=18
    FF_PRESET="medium"
    AUDIO_BITRATE="256k"
    #VIDEO_FILTERS="bwdif=0:-1:1"
    # This hqdn3d filter worked really well for dark, pixelated footage from handheld
    VIDEO_FILTERS="bwdif=0:-1:1,hqdn3d=4:5:4:4"
    #VIDEO_FILTERS="bwdif=0:-1:1,hqdn3d=4:5:4:4,transpose=2"
    ;;
  VHS)
    # For VHS captured at 720x486 (Intensity Pro): removes overscan lines for a cleaner digital file and scales
    # to 640x480 for proper 4:3 aspect ratio. Adds increases in Gamma/Saturation for richer color.
    ASPECT_RATIO="4:3"
    CRF_QUALITY=18
    FF_PRESET="veryfast"
    AUDIO_BITRATE="192k"
    #VIDEO_FILTERS="bwdif=1:1:0,crop=704:470:8:8,scale=640:480:interl=1,eq=gamma=1.1:saturation=1.5"
    #VIDEO_FILTERS="bwdif=1:1:0,crop=704:470:8:8,scale=640:480:interl=1,pp=ac"
    VIDEO_FILTERS="bwdif=1:1:0,crop=704:470:8:8,scale=640:480:interl=1,hqdn3d=4:5:4:4"
    #VIDEO_FILTERS="bwdif=1:1:0,crop=704:470:8:8,scale=640:480:interl=1"
    #VIDEO_FILTERS="bwdif=1:1:0,crop=704:470:8:8,scale=640:480:interl=1,atadenoise,hqdn3d=4,unsharp=7:7:0.5"
    ;;
  DV)
    ASPECT_RATIO="4:3"
    CRF_QUALITY=18
    FF_PRESET="medium"
    AUDIO_BITRATE="256k"
    VIDEO_FILTERS="bwdif=1:1:0,eq=gamma=1.1:saturation=1.5"
    ;;
  *)
    ASPECT_RATIO="16:9"
    CRF_QUALITY=22
    FF_PRESET="fast"
    AUDIO_BITRATE="192k"
    VIDEO_FILTERS="bwdif=1:-1:0"
	;;
esac

function createFriendlyFileName () {
# Description: This function takes the friendly title and converts it into a file name that's consistenly formatted to remove
# spaces and special characters.
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
	# Characters to completely remove (can add others)
	TITLE_PART=${TITLE_PART//[\'\"\,\!\(\)]/}
	# Special characters to replace with a space (can add others)
	TITLE_PART=${TITLE_PART//[-&+]/ }
	# Replace remaining spaces with periods
	TITLE_PART=${TITLE_PART//[^[:alnum:]]/\.}
	if [ -z "$2" ]; then
		echo $TITLE_PART
	else
		# Remove dashes and colons
		DATE_PART=${2//[-: ]/}
		DATE_PART=${DATE_PART:0:14}
		echo $DATE_PART-$TITLE_PART
	fi
}

function getReelFromPWD() {
	# This function sets the variable reel number to the name of the parent folder or "reel".
  #PARENT=$(dirname "$PWD")
  #REEL_NUMBER=$(basename "$PARENT")
  REEL_NAME=$(basename "$PWD")
  echo $REEL_NAME
}

function zipMKV() {
# This function is meant to be run in a folder of native mkv streams. 
# IMPORTANT: It requires mkvtoolnix to be installed!
# It will sort them by name and concatenate them together using the 
# name of the first file as the base.

	if ! command -v mkvmerge &>/dev/null ; then
	  echo "This function requires mkvmerge to run! Please install and try again."
	  exit
	fi

  first_file=$(ls -1 *.mkv | sort | head -1)
  input_files=""
  for f in $(ls -1 *.mkv | sort)
  do
      input_files="${input_files} $f"
  done
  base=`getFileBasename $first_file`
  ext=`getFileExtension $first_file`
  output_file="${base}-episode.${ext}"
  mkvmerge -o $output_file '[' $input_files ']'  
  #echo "$input_files"
  #exit;
}

METADATA="False"

#getReelFromPWD

FILE_BASENAME="${1%.*}"

if [ -z "$3" ]; then
	if [ -f "$FILE_BASENAME.metadata" ]; then
	  source "$FILE_BASENAME.metadata"
	  METADATA="True"
	fi
else
	source "$3"
	METADATA="True"
fi

echo $FILE_BASENAME
if [ $METADATA == "True" ]; then
	if [ -z $FRIENDLY_FILE_NAME ]; then
  	FRIENDLY_FILE_NAME=$(createFriendlyFileName "$EPISODE_TITLE" "$MD_DATE")
  	echo "Encoding file with name: " $FRIENDLY_FILE_NAME.mp4
  fi
  if [ -z ${END_TIME} ]; then
		ffmpeg -i "$1" \
		-c:v libx264 -x264-params ref=4 \
		-c:a aac -b:a $AUDIO_BITRATE -ac 2 \
		-pix_fmt yuv420p \
		-aspect $ASPECT_RATIO \
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
			-aspect $ASPECT_RATIO \
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
	-aspect $ASPECT_RATIO \
	-vf "$VIDEO_FILTERS" \
	-preset "$FF_PRESET" \
	-crf $CRF_QUALITY \
	-movflags +faststart \
	-write_tmcd 0 \
	"$FILE_BASENAME".mp4
fi

