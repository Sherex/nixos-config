{ config, pkgs, lib, sops-nix, ... }:

{
  imports = [ sops-nix.nixosModules.sops ];

  environment.systemPackages = with pkgs; [
    age
    sops
  ];

  users.users.sherex.extraGroups = [ config.users.groups.keys.name ];
  home-manager.users.sherex.programs.bash.shellAliases.esecret =
    "esecret() (sudo SOPS_AGE_KEY_FILE=${config.sops.age.keyFile} sops \"/persistent/safe/secrets/$1\") && esecret";

  sops = {
    # TODO: Define paths in a central place and based on hostname

    # TODO: Figure out a way to use sops-nix with flakes in a non-impure way
    #       (The secrets and keys are now residing outside the git repo
    #        which is considered impure by Flakes)

    # TODO: Look more at this example to figure out a good way to
    #       structure secrets.
    #       https://github.com/Mic92/dotfiles/blob/main/nixos/eve/modules/bitwarden.nix
    defaultSopsFile = "/persistent/safe/secrets/default.yaml";
    defaultSopsFormat = "yaml";

    age.keyFile = "/persistent/safe/keys/${config.system.name}.txt";
    age.generateKey = true;

    # As the secret file is not in the Nix Store it can't be validated
    validateSopsFiles = false;

    secrets = {
      "user/password".neededForUsers = true;
    };
  };
}
