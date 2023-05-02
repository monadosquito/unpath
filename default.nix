let
    nixpkgs = pin.nixpkgs {};
    pin = import ./chr/pin.nix;
in
    {
        pkgs ? nixpkgs,
    }
    :
    pkgs.stdenv.mkDerivation
        {
            installPhase = pkgs.lib.readFile ./scr/instl.sh;
            name = "unpath";
            phases = ["installPhase"];
            src = ./src;
            version = "1.0.0";
        }
