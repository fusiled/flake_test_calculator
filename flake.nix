{
  description = "A simple calculator";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.multiplier.url = "github:fusiled/flake_test_multiplier";


    outputs = { self, nixpkgs, multiplier, ... }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      package_name = "calculator";
      pkgs = system : import nixpkgs { inherit system; };

      mul_pkg = system : multiplier.packages.${system}.libmultiplier;

      derivRecipe = {system } : (pkgs(system)).stdenv.mkDerivation rec {
          pname = package_name;
          version = "0.0.1";

          src = ./.;

          nativeBuildInputs = [ multiplier ];
          buildInputs = [ multiplier ];

          buildPhase = ''
            $CXX -v -I${mul_pkg(system)}/include --std=c++11  ${mul_pkg(system)}/lib/libmultiplier.dylib -o calculator ./tst.cpp;
        '';

        installPhase = ''
            mkdir -p $out/bin;
            cp ./calculator $out/bin/;
        '';
        };

    in
    {
        packages = forAllSystems (system: {${package_name} = derivRecipe {system=system;};});
        defaultPackage = forAllSystems (system: self.packages.${system}.${package_name});
    };

}
