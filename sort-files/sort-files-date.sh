#!/bin/bash

while getopts "s:d:D" opt; do
    case $opt in
        s)
            source_dir=$OPTARG
            ;;
        d)
            dest_dir=$OPTARG
            ;;
        D)
            delete_source=true
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

if [ -z "$source_dir" ] || [ -z "$dest_dir" ]; then
    echo "Usage: $0 -s <source directory> -d <destination directory> [-D (delete source files)]"
    exit 1
fi

if [ ! -d "$source_dir" ]; then
    echo "Source directory does not exist: $source_dir"
    exit 1
fi

mkdir -p "$dest_dir"

counter=0
declare -A file_count

while IFS= read -r file; do
    year_of_creation=$(stat -c %y "$file" | cut -d ' ' -f 1 | cut -d '-' -f 1)
    # month_of_creation=$(stat -c %y "$file" | cut -d ' ' -f 1 | cut -d '-' -f 2)

    if [ -z ${file_count[$year_of_creation]} ]; then
        file_count[$year_of_creation]=1
    else
        file_count[$year_of_creation]=$((file_count[$year_of_creation]+1))
    fi
 
    parent_dir_name=$(basename "$(dirname "$file")")

    destination="$dest_dir/$year_of_creation/$parent_dir_name"
    mkdir -p "$destination"

    cp -p "$file" "$destination"
    echo -n "$(dirname "$file")" | tee "$destination/source.txt" > /dev/null

    counter=$((counter+1))
    echo -ne "\rCopied files: $counter"
 
done < <(find "$source_dir" -type f)

# Print statistics
echo -e "\nFiles copied successfully. Total files copied: $counter"
if [ "$delete_source" = true ]; then
    echo "Source files were deleted after copying."
fi
for year in "${!file_count[@]}"; do
    echo "Files created in $year: ${file_count[$year]}"
done
