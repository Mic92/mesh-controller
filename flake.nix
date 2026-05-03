{
  description = "A declarative controller for self-hosting zerotier";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      eachSystem =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system: f nixpkgs.legacyPackages.${system}
        );
    in
    {
      packages = eachSystem (
        pkgs:
        let
          zerotier-src = pkgs.fetchFromGitHub {
            owner = "zerotier";
            repo = "ZeroTierOne";
            rev = "master";
            hash = "sha256-fcGVoV0Vd8TrYDE730W9GBHcVjTXB3oGqWzJRErBBzk=";
          };
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.bashInteractive
              pkgs.cmake
              pkgs.rustc
              pkgs.cargo
            ];

            CMAKE_FLAGS = "-DSOURCE_DIR=${zerotier-src}";
          };
        }
      );

      checks = eachSystem (pkgs: {
        package-default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      });
    };
}
