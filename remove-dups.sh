#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <source directory> <cleanup directory>"
    exit 1
fi

# check if folders exist
if [ ! -d $1 ]; then
    echo "Source directory does not exist: $1"
    exit 1
fi

if [ ! -d $2 ]; then
    echo "Cleanup directory does not exist: $2"
    exit 1
fi

SOURCE_DIR="$1"
CLEANUP_DIR="$2"

# remove duplicates from cleanup directory
echo "Removing duplicates from cleanup directory: $CLEANUP_DIR"
fdupes -r -d -N $CLEANUP_DIR &&

# wait for user prompt to continue
read -p "Press enter to continue" &&

# remove files from cleanup directory that are duplicates of files in source directory
echo "Removing files from cleanup directory that are duplicates of files in source directory: $SOURCE_DIR" &&
fdupes -r "$SOURCE_DIR" "$CLEANUP_DIR" | grep -v "$SOURCE_DIR" | grep -v '^$' > fdupes 
DUPLICATES=$(wc -l fdupes | awk '{print $1}')
echo "Number of duplicates found: $DUPLICATES" 

read -p "Press enter to continue" &&

if [ $DUPLICATES -gt 0 ]; then
    xargs -d '\n' rm -v < fdupes &&
    rm fdupes &&
    find $CLEANUP_DIR -type d -empty -delete
else
    echo "No duplicates found"
    rm fdupes
fi
