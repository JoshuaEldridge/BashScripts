#!/home/josh/Documents/Code/virtualenv/sortphotos/bin/python3

# EXIF Date tags respected by PhotoPrism
# DateTimeOriginal, CreationDate, CreateDate, MediaCreateDate, ContentCreateDate, DateTimeDigitized, DateTime, SubSecDateTimeOriginal, SubSecCreateDate

# DateTimeOriginal
# DateTime
# CreateDate
# Make = "Sony
# Model = "Digital Mavica FD73"
# exiftool "-DateTimeOriginal="2024:03:15 19:23:00" 19991011063000.jpg
# exiftool -if 'not $exif:DateTimeOriginal' "-datetimeoriginal<filename" "-datetime<filename" "-createdate<filename" dir

# exiftool "-datetimeoriginal<filename" "-datetime<filename" "-createdate<filename" .
# exiftool -if 'not $exif:DateTimeOriginal' "-datetimeoriginal<filename" "-datetime<filename" "-createdate<filename" .
# exiftool -if '$DateTimeOriginal eq "0000:00:00 00:00:00"' "-datetimeoriginal<filename" "-datetime<filename" "-createdate<filename" -directory=updated-files .
# exiftool -if '(not $DateTimeOriginal or $DateTimeOriginal eq "0000:00:00 00:00:00")' "-datetimeoriginal<filename" "-datetime<filename" "-createdate<filename" .
# exiftool -if '(not $DateTimeOriginal or $DateTimeOriginal eq "0000:00:00 00:00:00")' -directory=orphans .
# Renaming Files from EXIF
# exiftool "-FileName<DateTimeOriginal" -d "%Y%m%d%H%M%S.%%le" "-Directory<DateTimeOriginal" -d "/home/josh/Pictures/iCloud-Renamed/%Y/%m"
# exiftool -F "-FileName<FileModifyDate" -d "%Y%m%d%H%M%S.%%le" .

# exiftool "-DateTimeOriginal=2006:08:23 12:52:31"
# Fishing.jpg
#exiftool "-datetimeoriginal<filename" "-datetime<filename" "-createdate<filename" 20060823125231.jpg

# Show all of the time/date tags on a photo
# exiftool -time:all -a -G0:1 -s yourfile.jpg

# Remove all Tags from an image (helpful for PSDs)
# exiftool -all:all= -r yourfile.jpg

# Working on files recursively, while keeping them in their respective directories helps in certain cases (batch operations are much more efficient)
#find . -type f -iname "*.heic" -printf '%p' -exec exiftool "-FileName<DateTimeOriginal" -d "%Y%m%d%H%M%S%+c.%%le" {} \;

# LIVE VIDEOS (Creation Date)
# find . -type f -iname "*_HEVC.MOV" -printf '%p' -exec exiftool "-FileName<CreationDate" -d "%Y%m%d%H%M%S%+c_HEVC.%%le" {} \;


from exiftool import ExifToolHelper
import os

def convertFileNameToDateTime(file_name):
	return f'{file_name[0:4]}:{file_name[4:6]}:{file_name[6:8]} {file_name[8:10]}:{file_name[10:12]}:{file_name[12:14]}'

sourceDir="/home/josh/Pictures/Photo-Archive/1999/10"

print(f"Files in the directory: {sourceDir}")

files = os.listdir(sourceDir)
fiels = [f for f in files if os.path.isfile(sourceDir+'/'+f)] #Filtering only the files.
print(*files, sep="\n")

for f in files:
	print('Original File Name: ' + f)
	date_string = convertFileNameToDateTime(f)
	print(f'Date String: {date_string}')

# with ExifToolHelper() as et:
# 	for d in et.get_tags(files, tags=['DateTimeOriginal']):
# 		for k, v in d.items():
# 			if 'EXIF:DateTimeOriginal' not in d:
# 				print('No EXIF Date Detected ' + d[k])
# 			else:
# 				print('Found! ' + d[k])
# 			#print(f"Dict: {k} = {v}")