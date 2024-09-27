{ pkgs, ... }:
{
  programs.gamemode.enable = true; # for performance mode

  programs.steam = {
    enable = true; # install steam
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  environment.systemPackages = with pkgs; [
    lutris # install lutris launcher
    protonup-qt # GUI for installing custom Proton versions like GE_Proton
  ];

  hardware.graphics = {
    # radv: open-source Vulkan driver from freedesktop. More performant, but less correct 
    enable32Bit = true; # enable 32-bit graphics drivers for 32-bit games in Wine/Proton

    # amdvlk: open-source Vulkan driver from AMD. More correct, but less performant. Consider enabling when issues arise with radv
    # extraPackages = [ pkgs.amdvlk ];
    # extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
  };
}
