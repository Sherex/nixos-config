#!/usr/bin/env bash

set -e

DOCKER_DATA_IMAGE="$1"
DOCKER_DATA_IMAGE_SIZE="$2"

[[ ! "$DOCKER_DATA_IMAGE_SIZE" =~ ^[0-9]+$ ]] && \
  echo "Second argument image size can only contain numbers in bytes" && \
  exit 1

echo "Checking if $DOCKER_DATA_IMAGE exists"
[[ -f "$DOCKER_DATA_IMAGE" ]] && \
  IMAGE_FILE_SIZE="$(stat --printf="%s" "$DOCKER_DATA_IMAGE")"

[[ "$IMAGE_FILE_SIZE" == "$DOCKER_DATA_IMAGE_SIZE" ]] && \
  echo "Existing file is the same size as the requested size ($DOCKER_DATA_IMAGE_SIZE). Exiting..." && \
  exit 0

[[ "$IMAGE_FILE_SIZE" > "$DOCKER_DATA_IMAGE_SIZE" ]] && \
  echo "Requested size can't be less that existing size ($IMAGE_FILE_SIZE > $DOCKER_DATA_IMAGE_SIZE)" && \
  exit 0

truncate --size="$DOCKER_DATA_IMAGE_SIZE" "$DOCKER_DATA_IMAGE"

echo "Format with EXT4 if it did not exist"
[[ -z $IMAGE_FILE_SIZE ]] && \
  echo "File was just created; formatting with EXT4..." && \
  mkfs.ext4 "$DOCKER_DATA_IMAGE"

echo "Check filesystem"
e2fsck -f "$DOCKER_DATA_IMAGE"

