#!/usr/bin/bash
###############
#  script to list create date subvol by directory 
#
#############

parse_btrfs_subvol_by_name() {
    local subvol_name="$1"
    local creation_time

    # Check if the subvolume name is provided
    if [[ -z "$subvol_name" ]]; then
        echo "Usage: parse_btrfs_subvol_by_name <subvolume_name>"
        return 1
    fi

    # Find the path of the subvolume using the subvolume name
    # Extract the creation time
    creation_time=$(sudo btrfs subvolume show "$subvol_name" | grep -oP 'Creation time:\s*\K.*')

    # Print the subvolume name and creation date
    echo -n "Volume Name: $subvol_name"
    echo "  Creation Date: $creation_time"
}
# credit
# https://stackoverflow.com/questions/25908149/how-to-test-if-location-is-a-btrfs-subvolume
#
is_btrfs_subvolume() {
    local dir=$1
    [ "$(stat -f --format="%T" "$dir")" == "btrfs" ] || return 1
    inode="$(stat --format="%i" "$dir")"
    case "$inode" in
        2|256)
            return 0;;
        *)
            return 1;;
    esac
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
# delete first entry as directory 
file_list=("${file_list[@]:1}")
for file in "${file_list[@]}"; do
    # Skip the .snapshot directory
    #  debug - echo "file: $file"
    if [[ "$file" == *".snapshot"* ]]; then
        continue
    fi
    if  is_btrfs_subvolume "$file" ; then
       parse_btrfs_subvol_by_name "$file"
    fi 
done

