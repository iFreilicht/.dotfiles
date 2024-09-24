{ config, lib, pkgs, ... }:
let
  cfg = config.boot.loader.systemd-boot;
in
{
  options = {
    boot.loader.systemd-boot = {
      edk2-uefi-shell = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Make the EDK2 UEFI Shell available from the systemd-boot menu.
            It can be used to manually boot other operating systems or for debugging.
          '';
        };

        sortKey = lib.mkOption {
          type = lib.types.str;
          default = "o_edk2-uefi-shell";
          description = ''
            `systemd-boot` orders the menu entries by their sort keys,
            so if you want something to appear after all the NixOS entries,
            it should start with {file}`o` or onwards.

            See also {option}`boot.loader.systemd-boot.sortKey`..
          '';
        };
      };

      windows = lib.mkOption {
        default = { };
        description = ''
          Make Windows bootable from systemd-boot. This option is not necessary when Windows and NixOS use the
          same EFI System Partition (ESP). In that case, Windows will automatically be detected by systemd-boot.

          However, if Windows is installed on a separate drive or ESP, you can use this option to add a menu entry
          for each installation manually.

          The attribute name is the title of the menu entry.
        '';
        example = lib.literalExpression ''
          { 
            "Windows 10".efiDeviceHandle = "HD0c3";
            "Windows 11... Are you sure about this?" = {
              efiDeviceHandle = "FS1";
              sortKey = "z_windows";
              cleanName = "windows-11";
            };
           }
        '';
        type = lib.types.attrsOf (lib.types.submodule ({ config, ... }: {
          options = {
            efiDeviceHandle = lib.mkOption {
              type = lib.types.str;
              example = "HD1b3";
              description = ''
                The device handle of the EFI System Partition (ESP) where the Windows bootloader is located.
                This is the device handle that the EDK2 UEFI Shell uses to load the bootloader.

                To find this handle, follow these steps:
                1. Set {option}`boot.loader.systemd-boot.edk2-uefi-shell.enable` to `true`
                2. Run `nixos-rebuild boot`
                3. Reboot and select "EDK2 UEFI Shell" from the systemd-boot menu
                4. Run `map -c` to list all consistent device handles
                5. For each device handle (for example, `HD0c1`), run `ls HD0c1:\EFI`
                6. If the output contains the directory `Microsoft`, you might have found the correct device handle
                7. Run `HD0c1:\EFI\Microsoft\Boot\Bootmgfw.efi` to check if Windows boots correctly
                8. If it does, this device handle is the one you need (in this example, `HD0c1`)

                This option is required, there is no useful default.
              '';
            };

            sortKey = lib.mkOption {
              type = lib.types.str;
              default = "";
              defaultText = ''{option}`cleanName`, prefixed with "os_"'';
              description = ''
                `systemd-boot` orders the menu entries by their sort keys,
                so if you want something to appear after all the NixOS entries,
                it should start with {file}`o` or onwards.

                See also {option}`boot.loader.systemd-boot.sortKey`..
              '';
            };

            cleanName = lib.mkOption {
              type = lib.types.strMatching "[a-z0-9_]+";
              example = "windows_10";
              default = lib.toLower (lib.replaceStrings [ " " ] [ "_" ] config._module.args.name);
              defaultText = ''attribute name of this entry, lower cased, with spaces replaced by underscores'';
              description = ''
                Cleaned-up version of the attribute name, used internally. Should be unique for each
                Windows installation. Only has to be set if the attribute name contains special characters.
              '';
            };
          };
        }));
      };
    };
  };

  config = {
    boot.loader.systemd-boot =
      let
        shell-path = "efi/shell.efi";
      in
      {
        extraFiles = lib.mkIf (cfg.edk2-uefi-shell.enable || cfg.windows != { }) {
          ${shell-path} = "${pkgs.edk2-uefi-shell}/shell.efi";
        };
        extraEntries = lib.mkMerge ([
          (lib.mkIf cfg.edk2-uefi-shell.enable {
            "edk2-uefi-shell.conf" = ''
              title EDK2 UEFI Shell
              efi /${shell-path}
              sort-key ${cfg.edk2-uefi-shell.sortKey}
            '';
          })
        ] ++ lib.mapAttrsToList
          (name: cfg: {
            "${cfg.cleanName}.conf" = ''
              title ${name}
              efi /${shell-path}
              options -nointerrupt -nomap -noversion ${cfg.efiDeviceHandle}:EFI\Microsoft\Boot\Bootmgfw.efi
              sort-key ${if cfg.sortKey != "" then cfg.sortKey else "os_" + cfg.cleanName}
            '';
          })
          cfg.windows);
      };
  };
}
