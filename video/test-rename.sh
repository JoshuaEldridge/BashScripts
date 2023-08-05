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
  DATE_PART=${2//[-: ]/}
  DATE_PART=${DATE_PART:0:14}
  echo $DATE_PART-$TITLE_PART
}


EPISODE_TITLE="Austin's Birthday Care Package from Oma and Opa"
MD_DATE="2005-09-09 16:56:45.000"

#friendlyRename "$EPISODE_TITLE" "$MD_DATE"

for f in `ls *.mp4`; do
  if [ ${f:0:8} = "20010323" ]; then
    DESC=$(mediainfo --Output="General;%Description%" "$f")
    TITLE=$(mediainfo --Output="General;%Title%" "$f")
    echo $f $TITLE $DESC
    echo $DESC | cut -d" " -f14
  fi
done


# for f in `ls *.mp4`; do
#   echo "$f"
#   echo "${f:0:4}"
# done