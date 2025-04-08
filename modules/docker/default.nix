{ config, pkgs, lib, home-manager, ... }:

let 
  data-root = "/media/docker-data";
  image-path = "/media/docker-data.img";
  image-size = "2500000000";
in
{
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
    daemon.settings = {
      data-root = data-root;
    };
  };

  # TODO:
  # - Test that the docker fs service below works as expected
  #   - Ensure directories exists
  # - Mount docker-data.img at docker-data
  # - Run docker rootless service as a systemservice but as a system user (dockeruser)

  systemd.services.ensure-docker-data-fs-exists = {
    description = "Creates an EXT4 filesystem in a file for use by Docker";
    enable = true;

    wantedBy = [ "default.target" ];

    path = [ pkgs.e2fsprogs ];
    script = ''
      set -e

      DOCKER_DATA_IMAGE="${image-path}"
      DOCKER_DATA_IMAGE_SIZE="${image-size}"

      [[ ! "$DOCKER_DATA_IMAGE_SIZE" =~ ^[0-9]+$ ]] && \
        echo "Second argument image size can only contain numbers in bytes" && \
        exit 1

      mkdir -p "$(dirname $DOCKER_DATA_IMAGE)"

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

    '';
  };
}

