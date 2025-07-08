{
  inputs = {
    opam-nix.url = "github:tweag/opam-nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.follows = "opam-nix/nixpkgs";
  };
  outputs =
    {
      self,
      flake-utils,
      opam-nix,
      nixpkgs,
    }@inputs:
    # Don't forget to put the package name instead of `throw':
    let
      package = "pgocaml";
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};
        devPackagesQuery = {
          ocaml-lsp-server = "*";
          ocamlformat = "*";
        };
        query = devPackagesQuery // {
          ocaml-base-compiler = "*";
        };
        scope = on.buildDuneProject { resolveArgs.with-test = true; } package ./. query;
        overlay = final: prev: {
          # Your overrides go here
        };
        scope' = scope.overrideScope overlay;
        devPackages = builtins.attrValues (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope');
      in
      {
        legacyPackages = scope';

        devShells.default = pkgs.mkShell {
          inputsFrom = [ scope'.${package} ];
          buildInputs = devPackages ++ [ pkgs.postgresql ];
        };
        packages.default = self.legacyPackages.${system}.${package};
      }
    );
}
