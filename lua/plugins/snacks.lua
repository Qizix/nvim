return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        grep = {
          -- Вмикаємо нечіткий пошук за замовчуванням
          matcher = {
            fuzzy = true,
          },
        },
      },
    },
  },
}
