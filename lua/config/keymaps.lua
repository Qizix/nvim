-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Delete without yanking
vim.keymap.set({ "n", "x" }, "x", '"_x', { desc = "Delete char/selection (no yank)" })
vim.keymap.set("n", "X", '"_X', { desc = "Delete backward char (no yank)" })
