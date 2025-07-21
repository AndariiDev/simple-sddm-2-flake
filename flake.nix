# simple-sddm-2-flake-source/flake.nix
{
  description = "NixOS flake for the simple-sddm-2 theme";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # Define the common system architecture
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system}; # Use legacyPackages for default access
      # Define the package here, so it can be used below
      simpleSddm2ThemePkg = pkgs.callPackage ./default.nix { };
    in
    {
      # 1. Provide the SDDM theme as a package
      packages.${system}.simple-sddm-2-theme = simpleSddm2ThemePkg;
      
      # 2. Provide the NixOS module
      nixosModules.default = { config, pkgs, lib, ... }: {
        imports = [
        (import ./sddm-theme.nix { # Pass `pkgs` and our specific package to the module
            inherit config lib pkgs; # Pass common module args
            simpleSddm2ThemePackage = simpleSddm2ThemePkg; # Pass our custom package
          })
        ];

        # The sddm-theme.nix module expects `pkgs.simple-sddm-2-theme`
        # We need to make sure this package is available to it.
        # This is where 'specialArgs' or making it accessible via 'pkgs' matters.
        # A simple way for a self-contained module is to ensure its `pkgs` has it.
        # However, the module can simply refer to it from its own flake's outputs too.
        config = {
          # Ensure the package is available within the module's pkgs context
          # This is implicitly handled when using `nixosModules.default` if the module
          # directly refers to `pkgs.simple-sddm-2-theme` and `pkgs` is the one passed to the module.
          # A more explicit way for the module to get *this* flake's package:
          # (This uses the `nixosModules` pattern where the module itself has access to `self`)
          _module.args = {
            simpleSddm2ThemePackage = self.packages.${system}.simple-sddm-2-theme;
          };
        };
      };
    };
}
