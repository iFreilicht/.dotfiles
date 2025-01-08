{
  config,
  pkgs,
  net,
  lib,
  ...
}:
let
  borgbase = net.junction.borgbase;
in
{
  # The root user needs an ssh key for borgmatic to be able to connect to the backup repos
  # ON REINSTALL: Run `sudo cat /root/.ssh/id_ed25519.pub` and add the output to the allowed keys in borgbase
  uhl.ensureRootSshKey.enable = true;

  programs.ssh.knownHosts = with borgbase; {
    ${repos.files.host}.publicKey = publicKey;
    ${repos.databases.host}.publicKey = publicKey;
  };

  sops.secrets."borg/passphrase" = {
    reloadUnits = [ "borgmatic.service" ];
  };

  services.borgmatic =
    let
      commonSettings = {
        compression = "lz4";
        archive_name_format = "backup-{now}";
        keep_hourly = 3;
        keep_daily = 7;
        keep_weekly = 4;
        keep_monthly = 6;
        keep_yearly = 10;

        # These options are used when `borgmatic check` is run
        check_last = 3;
      };
    in
    {
      enable = true;

      # ON REINSTALL: Run `sudo nix run nixpkgs#borgmatic -- init -e repokey-blake2` to initialize the repos,
      # or, when restoring from backups, research how to setup the repos from an existing remote repo
      configurations = {
        files = commonSettings // {
          # Leave empty on purpose, application modules should set this themselves
          source_directories = [ ];
          exclude_patterns = [ ];
          repositories = [ { inherit (borgbase.repos.files) path label; } ];
        };

        databases = commonSettings // {
          source_directories = lib.mkForce [ ]; # Should never be set for the databases repo
          # Leave empty on purpose, application modules should set this themselves
          mysql_databases = [ ];
          repositories = [ { inherit (borgbase.repos.databases) path label; } ];

        };
      };
    };
  systemd.services.borgmatic = {
    path = [
      # borgmatic requires mysqldump to be in the path to be able to backup MySQL databases
      pkgs.mariadb_106
      pkgs.sqlite # Required for backing up sqlite databases
    ];
    environment = {
      BORG_PASSCOMMAND = "cat ${config.sops.secrets."borg/passphrase".path}";
    };
  };
  systemd.timers.borgmatic.timerConfig = {
    # Run the backup every hour, 15 minutes past the hour
    OnCalendar = "*-*-* *:15";
    RandomizedDelaySec = "120"; # Default is 3h
  };
}
