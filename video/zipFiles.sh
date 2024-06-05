#!/usr/bin/bash

# This script is meant to be run in a folder of similar video file formats
# and handles: native dv streams, mkv files and avi properly. It will sort them
# by name and concatenate them together using the name of the first file as the base
# and append "-episode" to the end. This simplifies the process of concatenating files
# in time order (if they are named in a standard way), as well as using the correct
# method for joining files based on the file format.

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

function join_by {
  # split a bash array by a single or multi-character delimiter
  # join_by , a b c #a,b,c
  # join_by ' , ' a b c #a , b , c
  # join_by ')|(' a b c #a)|(b)|(c
  # join_by ' %s ' a b c #a %s b %s c 
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

if [[ $# -eq 0 ]]; then
    echo "This script requires at least one argument with a value of: dv, mkv or avi"
    exit 1
fi

EXT="*."$1

first_file=$(ls -1 $EXT | sort | head -1)
input_files=""
base=`getFileBasename $first_file`
ext=`getFileExtension $first_file`
output_file="${base}-episode.${ext}"

case $EXT in
  *.dv)
    echo "Passed: " $1 "Found: " $EXT
    for f in $(ls -1 $EXT | sort)
    do
        input_files="${input_files} $f"
    done
    echo $input_files
    cat $input_files > $output_file
    ;;
  *.mkv)
    if ! command -v mkvmerge &>/dev/null ; then
      echo "This function requires mkvmerge to run! Please install and try again."
      exit
    fi
    for f in $(ls -1 $EXT | sort)
    do
        input_files="${input_files} $f"
    done
    echo $input_files
    mkvmerge -o $output_file '[' $input_files ']'  
    ;;
  *.avi)
    if ! command -v ffmpeg &>/dev/null ; then
      echo "This function requires ffmpeg to run! Please install and try again."
      exit
    fi
    first_loop="True"
    for f in $(ls -1 $EXT | sort)
    do
      if [ $first_loop == "True" ]; then
        input_files="$f"
        first_loop="False"
      else
        input_files="$input_files $f"
      fi
    done
    ffmpeg_input=`join_by '|' $input_files`
    echo $ffmpeg_input
    ffmpeg -i "concat:$ffmpeg_input" -c copy $output_file
    ;;
  *)
    echo "This script requires a value of: dv, mkv or avi"
    echo $1
    exit 1
  ;;
esac
