#!/usr/bin/bash

# Given a raw input file that contains a DV stream, this
# script will generate DVRescue metadata and technical data,
# create an archive-ready native dv stream file, and split 
# the stream into episode groups for curation.

# Check that EXIFTool is in the path, otherwise the script will fail


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

function unpackageDV() {
# Input: DV Filename (not sure if the container really matters, tested with mov)
# Convert files from proreitary Apple (*.mov) container back to original DV
# Capture the output and rename the resulting DV file with the same base name
# as the original mov file.
    file_base=`getFileBasename "${1}"`
    unpackaged=`dvpackager -u "${1}"`
    # dvpackager only outputs the following string, so need to parse out the resulting dv file name.
    # Unpackaging mode. Unpackaging the input files into unpackaged_2ef69183-ee53-42be-a442-c273064999df.dv.
    trimmed=`echo $unpackaged | sed -e 's,^.* ,,'`
    unpackaged_file=${trimmed:0:-1}
    dv="$file_base.dv"
    mv "$unpackaged_file" "$dv"
    echo $dv
}

function rescueDV() {
# Input: DV File
# Generate Technical Subtitles and XML
    dvrescue  "${1}" -s ${1}.dvrescue.techsubs.vtt
}

function packageDV() {
# Input: DV File
    dir_name=`getFileBasename "${1}"`
    if [ ! -d $dir_name ]; then
        mkdir -p $dir_name;
    fi
    dvpackager -Z -d -e dv -v -o "${dir_name}" "${1}"
    #mv "${1}" "$dir_name/${1}"
    rm -rf /tmp/dvpackager.*
}

function renameDV() {
    exiftool "-FileName<DateTimeOriginal" -d "%Y%m%d%H%M%S%%c.%%le" *_part*
}

original_input_file="${1}"

dir_name=`getFileBasename "${1}"`

#dv_filename=`unpackageDV "${original_input_file}"`

#rescueDV $dv_filename

#packageDV $dv_filename

packageDV "$1"

cd $dir_name

renameDV

GAP=$((60*90))

previous_timestamp=0
for x in $(ls -1 *.dv | sort) ; do
    oldfolder=$(dirname $x)
    echo "Old Folder is: " $oldfolder
    file=$(basename $x)
    # dvgrab-2011.02.12_19-04-58.dv
    echo "File is: " $file
    year=${file:0:4}
    mon=${file:4:2}
    day=${file:6:2}
    hour=${file:8:2}
    min=${file:10:2}
    sec=${file:12:2}
    timestamp=$(date +%s -d "$year-$mon-$day $hour:$min:$sec")
    echo "Timestamp is: " $timestamp
    if [[ $(( $timestamp - $previous_timestamp )) -gt $GAP ]] ; then
        newfolder=$(date "+%Y-%m-%d_%H-%M-%S" -d "@$timestamp")
        mkdir $newfolder
    fi
    mv -v "$x" "$newfolder/$file"
    previous_timestamp=$timestamp
done

cd ..

#mv "${dv_filename}" "${dv_filename}".dvrescue.techsubs.vtt "${dir_name}"/.
mv "${dv_filename}" "${dir_name}"/.


