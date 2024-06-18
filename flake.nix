{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
    hyprland = {
      # Use v0.40.0 until new implementation is stable
      url = "git+https://github.com/hyprwm/Hyprland?rev=cba1ade848feac44b2eda677503900639581c3f4&submodules=1";
    };
    xremap-flake = {
      url = "github:xremap/nix-flake";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
    nur = {
      url = "github:nix-community/NUR";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
    nixvim = {
      url = "github:nix-community/nixvim";
    };
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
    aiken = {
      url = "github:aiken-lang/aiken";
    };
    neorg-overlay = {
      url = "github:nvim-neorg/nixpkgs-neorg-overlay";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
    };
    yazi = {
      url = "github:sxyazi/yazi";
    };
  };

  outputs = {...} @ inputs: let
    inherit (inputs) nixpkgs;
    inherit (nixpkgs) lib;
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    inherit inputs;
    nixosModules = import ./modules {inherit lib inputs nixpkgs pkgs system;};
    formatter = pkgs.alejandra;
  };

  nixConfig = {
    extra-trusted-substituters = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://yazi.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://cache.iog.io"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
  };
}
