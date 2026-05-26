{
  description = "Next.js Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-linux"; # Or x86_64-linux if you move this
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "nodejs-20.20.2"
            "nodejs-slim-20.20.2"
          ];
        };
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          bashInteractive
          pkg-config
          python3
        ];

        buildInputs = with pkgs; [
          nodejs_20 # Or whatever version you need
          bun

          # --- ADDED: Browser for Playwright ---
          chromium

          # If you have native modules that need system libs:
          stdenv.cc.cc.lib
          glib
        ];

        shellHook = ''
          echo "🚀 Next.js Environment Loaded"
          echo "Node: $(node --version)"
          echo "Bun: $(bun --version)"
          
          # --- ADDED: Playwright Configuration ---
          # Tell Playwright to use the Chromium installed by Nix
          export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
          export PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH="${pkgs.chromium}/bin/chromium"

          # Fix for native modules finding libraries
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ 
            pkgs.stdenv.cc.cc.lib 
            pkgs.glib
          ]}:$LD_LIBRARY_PATH"
        '';
      };
    };
}
