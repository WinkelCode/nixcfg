{ config, pkgs, ... }:

{
  imports =
    [ # Imports
      ./hardware-configuration.nix
    ];

  # Systemd-Boot Stuff
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;


  # Timezone & Locale
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  
  # NTP
  services.timesyncd.enable = false; # Disable timesyncd
  services.chrony = { # Enable and Set up Chrony
    enable = true;
    services.chrony.enableNTS = true;
    services.chrony.servers = [
      ptbtime1.ptb.de
    ];

  # Network
  networking = {
    useDHCP = false; # New Default Behavior
    interfaces = {
      eth0 = { # Ethernet Default
        useDHCP = true; # Uses DHCP
      };
    };
  };
  
  # Users
  users = {
    mutableUsers = false;
    users = {
      user = { # User Account 1
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        password = "user";
        packages = with pkgs; [ # User's Packages
          vim
        ];
      };
    };
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    git
  ];
  
  system.stateVersion = "21.11"; # Initial Version Thingy

};

