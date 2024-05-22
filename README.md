# nixdoc to GitHub
Convert [nixdoc](https://github.com/nix-community/nixdoc/) output to GitHub markdown.

Ever wanted to show your Nix language library reference documentation right in the `README.md`?
This is how to do it.

> **Example**
>
> ## Automatically update files with a pre-commit hook
>
> Write a Nix language library with [RFC 145](https://github.com/NixOS/rfcs/pull/145)-style comments:
>
> ````nix
> /**
> A library to do nothing at all
> */
> { lib }:
> {
>   /**
>   This elegantly wraps `pkgs.lib.id`.
>
>   :::{.example}
>
>   # Do nothing
>
>   ```nix
>   id x
>   ```
>   :::
>   */
>   id = lib.id;
> }
> ````
>
> Add [fricklerhandwerk/git-hooks](https://github.com/fricklerhandwerk/git-hooks) to automatically set up Git hooks in your Nix shell environment.
>
> ```shell-session
> nix-shell -p npins
> npins init
> npins add github fricklerhandwerk nixdoc-to-github -b main
> npins add github fricklerhandwerk git-hooks -b main
> ```
>
> Add a pre-commit hook to update `README.md`:
>
> ```nix
> # default.nix
> {
>   sources ? import ./npins,
>   system ? builtins.currentSystem,
>   pkgs ? import sources.nixpkgs { inherit system; config = { }; overlays = [ ]; },
>   nixdoc-to-github ? pkgs.callpackage sources.nixdoc-to-github { },
>   git-hooks ? pkgs.callPackage sources.git-hooks { },
> }:
> let
>   lib = {
>     inherit (git-hooks.lib) git-hooks;
>     inherit (nixdoc-to-github.lib) nixdoc-to-github;
>   };
>   update-readme = lib.nixdoc-to-github.run {
>     description = "Nothing";
>     category = "nothing";
>     file = "${toString ./lib.nix}";
>     output = "${toString ./README.md}";
>   };
> in
> {
>   lib.nothing = pkgs.callPackage ./lib.nix { };
>   shell = pkgs.mkShellNoCC {
>     shellHook = ''
>       ${with lib.git-hooks; pre-commit (wrap.abort-on-change update-readme)}
>     '';
>   };
> }
> ```
>

## `lib.nixdoc-to-github.run`

- `description` (string)

  Title to be displayed as the first heading in the document.

- `category` (string)

  Top-level attribute name for the library.
  For example, setting `"foo"` will result in headings of the form `lib.foo.some-function`.

- `file` (string)

  Nix file to parse.

- `output` (string)

  File to write the output to.



