with (builtins.fromJSON (builtins.readFile ./nixpkgs.json));
let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
    inherit sha256;
  }) { config.allowUnfree = true; };

  iosCompiler =
    pkgs.pkgsCross.iphone64.haskell.packages.integer-simple.ghc865.override {
      overrides = self: super: {
        mkDerivation = args: super.mkDerivation (args // {
          enableLibraryProfiling = false;
            doCheck = false;
            doHaddock = false;
          });
        ghc = super.ghc.overrideAttrs (drv: {
          patchPhase = ''
            sed -i -e '4092,4093d' compiler/main/DynFlags.hs
          '';
       });
     };
   };

  libiservARM = with pkgs.haskell.lib; doJailbreak (
    iosCompiler.callCabal2nixWithOptions "libiserv" libiserv-src "-fnetwork" {
      network = iosCompiler.network_2_6_3_1;
    });

  libiserv-src =
    pkgs.fetchzip {
      url = http://releases.mobilehaskell.org/ghc-packages/libiserv-8.6.5.tar.gz;
      sha256 = "1s6mlhx88klr223n82zqv0xra3zcn06ayan9zk5zbv8n04nnvb13";
    };

  libiserv = with pkgs.haskell.lib;
    pkgs.haskellPackages.callCabal2nixWithOptions "libiserv" libiserv-src "-fnetwork" {
      network = dontCheck (pkgs.haskell.packages.ghc865.network_2_6_3_1);
    };

  remote-iservPkg = with pkgs.haskell.lib;
    iosCompiler.callCabal2nix "remote-iserv" ./. {
      libiserv = libiservARM;
    };

  remote-iserv = remote-iservPkg.overrideAttrs (drv: {
     preBuild = ''
        export NIX_CFLAGS_COMPILE="-framework Foundation -framework UIKit $NIX_CFLAGS_COMPILE"
     '';
     buildInputs =
       ["${pkgs.darwin.xcode}/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System"] ++
          drv.buildInputs;
  });

in
  remote-iserv
