{
  description = "A declarative controller for self-hosting zerotier";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
      systems = lib.systems.flakeExposed;
      perSystem = { pkgs, ... }:
        let
          zerotier-src = pkgs.fetchFromGitHub {
            owner = "zerotier";
            repo = "ZeroTierOne";
            rev = "master";
            hash = "sha256-fcGVoV0Vd8TrYDE730W9GBHcVjTXB3oGqWzJRErBBzk=";
          };
        in
        {
          packages.default = pkgs.mkShell {
            packages = [
              pkgs.bashInteractive
              pkgs.cmake
              pkgs.rustc
              pkgs.cargo
            ];

            CMAKE_FLAGS = "-DSOURCE_DIR=${zerotier-src}";
          };
        };
    });
}
