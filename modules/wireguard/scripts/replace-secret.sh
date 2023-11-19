set -e

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <secret_name> <file_path> <regex>"
  exit 1
fi

# Assign arguments to variables
secret_name="$1"
file_path="$2"
regex="$3"

# Check if the file exists in /run/secrets
secret_file="/run/secrets/$secret_name"
if [ ! -f "$secret_file" ]; then
  echo "Error: Secret file not found: $secret_file"
  exit 1
fi

# Get the content of the secret file and escape special characters
secret_value=$(cat "$secret_file" | sed 's/[\.*^$]/\\&/g')

# Check if the file to be modified exists
if [ ! -f "$file_path" ]; then
  echo "Error: File not found: $file_path"
  exit 1
fi

# Ensure /run/secrets/replacements/ directory exists
replacements_dir="/run/secrets/replacements"
mkdir -p "$replacements_dir"

# Extract the filename from the file path
filename=$(basename "$file_path")

# Create the new file in /run/secrets/replacements
new_file="$replacements_dir/$filename"
sed -E "s/$regex/\1$secret_value\2/" "$file_path" > "$new_file"

# Bind mount the new file over the original file
mount --bind "$new_file" "$file_path"

echo "Replacement complete. Check the file: $file_path"
