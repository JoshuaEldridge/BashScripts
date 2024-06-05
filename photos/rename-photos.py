#!/home/josh/Documents/Code/virtualenv/sortphotos/bin/python3

import os
from os import path
import sys

# name_of_script = sys.argv[0]

if len(sys.argv) > 1:
    source_dir = sys.argv[1]
else:
    source_dir = ''

cwd = os.getcwd()
current_dir = path.join(cwd, source_dir)
print(current_dir)

file_list = os.listdir(current_dir)

def truncate_and_rename(file, increment=1):
    file_name, file_ext = path.splitext(file)
    start = file_name[0:13]
    renamed = start + str(increment) + file_ext
    return renamed

#print(original_file_list)
for f in file_list:
    if "_" in f:
        increment = 1
        renamed = truncate_and_rename(f, increment)
        while (path.exists(path.join(current_dir, renamed))):
            increment += 1
            renamed = truncate_and_rename(f, increment)

        os.rename(path.join(current_dir, f), path.join(current_dir, renamed))