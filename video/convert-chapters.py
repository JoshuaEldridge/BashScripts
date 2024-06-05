#!/home/josh/Documents/Code/virtualenv/sortphotos/bin/python

# https://ikyle.me/blog/2020/add-mp4-chapters-ffmpeg
# Extract Metadata From Video:
# ffmpeg -i 20010823112013-episode.mp4 -f ffmetadata FFMETADATAFILE
# ;FFMETADATA1
# major_brand=isom
# minor_version=512
# compatible_brands=isomiso2avc1mp41
# description=This video was originally captured on Thursday August 23, 2001 at 11:20am. Archive: Reel-1021-02
# title=Goofy Skits in Indianapolis
# date=2001-08-23 11:20:13.000
# genre=Home Video Archive
# encoder=Lavf59.36.100

# Example Chapters.txt File:
# 0:23:20 Start
# 0:40:30 First Performance
# 0:40:56 Break
# 1:04:44 Second Performance
# 1:24:45 Crowd Shots
# 1:27:45 Credits

# Add Chapters to the FFMETADATAFILE:
# [CHAPTER]
# TIMEBASE=1/1000
# START=1
# END=448000
# title=The Pledge

# Write Metadata to the File:
# ffmpeg -i 20010823112013-episode.mp4  -i FFMETADATAFILE -map_metadata 1 -codec copy 20010823112013-episode-chapters.mp4


import re

chapters = list()

with open('chapters.txt', 'r') as f:
   for line in f:
      x = re.match("(\d{2}):(\d{2}):(\d{2}) (.*)", line)
      hrs = int(x.group(1))
      mins = int(x.group(2))
      secs = int(x.group(3))
      title = x.group(4)

      minutes = (hrs * 60) + mins
      seconds = secs + (minutes * 60)
      timestamp = (seconds * 1000)
      chap = {
         "title": title,
         "startTime": timestamp
      }
      chapters.append(chap)

text = ""

for i in range(len(chapters)-1):
   chap = chapters[i]
   title = chap['title']
   start = chap['startTime']
   end = chapters[i+1]['startTime']-1
   text += f"""
[CHAPTER]
TIMEBASE=1/1000
START={start}
END={end}
title={title}
"""


with open("FFMETADATAFILE", "a") as myfile:
    myfile.write(text)