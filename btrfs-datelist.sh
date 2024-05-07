#!/usr/bin/bash


parse_btrfs_subvol_by_name() {
    local subvol_name="$1"
    local creation_time

    # Check if the subvolume name is provided
    if [[ -z "$subvol_name" ]]; then
        echo "Usage: parse_btrfs_subvol_by_name <subvolume_name>"
        return 1
    fi

    # Find the path of the subvolume using the subvolume name
    # local subvol_path=$(sudo btrfs subvolume list / | grep -oP "$subvol_name" | head -n 1)

    # Extract the creation time
    creation_time=$(sudo btrfs subvolume show "$subvol_name" | grep -oP 'Creation time:\s*\K.*')

    # Print the subvolume name and creation date
    echo -n "Volume Name: $subvol_name"
    echo "  Creation Date: $creation_time"
}

# Check if a directory path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Assign the first command-line argument to 'directory_path'
directory_path="$1"

# Read all file names into an array
readarray -t file_list < <(find "$directory_path" -maxdepth 1 -type d -printf "%f\n")

cd $directory_path
# Print all file names
for file in "${file_list[@]}"; do
     # Skip the .snapshot directory
    if [[ "$file" == *".snapshot"* ]]; then
        continue
    fi
    parse_btrfs_subvol_by_name "$file"
done

