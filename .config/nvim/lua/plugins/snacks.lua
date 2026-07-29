vim.keymap.set("n", "<leader>bd", function() require("snacks").bufdelete() end, { desc = "close buffer" })
