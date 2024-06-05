#!/usr/bin/bash

shopt -s extglob

if ! command -v mediainfo &>/dev/null ; then
  echo "This script requires MediaInfo to run! Please install and try again."
  exit
fi

function friendlyRename () {
# Input: this function expects TITLE and DATE variables to passed into the first and second positions
# Output: a single string that can be used as a file name where spaces are converted to periods (.) and special characters are removed and a timestamp is converted to a simple date.
# Description: Takes the friendly title and convert it into a file name that's consistenly formatted to the following: Beatrice.Rides.the.Scrambler.2009-06-13.mp4
# Media files will be stored in folders by year, so leading with the Title (rather than the date) should help with finding and sorting videos more quickly.

  TITLE_PART="$1"
  # Handle multiple spaces, tabs, etc
  TITLE_PART=${TITLE_PART//+([[:space:]])/ }
  # Remove commas, single and double quotes (can add others)
  TITLE_PART=${TITLE_PART//[\'\",!\(\)\.]/}
  # Replace special characters with a space (can add others)
  TITLE_PART=${TITLE_PART//[-&+]/ }
  # Replace remaining spaces with periods
  TITLE_PART=${TITLE_PART//[^[:alnum:]]/\.}
  DATE_PART=${2:0:14}
  echo $DATE_PART-$TITLE_PART
}



if [ "$1" != "Prod" ] && [ "$1" != "Test" ] ; then 

  echo "This simple utility will rename files based on an existing standard (DATE-FRIENDLY_NAME) using existing metadata from the files."
  echo "CAUTION: If the files haven't been tagged properly with Title and Date attributes, resulting files will be incorrect."
  echo "To run this script in preview mode against all mp4 files in this directory, use the following command:"
  echo "$0 Test"
  echo "Once confirmed, run $0 Prod"

  exit
fi


for f in `ls *.mp4`
  do
    FTITLE=$(mediainfo --Output="General;%Title%" "$f")
    if [ "$1" = "Prod" ]; then
      MOVE_FILE=$(friendlyRename "$FTITLE" "$f")
      mv "$f" "$MOVE_FILE.mp4"
    fi
    if [ "$1" = "Test" ]; then
      echo $f
      echo $FDATE
      friendlyRename "$FTITLE" "$f"
      echo ""
    fi
  done