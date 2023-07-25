#!/usr/bin/bash

if ! command -v mp4tag &>/dev/null ; then
  echo "This script requires mp4tag to run! Please install and try again."
  exit
fi

if ! command -v exiftool &>/dev/null ; then
  echo "This script requires EXIFTool to run! Please install and try again."
  exit
fi

METADATA="False"

FILE_BASENAME="${1%.*}"

if [ -f "$FILE_BASENAME.metadata" ]; then
  source "$FILE_BASENAME.metadata"
  METADATA="True"
else
  echo "This script requires a local metadata file with the same name as the file to be tagged."
  echo "20071027165030-episode.mp4 needs a corresponding file named 20071027165030-episode.metadata with the following variables set:"
  echo ""
  echo '    EPISODE_TITLE="Baby Ballerina Flowers and Fairies Recital"'
  echo '    MD_DATE="2007-06-23 09:45:00.000"'
  echo '    GENRE="Home Video Archive"'
  echo '    ARCHIVE=DV'
  echo "    A DESCRIPTION field is optional, and if not included one will be generated automatically."
  echo ""
  echo "Example Usage: $0 20071027165030-episode.mp4"
  echo ""
  exit
fi

EXIF_DATE=`echo ${MD_DATE:0:19} | sed "s/-/:/g"`
SIMPLE_DATE=`date -d "$MD_DATE" '+%A %B %e, %Y'`
FRIENDLY_FULL_DATE=`date -d "$MD_DATE" '+%A %B %e, %Y at %-I:%M%P'`

if [ -z $DESCRIPTION ]; then
  DESCRIPTION="This video was originally captured on $FRIENDLY_FULL_DATE. Archive: $ARCHIVE"
fi

set -o nounset

function tag_video () {
    INFILE="$1"
    OUTFILE="TAGGED-$INFILE"
    mp4tag --set Name:S:"$EPISODE_TITLE" \
    --set Title:S:"$EPISODE_TITLE" \
    --set Description:S:"$DESCRIPTION" \
    --set Date:S:"$MD_DATE" \
    --set GenreName:S:"$GENRE" \
    $INFILE $OUTFILE
    mv $OUTFILE $INFILE
    RM_FILE="$INFILE"_original
    exiftool "-datetimeoriginal=$EXIF_DATE" "-datetime=$EXIF_DATE" "-createdate=$EXIF_DATE" "-mediacreatedate=$EXIF_DATE" "-trackcreatedate=$EXIF_DATE" $INFILE
    if [ -f $RM_FILE ]; then
      #echo $RM_FILE
      rm $RM_FILE
    fi
}

tag_video "$1"