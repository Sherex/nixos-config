#!/usr/bin/env nix-shell
#!nix-shell -i bash -p age sops

set -euo pipefail

prompt() {
  local ans
  while true; do
    read -p "$1 [y/yes/n/no]: " ans
    [[ -z "$ans" ]] && continue
    [[ "$ans" =~ ^[yY](es)?$ ]] && return 0
    [[ "$ans" =~ ^[nN](o)?$ ]] && return 1
  done
}

if [ ! -f ".sops.yaml" ]; then
  echo "Could not find .sops.yaml in the current directory."
  echo "Are you executing the script from the correct directory?"
  exit 1
fi

template_file="secrets_template.yaml"
if [ ! -f "$template_file" ]; then
  echo "Error: Template file '$template_file' not found."
  echo "Please create a YAML template file with the expected structure."
  prompt "Optionally create a empty file there now?" || exit 1
  touch $template_file 
fi

secrets_dir="/persistent/safe/secrets"
output_file="$secrets_dir/default.yaml"

hostname=${1:-$(hostname)}
key_file="/persistent/safe/keys/${hostname}.txt"
if prompt "Use '$hostname' as hostname?"; then
  echo "Proceeding with $hostname"
else
  echo "Please provide the desired hostname as first argument."
  echo "NOTE: It has to match the name of the system that is being set up."
  exit 1
fi

echo "
Summary of actions to be performed:
- Hostname used: $hostname
- Age key file to be created or reused: $key_file
- Secrets directory to be created: $secrets_dir
- Template file to be edited: $secrets_dir/$template_file
- Final SOPS-encrypted output file: $output_file

Directories to create:
  - /persistent/safe/keys
  - /persistent/safe/secrets

Files to create/edit:
  - $key_file (age key)
  - $template_file (user-edited secrets template)
  - $output_file (SOPS-encrypted secrets)
"
prompt "Proceed?" || exit 0

echo "Creating directories..."
sudo mkdir -p /persistent/safe/keys
sudo mkdir -p /persistent/safe/secrets

if sudo [ ! -f $key_file ]; then
  echo "Generating age key.. storing at $key_file"
  sudo age-keygen -o $key_file
  if [ $? -ne 0 ]; then
    echo "Error: age-keygen failed."
    exit 1
  fi
else
  echo "Using existing $key_file"
fi

sudo chown -R root:root /persistent/safe/keys
sudo chmod 600 "$key_file"

sudo chown -R root:root "$secrets_dir"
sudo chmod 700 "$secrets_dir"

# 5. Prompt the user to edit the template file
echo "Please edit the template file '$template_file' and fill in your secrets."
echo "You can use any text editor (e.g., nano, vim)."
if sudo [ ! -f "$secrets_dir/$template_file" ]; then
  echp "Copying $template_file to $secrets_dir..."
  sudo install -o root -g root -m 0600 "$template_file" "$secrets_dir/$template_file"
fi

prompt "Edit $secrets_dir/$template_file now with sudoedit?" && sudoedit "$secrets_dir/$template_file"

# 6.  Create/Update the sops file for the host from the template.
echo "Creating/Updating SOPS secret file: $output_file"
sudo SOPS_AGE_KEY_FILE="$key_file" sops encrypt "$secrets_dir/$template_file" --output "$output_file"
if [ $? -ne 0 ]; then
  echo "Error: sops command failed."
  exit 1
fi

echo "Bootstrapping complete for hostname: $hostname"
echo "Age key stored at: $key_file"
echo "SOPS secret file created/updated at: $output_file"

