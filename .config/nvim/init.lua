vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 4000
vim.opt.timeout = true
vim.opt.clipboard = "unnamedplus"
vim.opt.autoread = true
vim.opt.termguicolors = true
vim.opt.cursorline = true

-- autoread
local checktime_group = vim.api.nvim_create_augroup("auto_checktime", { clear = true })
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "FocusGained" }, {
  group = checktime_group,
  callback = function()
    if vim.bo.buftype ~= "nofile" then vim.cmd.checktime() end
  end,
})

vim.keymap.set({ "n", "v", "o" }, "q", "<Nop>")

-- packages
vim.pack.add({
  { src = "https://github.com/folke/flash.nvim", name = "flash" },
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  { src = "https://github.com/dmtrKovalenko/fff.nvim", name = "fff" },
  { src = "https://github.com/MagicDuck/grug-far.nvim", name = "grug-far" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "nvim-treesitter" },
  { src = "https://github.com/max397574/better-escape.nvim", name = "better_escape" },
  { src = "https://github.com/nvim-tree/nvim-tree.lua", name = "nvim-tree" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons", name = "web-devicons" },
  { src = "https://github.com/stevearc/conform.nvim", name = "conform" },
  { src = "https://github.com/folke/snacks.nvim", name = "snacks" },
  { src = "https://github.com/folke/trouble.nvim", name = "trouble" },
  { src = "https://github.com/neovim/nvim-lspconfig", name = "lspconfig" },
})

-- fff: download binary on install/update
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "fff.nvim" and (kind == "install" or kind == "update") then
      if not ev.data.active then vim.cmd.packadd("fff.nvim") end
      require("fff.download").download_or_build_binary()
    end
  end,
})

-- global plugins: work in vscode too
require("plugins.flash")
require("plugins.better-escape")
require("plugins.catppuccin")

-- non-vscode: plugins, keymaps, UI
if not vim.g.vscode then
  -- terminal keymaps
  vim.keymap.set("t", "[b", "<C-\\><C-n>:bprevious!<CR>", { desc = "previous buffer" })
  vim.keymap.set("t", "]b", "<C-\\><C-n>:bnext!<CR>", { desc = "next buffer" })
  vim.keymap.set("t", "<C-space>", "<C-\\><C-n>", { desc = "exit terminal" })
  for _, dir in ipairs({ "h", "j", "k", "l" }) do
    vim.keymap.set("t", "<C-w>" .. dir, ("<C-\\><C-n><C-w>%s"):format(dir), { desc = "terminal: move " .. dir })
  end
  vim.keymap.set({ "n", "t" }, "<C-`>", function()
    vim.cmd("term")
  end, { desc = "terminal" })

  -- on terminal exit: delete buffer and replace window with MRU (like bufdelete)
  vim.api.nvim_create_autocmd("TermClose", {
    callback = function(ev)
      require("plugins.snacks").bufdelete(ev.buf)
    end,
    desc = "delete terminal buffer on exit (like bufdelete)",
  })

  vim.keymap.set("n", "<leader>qq", ":qa!<CR>", { desc = "quit all" })

  require("plugins.snacks")
  require("plugins.fff")
  require("plugins.grug-far")
  require("plugins.nvim-tree")
  require("plugins.conform")
end

-- LSP attach: buffer-local keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = "lsp: " .. desc })
    end
    map("n", "gd", vim.lsp.buf.definition, "go to definition")
    map("n", "K", vim.lsp.buf.hover, "hover")
    map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "code action")
    map("n", "gr", vim.lsp.buf.references, "references")
    map("n", "[d", vim.diagnostic.goto_prev, "prev diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "next diagnostic")
  end,
})

-- treesitter is auto-started in neovim 0.12 when a parser is available.
-- nvim-treesitter is kept in pack.add for TSInstall / parser management.

require("plugins.zathura")
require("plugins.typst")
require("plugins.vscode")
