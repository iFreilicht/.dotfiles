{ pkgs, ... }:
{
  programs.gamemode.enable = true; # for performance mode

  programs.steam = {
    enable = true; # install steam
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  environment.systemPackages = with pkgs; [
    lutris # Universal game launcher
    wineWowPackages.waylandFull # Native Wine, the only one you can't install with protonup
    protonup-qt # GUI for installing custom Proton and Wine versions like GE_Proton
    winetricks # Useful tools for wine workarounds
    protontricks # Run winetricks on Proton prefixes
    mangohud # Vulkan overlay for monitoring
  ];

  hardware.graphics = {
    # radv: open-source Vulkan driver from freedesktop. More performant, but less correct
    enable32Bit = true; # enable 32-bit graphics drivers for 32-bit games in Wine/Proton

    # amdvlk: open-source Vulkan driver from AMD. More correct, but less performant. Consider enabling when issues arise with radv
    # extraPackages = [ pkgs.amdvlk ];
    # extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
  };
}
