local M = {}

local substitution_patterns = { "%.json$", "%.txt$", "%.md$", "%.typ$" }
M.substitution_patterns = substitution_patterns

M.compile = function()
  local file = vim.fn.expand("%:p")
  if not file:match("%.typ$") then
    return
  end
  local dir = vim.fn.expand("%:p:h")
  local name = vim.fn.expand("%:t:r")
  local pdf_dir = dir .. "/pdf"
  vim.fn.mkdir(pdf_dir, "p")
  local pdf = pdf_dir .. "/" .. name .. ".pdf"
  vim.system({ "typst", "compile", file, pdf }, { cwd = dir }, function(obj)
    if obj.code == 0 then
      vim.schedule(function()
        vim.notify("typst: compiled " .. vim.fn.fnamemodify(pdf, ":~"), vim.log.levels.INFO)
      end)
    else
      vim.schedule(function()
        vim.notify("typst: failed\n" .. obj.stderr, vim.log.levels.ERROR)
      end)
    end
  end)
end

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = {"*.typ", "*.txt", "*.md", "*.json"},
  callback = function()
    vim.cmd([[%s/\%u2019/'/ge]])
    vim.cmd([[%s/\%u2013/-/ge]])
    vim.cmd([[%s/\%u2014/-/ge]])
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.typ",
  callback = M.compile,
})

return M
