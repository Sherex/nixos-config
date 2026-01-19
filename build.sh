#!/usr/bin/env bash

set -euo pipefail

HOST=""
TARGET_HOST=""
ACTION=""
EXTRA_ARGS=()
USE_HOST_FLAG=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --host)
            if [[ -z "${2:-}" || "$2" == --* ]]; then
                echo "Error: --host requires a non-option argument" >&2
                exit 1
            fi
            TARGET_HOST="$2"
            USE_HOST_FLAG=true
            shift 2
            ;;
        --host=*)
            TARGET_HOST="${1#*=}"
            USE_HOST_FLAG=true
            shift
            ;;
        --)
            # End of options
            shift
            EXTRA_ARGS+=("$@")
            break
            ;;
        -*)
            # Collect other options for nixos-rebuild
            EXTRA_ARGS+=("$1")
            shift
            ;;
        *)
            if [[ -z "$HOST" ]]; then
                HOST="$1"
            elif [[ -z "$ACTION" ]]; then
                ACTION="$1"
            else
                EXTRA_ARGS+=("$1")
            fi
            shift
            ;;
    esac
done

if [[ -z "$HOST" || -z "$ACTION" ]]; then
    echo "Usage: $0 <host> <action> [extra nixos-rebuild args...]" >&2
    echo "       $0 --host <target> <host> <action> [...]" >&2
    echo "Action must be one of: switch, build, boot" >&2
    exit 1
fi

if [[ ! "$ACTION" =~ ^(switch|build|boot)$ ]]; then
    echo "Invalid action: $ACTION" >&2
    echo "Action must be one of: switch, build, boot" >&2
    exit 1
fi

if [[ "$USE_HOST_FLAG" == false ]]; then
    TARGET_HOST="$HOST"
fi

if [[ "$ACTION" =~ ^(switch|boot)$ ]]; then
    echo "Adding \"wheel-nopass\" group to remote user"
    ssh -t "$TARGET_HOST" "sudo usermod -aG wheel-nopass sherex"
    echo "Success."
fi

echo "Starting build of $HOST..."
nixos-rebuild --flake ".#$HOST" "$ACTION" --target-host "$TARGET_HOST" --sudo "${EXTRA_ARGS[@]}"
