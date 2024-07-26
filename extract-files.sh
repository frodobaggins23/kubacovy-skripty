#!/bin/bash

# Assign script parameters to variables
while getopts "s:d:t:D" opt; do
    case $opt in
        s)
            source_folder=$OPTARG
            ;;
        d)
            dest_folder=$OPTARG
            ;;
        t)
            file_group=$OPTARG
            ;;
        D)
            delete_file=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

# Check if any of the parameters is missing
if [ -z "$source_folder" ] || [ -z "$dest_folder" ] || [ -z "$file_group" ]; then
    echo "Usage: $0 -s <source_folder> -d <dest_folder> -t <file_group>"
    exit 1
fi

# Check if source folder exists
if [ ! -d "$source_folder" ]; then
    echo "Source folder does not exist: $source_folder"
    exit 1
fi

# Create destination folder if it does not exist
mkdir -p "$dest_folder"

# Define file extensions based on file group selection
case $file_group in
    image)
        file_extensions=("jpg" "JPG" "png" "PNG" "gif" "GIF" "raw")
        ;;
    video)
        file_extensions=("mp4" "avi" "mov" "mkv")
        ;;
    document)
        file_extensions=("doc" "docx" "pdf" "txt")
        ;;
    sound)
        file_extensions=("mp3" "wav" "flac")
        ;;
    *)
        echo "Invalid file group: $file_group"
        echo "Available file groups: image, video, document, sound"
        exit 1
        ;;
esac

# Initialize the counter and associative array for statistics
declare -A file_count
counter=0

# Find and copy files
for file_extension in "${file_extensions[@]}"; do
    file_count[$file_extension]=0
    while IFS= read -r file; do
        # Get the relative path of the file
        relative_path="${file#$source_folder/}"
        
        # Create the corresponding directory in the destination folder
        dest_dir="$dest_folder/$(dirname "$relative_path")"
        mkdir -p "$dest_dir"
        
        # Copy the file to the destination directory
        cp "$file" "$dest_dir"
    
        # Increment the counters
        counter=$((counter+1))
        file_count[$file_extension]=$((file_count[$file_extension]+1))
        echo -ne "\rCopied files: $counter"
    
        # Delete the file if specified
        if [ "$delete_file" = true ]; then
            rm "$file"
        fi
    done < <(find "$source_folder" -type f -iname "*.$file_extension")
done

# If files were deleted, remove empty directories in the source folder
if [ "$delete_file" = true ]; then
    find "$source_folder" -type d -empty -delete
fi

# Print statistics
echo -e "\nFiles copied successfully. Total files copied: $counter"
if [ "$delete_file" = true ]; then
    echo "Source files were deleted after copying."
fi
for ext in "${!file_count[@]}"; do
    echo "Files with extension .$ext: ${file_count[$ext]}"
done