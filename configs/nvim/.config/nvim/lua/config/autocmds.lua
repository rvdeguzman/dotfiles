-- Autocmds are automatically loaded on the VeryLazy event.

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("personal-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 75 })
  end,
})
