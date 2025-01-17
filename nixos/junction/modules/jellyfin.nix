{ mnt, lib, ... }:
let
  dataDir = "${mnt.jellyfin}/data";
  movieDir = "${mnt.jellyfin}/Movies";
  showsDir = "${mnt.jellyfin}/Shows";
  musicDir = "${mnt.jellyfin}/Music";
  booksDir = "${mnt.jellyfin}/Books";
in
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    dataDir = dataDir;
  };

  # Set up folder structure and permissions
  systemd.tmpfiles.rules =
    [
      "d ${dataDir} 0750 jellyfin jellyfin - -" # Only jellyfin should write to the data dir
    ]
    ++ lib.map (dir: "d ${dir} 0770 jellyfin users - -") # Allow jellyfin and regular users to add/access media
      [
        movieDir
        showsDir
        musicDir
        booksDir
      ];

  # Backups
  services.borgmatic.configurations.files = {
    source_directories = [
      # Only back up metadata and configuration, media is too big for remote backups
      dataDir
    ];
  };
}
