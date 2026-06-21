# Neovim Config

Fast Neovim setup with Telescope, colorschemes, Alpha start page, LSP, completion, autopairs, and a few custom text objects.

## Install From Zero

Ubuntu/Debian:

```sh
sudo apt update && sudo apt install -y neovim git ripgrep nodejs npm && rm -rf ~/.config/nvim && git clone -b server https://github.com/Qizix/nvim ~/.config/nvim && nvim --headless "+Lazy! sync" +qa
```

Then open Neovim:

```sh
nvim
```

## Main Binds

- `<space>ff` find files
- `<space>fg` search text
- `<space>fb` find buffers
- `<space>fh` find help
- `gd` go to definition
- `K` hover docs
- `<leader>rn` rename symbol
- `<leader>ca` code action
- `viq` select inside nearest quote
- `vaq` select around nearest quote
- `vib` select inside nearest bracket
- `vab` select around nearest bracket
