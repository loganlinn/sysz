{
  description = "fzf terminal UI for sysctl";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs = inputs @ {flake-parts, ...}:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = {
        config,
        pkgs,
        lib,
        ...
      }: {
        packages.default = config.packages.sysz;
        packages.sysz = pkgs.callPackage ./. {};
        apps.default = config.apps.sysz;
        apps.sysz.program = lib.getExe config.packages.sysz;
        apps.sysz.type = "app";
        overlayAttrs.sysz = config.packages.sysz;
        devShells.default = pkgs.mkShell {
          name = "sysz";
          inputsFrom = [ config.packages.sysz ];
          buildInputs = with pkgs; [
            coreutils
            bash
            fzf
            nixpkgs-fmt
            gnumake
            gnused
            git
            pacman
          ];
        };
      };
      flake = {
        debug = true;
      };
    };
}
