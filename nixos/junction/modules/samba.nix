{
  lib,
  mnt,
  net,
  ...
}:

let
  shares = {
    public = "${mnt.samba}/public";
    private = "${mnt.samba}/private";
    timemachine = "${mnt.samba}/tm_share";
  };

  # Valid values are documented here: https://callumgare.github.io/macos-device-icons/
  # However, most don't seem to work. TimeCapsule8,119 was the only one that reliably displayed a custom icon
  # (at least in the beginning, now that doesn't work either)
  macOsIcon = "TimeCapsule8,119";
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
    openFirewall = true;
    settings = {
      # Use `global` instead of `extraConfig` to avoid syntax errors
      global = {
        security = "user";

        # Basic settings
        "server string" = net.junction.name;
        "netbios name" = net.junction.name;
        "workgroup" = "WORKGROUP";

        # Security settings
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "${net.gateway.wireguard.subnet} ${net.home.subnet} 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";

        ### TIME MACHINE ###
        "min protocol" = "SMB2";
        "ea support" = "yes";

        # This needs to be global else time machine ops can fail, according to
        # https://github.com/connorfeeley/dotfiles/blob/fe585f1c34d4384173a10948d83d00737b3d0a26/nixos/machines/workstation/samba.nix#L33
        "vfs objects" = "fruit streams_xattr";
        "fruit:aapl" = "yes";
        "fruit:metadata" = "stream";
        "fruit:model" = macOsIcon;
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:zero_file_id" = "yes";
        "fruit:nfs_aces" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "spotlight" = "no";
      };
      # Public share for Movies, ISOs, etc.
      public = {
        path = shares.public;
        "guest ok" = "yes";
        "read only" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "write list" = "felix";
        "force user" = "samba";
        "force group" = "samba";
      };
      # Private share for personal files
      private = {
        path = shares.private;
        "guest ok" = "no";
        "read only" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "samba";
        "force group" = "samba";
      };

      # Apple TimeMachine share
      timemachine = {
        path = shares.timemachine;
        "guest ok" = "no";
        "read only" = "no";
        "force user" = "samba";
        "force group" = "samba";
        "fruit:time machine" = "yes";
        # Sufficient with my current 500GB SSD and Nix store taking up a bunch of that
        "fruit:time machine max size" = "500G";
        "vfs objects" = "catia fruit streams_xattr";
      };
    };
  };

  # Ensure directories for shares exist
  systemd.tmpfiles.rules = (
    lib.lists.map (path: "d ${path} 0750 samba samba - -") ([ mnt.samba ] ++ (lib.attrValues shares))
  );

  # Make Transmission downloads available in the public Samba share
  fileSystems = {
    "${mnt.samba}/public/TorrentDownloads" = {
      device = "${mnt.transmission}/Downloads";
      options = [
        "bind"
        "ro"
      ];
    };
  };

  # Advertise shares to Windows clients
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # Advertise shares to macOS clients
  services.avahi = {
    publish = {
      enable = true;
      userServices = true;
      # ^^ Needed to allow samba to automatically register mDNS records (without the need for an `extraServiceFile`
    };
    nssmdns4 = true;
    # ^^ Not one hundred percent sure if this is needed- if it aint broke, don't fix it
    enable = true;
    openFirewall = true;
    allowInterfaces = [
      "enp2s0"
      "wg0"
    ];
    extraServiceFiles = {
      timemachine = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
            <service>
            <type>_device-info._tcp</type>
            <port>0</port>
            <txt-record>model=${macOsIcon}</txt-record>
          </service>
          <service>
            <type>_adisk._tcp</type>
            <txt-record>dk0=adVN=timemachine,adVF=0x82</txt-record>
            <txt-record>sys=waMa=0,adVF=0x100</txt-record>
          </service>
        </service-group>
      '';
    };
  };
}
