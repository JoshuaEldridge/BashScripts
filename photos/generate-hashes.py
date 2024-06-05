#!/home/josh/Documents/Code/virtualenv/sortphotos/bin/python

# Generate SHA512 hashes for a directory of image files.

import time
import hashlib
import os
from os import path
import argparse
import photohashing as ph

start = time.time()
parser = argparse.ArgumentParser(
                    prog = path.basename(__file__),
                    description = 'This program generates and stores a set of file hashes and provides an interface for checking files against the hash set.',
                    epilog = 'Useful for checking for duplicate photos.')
parser.add_argument('-d', '--startdir', default = os.getcwd(), help='Pass the directory you wish to recursively scan to generate the hash set. Default is the current working directory. Requires a target file for writing.')
parser.add_argument('-o', '--outfile', default = 'Photo-Hash-Digest.txt', help='Writable file for storing file hashes.')

args = parser.parse_args()

total_hash_count = 0
file_name = path.join(args.startdir, args.outfile)

# CREATING HASH FILE

for (root,dirs,files) in os.walk(args.startdir, topdown=True):
    #print (root)
    #print (dirs)
    #print (files)
    if len(files) > 0:
        file_hashes = ph.generate_hashes_from_directory(root)
        print(f'Hashed {len(file_hashes)} Files')
        ph.write_hashes_file(file_name, file_hashes)
        print(f'Wrote {len(file_hashes)} Hashes to {file_name}')
        total_hash_count += len(file_hashes)

print(f"Hashed {total_hash_count} Files")
end = time.time()
execution_time = (end - start) * 10**3
print(f"Program execution time is: {execution_time} in milliseconds")
