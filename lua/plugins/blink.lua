return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.completion = opts.completion or {}
      opts.completion.ghost_text = opts.completion.ghost_text or {}
      opts.completion.ghost_text.enabled = false

      opts.keymap = opts.keymap or {}
      opts.keymap["<CR>"] = { "fallback" }
      opts.keymap["<Tab>"] = { "select_and_accept", "fallback" }
    end,
  },
}
