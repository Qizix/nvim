local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true

local node_bins = vim.fn.glob("/opt/nvm/versions/node/v*/bin", true, true)
if #node_bins > 0 then
  vim.env.PATH = node_bins[#node_bins] .. ":" .. vim.env.PATH
end

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

local function is_escaped(line, index)
  local backslashes = 0
  index = index - 1

  while index >= 1 and line:sub(index, index) == "\\" do
    backslashes = backslashes + 1
    index = index - 1
  end

  return backslashes % 2 == 1
end

local function select_range(row, start_col, end_col)
  if start_col > end_col then
    return
  end

  vim.fn.setpos(".", { 0, row, start_col, 0 })
  vim.cmd("normal! v")
  vim.fn.setpos(".", { 0, row, end_col, 0 })
end

local function select_nearest_quotes(inner)
  local row = vim.fn.line(".")
  local col = vim.fn.col(".")
  local line = vim.fn.getline(row)
  local best

  for _, quote in ipairs({ "'", '"', "`" }) do
    local left
    for index = col, 1, -1 do
      if line:sub(index, index) == quote and not is_escaped(line, index) then
        left = index
        break
      end
    end

    local right
    for index = col + 1, #line do
      if line:sub(index, index) == quote and not is_escaped(line, index) then
        right = index
        break
      end
    end

    if left and right then
      local width = right - left
      if not best or width < best.width then
        best = { left = left, right = right, width = width }
      end
    end
  end

  if not best then
    return
  end

  local start_col = best.left + (inner and 1 or 0)
  local end_col = best.right - (inner and 1 or 0)
  select_range(row, start_col, end_col)
end

local function select_nearest_pair(pairs, inner)
  local row = vim.fn.line(".")
  local col = vim.fn.col(".")
  local line = vim.fn.getline(row)
  local best

  for _, pair in ipairs(pairs) do
    local left_char, right_char = pair[1], pair[2]
    local left
    for index = col, 1, -1 do
      if line:sub(index, index) == left_char then
        left = index
        break
      end
    end

    local right
    for index = col + 1, #line do
      if line:sub(index, index) == right_char then
        right = index
        break
      end
    end

    if left and right then
      local width = right - left
      if not best or width < best.width then
        best = { left = left, right = right, width = width }
      end
    end
  end

  if not best then
    return
  end

  local start_col = best.left + (inner and 1 or 0)
  local end_col = best.right - (inner and 1 or 0)
  select_range(row, start_col, end_col)
end

for _, mode in ipairs({ "o", "x" }) do
  vim.keymap.set(mode, "iq", function()
    select_nearest_quotes(true)
  end, { desc = "Inside nearest quote" })

  vim.keymap.set(mode, "aq", function()
    select_nearest_quotes(false)
  end, { desc = "Around nearest quote" })

  vim.keymap.set(mode, "ib", function()
    select_nearest_pair({ { "(", ")" }, { "[", "]" }, { "{", "}" } }, true)
  end, { desc = "Inside nearest bracket" })

  vim.keymap.set(mode, "ab", function()
    select_nearest_pair({ { "(", ")" }, { "[", "]" }, { "{", "}" } }, false)
  end, { desc = "Around nearest bracket" })
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  end,
})

require("lazy").setup({
  {
    "goolord/alpha-nvim",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        [[              v .   ._, |_  .              ]],
        [[           `-._\/  .  \\ /    |/_            ]],
        [[               \\  _\, y | \//              ]],
        [[         _\_.___\\, \\/ -.\||               ]],
        [[           `7-,--.`._||  / / ,              ]],
        [[           /'     `-. `./ / |/_.'           ]],
        [[                     |    |//               ]],
        [[                     |_    /                ]],
        [[                     |-   |                 ]],
        [[                     |   =|                 ]],
        [[                     |    |                 ]],
        [[--------------------/ ,  . \\--------._     ]],
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "Find files", ":Telescope find_files<CR>"),
        dashboard.button("g", "Search text", ":Telescope live_grep<CR>"),
        dashboard.button("r", "Recent files", ":Telescope oldfiles<CR>"),
        dashboard.button("q", "Quit", ":qa<CR>"),
      }

      alpha.setup(dashboard.opts)
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Search text" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Find help" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<esc>"] = require("telescope.actions").close,
            },
          },
        },
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "buffer" },
        },
      })
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})

      local cmp_ok, cmp = pcall(require, "cmp")
      if cmp_ok then
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    version = "v1.8.0",
    dependencies = {
      { "williamboman/mason.nvim", version = "v1.11.0" },
      { "williamboman/mason-lspconfig.nvim", version = "v1.32.0" },
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()

      local servers = {
        "lua_ls",
        "pyright",
        "ts_ls",
        "bashls",
        "jsonls",
      }

      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_installation = true,
      })

      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local configs = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
      }

      for _, server in ipairs(servers) do
        if lspconfig[server] then
          local config = configs[server] or {}
          config.capabilities = capabilities
          lspconfig[server].setup(config)
        end
      end
    end,
  },
})
