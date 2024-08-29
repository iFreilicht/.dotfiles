{ config, lib, mnt, ... }:
let
  # To be able to open the ports in the firewall that FTP will randomly assign when entering
  # passive mode, we need to restrict the range, else we'd have to open all of them.
  ftp-pasv-min-port = 22200;
  ftp-pasv-max-port = 22400;
in
{
  # This FTP server is not supposed to be general-purpose, it is purely designed
  # to be a target for backups from some machines of my family members.
  # Regular file access for server users happens via SSH.

  sops.secrets."ftp-users/stefan/pw-hash" = {
    neededForUsers = true;
  };

  users.users.stefan = {
    isSystemUser = true;
    home = "${mnt.ftp}/stefan";
    createHome = true;
    # Only allow reading access to the home directory.
    # This is a security requirement by vsftpd
    homeMode = "500";
    group = "ftp";
    hashedPasswordFile = config.sops.secrets."ftp-users/stefan/pw-hash".path;
  };

  # As the home directory can't be written to, create writeable subdirectories.
  # These can then be accessed fully via FTP.
  systemd.tmpfiles.rules = [
    "d ${mnt.ftp}/stefan/album 0700 stefan ftp -"
  ];

  services.vsftpd = {
    enable = true;
    localUsers = true;
    writeEnable = true;
    # Prevent access to any files outside of the user's home directory 
    chrootlocalUser = true;
    # Only allow access through these accounts by default
    userlist = [
      "stefan"
    ];
    extraConfig = ''
      pasv_min_port=${toString ftp-pasv-min-port}
      pasv_max_port=${toString ftp-pasv-max-port}
    '';
  };

  networking.firewall.allowedTCPPorts = [ 20 21 ] ++ (lib.range ftp-pasv-min-port ftp-pasv-max-port);
}
