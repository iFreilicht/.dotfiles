{
  pkgs,
  kdePackages,
  bash,
  plasma-theme-switcher,
}:
# Simple script to quickly switch between the light and dark breeze theme in KDE Plasma
let
  breeze = kdePackages.breeze;
  breeze-themes = "${breeze}/share/color-schemes";
  theme-switcher = "${plasma-theme-switcher}/bin/plasma-theme";
in
pkgs.writeScriptBin "toggle-dark" ''
  #!${bash}/bin/bash
  ${theme-switcher} -c ${breeze-themes}/BreezeDark.colors -c ${breeze-themes}/BreezeLight.colors
''
