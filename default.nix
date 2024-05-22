{
  sources ? import ./nix/sources,
  system ? builtins.currentSystem,
  pkgs ? import sources.nixpkgs { inherit system; config = { }; overlays = [ ]; },
  # a newer version of Nixpkgs ships with an improved rnix-parser,
  # but nixdoc upstream does not expose the package recipe...
  # https://github.com/nix-community/nixdoc/pull/125
  nixdoc ? pkgs.callPackage ./nix/nixdoc.nix { inherit sources; },
  git-hooks ? pkgs.callPackage sources.git-hooks { },
}:
let
  update-readme = lib.nixdoc-to-github.run {
    description = "nixdoc to GitHub";
    category = "nixdoc-to-github";
    file = "${toString ./lib.nix}";
    output = "${toString ./README.md}";
  };
  lib = {
    nixdoc-to-github = (pkgs.callPackage ./lib.nix { inherit nixdoc; });
    inherit (git-hooks.lib) git-hooks;
  };
  # wrapper to account for the custom lockfile location
  npins = pkgs.callPackage ./nix/npins.nix { };
in
{
  lib = { inherit (lib) nixdoc-to-github; };

  shell = pkgs.mkShellNoCC {
    packages = [
      npins
      nixdoc
    ];
    shellHook = ''
      ${with lib.git-hooks; pre-commit (wrap.abort-on-change update-readme)}
    '';
  };
}
