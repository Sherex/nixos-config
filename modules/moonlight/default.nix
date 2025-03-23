{ config, pkgs, lib, ... }:
{
  home-manager.users.sherex = { pkgs, ... }: {
    home.packages = with pkgs; [
      moonlight-qt
    ];

    xdg.desktopEntries.moonlight = {
      name = "WinShit (Moonlight)";
      comment = "Stream the Desktop from winshit using Moonlight";
      exec = "${pkgs.writeShellScript "start-winshit-stream.sh" ''
        VM_NAME="winshit"
        STREAMING_PORT=47984  # Change this if Sunshine runs on a different port
        CHECK_INTERVAL=1
        NOTIFY_CMD="${pkgs.libnotify}/bin/notify-send -u normal"
        VIRSH_CMD="${pkgs.libvirt}/bin/virsh -c qemu:///system"

        # Check if VM is already running
        if $VIRSH_CMD list --name | grep -q "^$VM_NAME$"; then
            echo "VM '$VM_NAME' is already running."
            $NOTIFY_CMD "VM Already Running" "The VM '$VM_NAME' is already running."
        else
            # Start the VM
            $VIRSH_CMD start "$VM_NAME" > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                $NOTIFY_CMD "VM Started" "The VM '$VM_NAME' has been started."
            else
                $NOTIFY_CMD "VM Error" "Failed to start the VM '$VM_NAME'."
                exit 1
            fi
        fi

        # Function to get VM's IP address
        get_vm_ip() {
            $VIRSH_CMD domifaddr "$VM_NAME" | awk '/ipv4/ {print $4}' | cut -d'/' -f1
        }

        # Function to check if Sunshine is responding
        is_sunshine_ready() {
            local ip=$(get_vm_ip)
            if [ -z "$ip" ]; then
                return 1  # VM has no IP yet
            fi

            # Send a small packet to the streaming port and check if there's a response
            echo -n | nc -zv -w 2 "$ip" "$STREAMING_PORT" 2>&1 | grep -q "succeeded"
            return $?  # 0 if service is responding, non-zero otherwise
        }

        # Wait until the Sunshine service is up
        echo "Waiting for Sunshine service to be ready..."
        while ! is_sunshine_ready; do
            sleep $CHECK_INTERVAL
        done

        $NOTIFY_CMD "VM Ready" "Sunshine is now running on '$VM_NAME'."
        echo "Sunshine service is ready for use."

        moonlight stream winshit Desktop
      ''}";
      icon = "moonlight";
      terminal = false;
      type = "Application";
      categories = [ "Qt" "Game" ];
      settings = {
        Keywords = "nvidia;gamestream;stream;sunshine;remote play";
      };
    };
  };
}


