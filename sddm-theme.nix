# simple-sddm-2-flake-source/sddm-theme.nix
{ config, pkgs, lib, simpleSddm2ThemePackage, ... }:

let
  # Get the theme package we just defined (it will be an attribute in our flake output)
  # We'll refer to it as 'config.lib.simpleSddm2Theme' or similar from the module.
  # For now, let's assume it's passed in or we get it via `pkgs.simple-sddm-2`.
  # When this is part of a flake, we'll pass it as an argument or grab from inputs.
  # Let's simplify and make the flake provide it directly for the module.
  simpleSddm2ThemePackage = pkgs.simple-sddm-2-theme; # This will be defined by the flake.

in {
  options.andarii.sddm = {
    enableSimpleSddm2Theme = lib.mkEnableOption "simple-sddm-2 theme for SDDM";
  };

  config = lib.mkIf config.andarii.sddm.enableSimpleSddm2Theme {
    # Ensure SDDM is enabled
    services.xserver.displayManager.sddm.enable = true;

    # Set the theme to 'simple-sddm-2' (the name used in the installPhase)
    services.xserver.displayManager.sddm.theme = "simple-sddm-2";

    # Add the theme package to the system's environment.systemPackages
    # This ensures the theme files are present and SDDM can find them.
    environment.systemPackages = [
      simpleSddm2ThemePackage
    ];

    # Optionally, you might want to configure the background if the theme supports it
    # This would typically be done by overriding theme.conf or providing it
    # services.xserver.displayManager.sddm.extraConfig = ''
    #   Theme=simple-sddm-2
    #   [Theme]
    #   Background=/path/to/your/background.png
    # '';
    # Or, if the theme uses a specific background configuration:
    # services.xserver.displayManager.sddm.extraConfig = ''
    #   [Theme]
    #   background=${simpleSddm2ThemePackage}/share/sddm/themes/simple-sddm-2/Backgrounds/tokyocity.png
    # '';
    # You'll need to check the theme's `theme.conf` for how it handles backgrounds.
    # The default `theme.conf` just points to `Backgrounds/tokyocity.png` so it should work out of the box if `simpleSddm2ThemePackage` is correct.
  };
}
