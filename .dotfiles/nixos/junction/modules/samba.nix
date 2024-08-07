{ lib, mnt, net, ... }:

let
  shares = {
    public = "${mnt.samba}/public";
    private = "${mnt.samba}/private";
  };
in
{
  # Unix user owning the samba shares
  users.users.samba = {
    isSystemUser = true;
    group = "samba";
  };
  users.groups.samba = { };

  # Samba file shares
  # ON REINSTALL: Add users again with `smbpasswd -a <username>`
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      server string = ${net.junction.name}
      netbios name = ${net.junction.name}
      workgroup = WORKGROUP

      # note: localhost is the ipv6 localhost ::1
      # 10.100.0. are wireguard peers
      hosts allow = 10.100.0. 192.168.0. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      public = {
        path = shares.public;
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "write list" = "felix";
        "force user" = "samba";
        "force group" = "samba";
      };
      private = {
        path = shares.private;
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "samba";
        "force group" = "samba";
      };
    };
  };

  # Ensure directories for shares exist
  systemd.tmpfiles.rules =
    (lib.lists.map
      (path:
        "d ${path} 0750 samba samba - -"
      )
      ([ mnt.samba ] ++ (lib.attrValues shares)));

  # Advertise shares to Windows clients
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.avahi = {
    publish.enable = true;
    publish.userServices = true;
    # ^^ Needed to allow samba to automatically register mDNS records (without the need for an `extraServiceFile`
    nssmdns4 = true;
    # ^^ Not one hundred percent sure if this is needed- if it aint broke, don't fix it
    enable = true;
    openFirewall = true;
  };
}
