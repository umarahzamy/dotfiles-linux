pcall(function()
  require("catppuccin").setup({
    flavour = "mocha",
    term_colors = false,
    transparent_background = true,
    float = { transparent = true },
  })
  vim.cmd.colorscheme("catppuccin")
end)
