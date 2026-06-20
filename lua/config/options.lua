-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.termguicolors = true
vim.g.ai_cmp = false

-- Keep root/picker scope at current working directory (disable project-style root detection)
vim.g.root_spec = { "cwd" }
