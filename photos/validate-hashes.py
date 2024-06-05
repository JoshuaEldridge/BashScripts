#!/home/josh/Documents/Code/virtualenv/sortphotos/bin/python

# Generate SHA512 hashes for a directory of image files.
# Compare timing for sha256sum vs. openssl 

import time
import hashlib
import os
from os import path
import argparse
import photohashing as ph

start = time.time()

file_scan_counter = 0
file_found_counter = 0
parser = argparse.ArgumentParser(
                    prog = path.basename(__file__),
                    description = 'This program generates and stores a set of file hashes and provides an interface for checking files against the hash set.',
                    epilog = 'Useful for checking for duplicate photos.')
parser.add_argument('-d', '--directory_to_validate', default = os.getcwd(), help='Pass the directory of files you wish to validate against the hash set. If no directory is passed, this will defaul to the current working directory')
parser.add_argument('-f', '--file_with_hashes', required = True, help='File containing the full hash set for comparison.')
parser.add_argument('-s', '--single_file', help='Check whether a single file exists in the hash set.')
parser.add_argument('-t', '--test_only', action = 'store_true', help='This only applies to the full directory scan -- if you wish to only have the digest printed (and take no action).')
parser.add_argument('-r', '--recursive_scan', action = 'store_true', help='Recursively validate all files in subdirectories.')


args = parser.parse_args()

# CHECKING FILE HASHES
hashes_set = ph.read_hashes_file(args.file_with_hashes)
hash_set_size = len(hashes_set)

if args.single_file:
    single_file_hash = ph.calculate_file_hash(args.single_file)
    if single_file_hash in hashes_set:
        print(f"DUPLICATE: The file {args.single_file} was found in the hash set.")
    else:
        print(f"UNIQUE: The file {args.single_file} was NOT found in the hash set.")
        print(single_file_hash)
        # ADD TO THE HASH SET
        answer = input("Write unique hashes to hash set? [No]")
        if answer.lower() in ["y", "yes"]:
            ph.write_hashes_file(args.file_with_hashes, [single_file_hash])
    exit()

dir_to_scan = path.join(os.getcwd(),args.directory_to_validate)

if args.test_only is True:
    print("Running in TEST mode, no files will be moved ...")

if args.recursive_scan is True:
    total_file_count = 0
    originals = []
    print("Recursively Scanning ...")
    for p, d, f in os.walk(dir_to_scan):
        total_file_count += len(f)

    for root, dirs, files in os.walk(".", topdown=False):
        
        for name in files:
            full_file = path.join(root,name)
            this_file_hash = ph.calculate_file_hash(full_file)
            #print(this_file_hash)
            file_scan_counter += 1
            print(f'Files Scanned: {file_scan_counter} of {total_file_count}', end='\r')
            if this_file_hash not in hashes_set:
                #print(f'Unique File Found: {full_file} with {this_file_hash}')
                print(f'Unique File Found: {full_file}')
                originals.append(full_file)
                #print(f'This file is a duplicate: {f} with {this_file_hash}')
                file_found_counter += 1
            else:
                # Don't actually move duplicate files if we're only testing ...
                if not args.test_only is True:
                    duplicate_dir = path.join(dir_to_scan, 'duplicates')
                    print("Duplicate Dir: " + duplicate_dir)
                    if not path.isdir(duplicate_dir):
                        os.mkdir(duplicate_dir)
                    print(dir_to_scan, duplicate_dir, name)
                    os.rename(path.join(dir_to_scan, full_file), path.join(duplicate_dir, name))

    if len(originals) > 0:
        for o in originals:
            print(o)
else: 
    os.chdir(dir_to_scan)
    for f in os.listdir(dir_to_scan):
        if os.path.isfile(path.join(dir_to_scan, f)):
            this_file_hash = ph.calculate_file_hash(path.join(dir_to_scan, f))
            #print(this_file_hash)
            file_scan_counter += 1
            print(f'Files Scanned: {file_scan_counter}', end='\r')
            if this_file_hash not in hashes_set:
                #print(f'Unique File Found: {f} with {this_file_hash}')
                print(f'Unique File Found: {f}')
                #print(f'This file is a duplicate: {f} with {this_file_hash}')
                file_found_counter += 1
            else:
                if not args.test_only is True:
                    duplicate_dir = path.join(dir_to_scan, 'duplicates')
                    if not path.isdir(duplicate_dir):
                        os.mkdir(duplicate_dir)

                    os.rename(path.join(dir_to_scan, f), path.join(duplicate_dir, f))

print(f"Number of Files Checked: {file_scan_counter}")
print(f"Number of Original Files Found: {file_found_counter}")
print(f"Total Hash Set Size: {hash_set_size}")

end = time.time()
execution_time = (end - start) * 10**3
print(f"Program execution time is: {execution_time} in milliseconds")