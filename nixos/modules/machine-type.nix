{ lib, ... }:
{
  options = {
    uhl.machineType = lib.mkOption {
      type = lib.types.enum [
        "desktop"
        "server"
      ];
      description = ''
        The type of machine this configuration is for. This affects the
        packages and services that are enabled by default.
      '';
    };
  };
}
