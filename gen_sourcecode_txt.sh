#!/bin/bash

print_file_content() {
    local file="$1"
    local file_name=$(basename "$file")
    echo "----- Start of file: $file_name -----"
    cat "$file"
    echo
    echo "----- End of file: $file_name -----"
    echo 
}

read_files_recursive() {
    local folder="$1"
    local files=()

    # Read all files and directories in the current folder
    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(find "$folder" -type f -print0)

    # Iterate over the files and print their content
    for file in "${files[@]}"; do
        print_file_content "$file"
    done
}

# Check if the folder path is provided as an argument
if [ $# -ne 1 ]; then
    echo "Please provide a folder path as an argument."
    exit 1
fi

# Get the folder path from the argument
folder_path="$1"

# Check if the folder exists
if [ ! -d "$folder_path" ]; then
    echo "Folder does not exist: $folder_path"
    exit 1
fi

# Call the function to read files recursively
read_files_recursive "$folder_path"
