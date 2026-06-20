local function cwd_dir()
  return vim.uv.cwd() or vim.fn.getcwd()
end

local function root_dir()
  return LazyVim.root()
end

local function visual_or_cword()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    local start_pos = vim.api.nvim_buf_get_mark(0, "<")
    local end_pos = vim.api.nvim_buf_get_mark(0, ">")
    local lines = vim.api.nvim_buf_get_text(0, start_pos[1] - 1, start_pos[2], end_pos[1] - 1, end_pos[2] + 1, {})
    return table.concat(lines, " ")
  end

  return vim.fn.expand("<cword>")
end

local function open_fff(dir, method, opts)
  return function()
    local fff = require("fff")
    fff.change_indexing_directory(dir())
    fff[method](type(opts) == "function" and opts() or opts)
  end
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader><space>", false },
      { "<leader>/", false },
      { "<leader>fc", false },
      { "<leader>ff", false },
      { "<leader>fF", false },
      { "<leader>sg", false },
      { "<leader>sG", false },
      { "<leader>sw", false },
      { "<leader>sW", false },
    },
  },
  {
    "dmtrKovalenko/fff.nvim",
    build = function()
      require("fff.download").download_or_build_binary()
    end,
    lazy = false,
    opts = {
      lazy_sync = true,
      frecency = {
        enabled = true,
      },
      history = {
        enabled = true,
      },
    },
    keys = {
      { "<leader><space>", open_fff(root_dir, "find_files"), desc = "Find Files (Root Dir)" },
      { "<leader>/", open_fff(root_dir, "live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>fc", open_fff(function() return vim.fn.stdpath("config") end, "find_files"), desc = "Find Config File" },
      { "<leader>ff", open_fff(root_dir, "find_files"), desc = "Find Files (Root Dir)" },
      { "<leader>fF", open_fff(cwd_dir, "find_files"), desc = "Find Files (cwd)" },
      { "<leader>sg", open_fff(root_dir, "live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>sG", open_fff(cwd_dir, "live_grep"), desc = "Grep (cwd)" },
      {
        "<leader>sw",
        open_fff(root_dir, "live_grep", function()
          return { query = visual_or_cword() }
        end),
        desc = "Visual selection or word (Root Dir)",
        mode = { "n", "x" },
      },
      {
        "<leader>sW",
        open_fff(cwd_dir, "live_grep", function()
          return { query = visual_or_cword() }
        end),
        desc = "Visual selection or word (cwd)",
        mode = { "n", "x" },
      },
    },
  },
}
