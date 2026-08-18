{ config, lib, pkgs, ... }: {
  home-manager = {
    users.koshchei = { pkgs, ... }: {
      programs = {
        neovim = {
	  enable = true;
	  defaultEditor = true;
	  initLua = 
            let
	      clipboard = lib.mkAfter "vim.opt.clipboard = 'unnamedplus'";
	    in
	      lib.mkMerge [ clipboard ];
	};
      };
    };
  };
}
