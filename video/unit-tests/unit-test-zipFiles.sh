#!/usr/bin/bash

# This unit test script should be run from the unit-tests folder!

cd zipFiles
cd dv
zipFiles.sh dv
if [ -e 20090411100503-episode.dv ]; then
    echo "DV test has passed!"
    rm 20090411100503-episode.dv
fi

cd ../avi

zipFiles.sh avi

if [ -e 20090411100503-episode.avi ]; then
    echo "AVI test has passed!"
    rm 20090411100503-episode.avi
fi

cd ../mkv

zipFiles.sh mkv
if [ -e 20090411100503-episode.mkv ]; then
    echo "MKV test has passed!"
    rm 20090411100503-episode.mkv
fi
